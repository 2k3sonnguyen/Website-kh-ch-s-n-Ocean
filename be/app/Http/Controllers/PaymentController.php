<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Payment;
use App\Models\Booking;
use App\Models\Room;
use App\Models\Service;
use App\Models\ServiceOrder; 
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Cache;

class PaymentController extends Controller
{
    public function createPayment(Request $request)
    {
        $request->validate([
            'booking_id' => 'required|exists:bookings,id',
            'amount' => 'required|numeric|min:1000',
            'method' => 'required|in:wallet,atm,qr',
        ]);

        $endpoint = "https://test-payment.momo.vn/v2/gateway/api/create";
        $partnerCode = "MOMO";
        $accessKey = "F8BBA842ECF85";
        $secretKey = "K951B6PE1waDMi640xX08PD3vg6EkVlz";

        $orderId = uniqid();
        $requestId = uniqid();
        $method = $request->input('method');
        $bookingId = $request->input('booking_id');
        $amount = $request->input('amount');

        $requestType = match ($method) {
            'wallet', 'qr' => 'captureWallet',
            'atm' => 'payWithATM',
        };

        $redirectUrl = route('payment.callback');
        $ipnUrl = route('payment.ipn');

        $rawHash = "accessKey=$accessKey&amount=$amount&extraData=&ipnUrl=$ipnUrl&orderId=$orderId&orderInfo=Thanh toán đặt phòng&partnerCode=$partnerCode&redirectUrl=$redirectUrl&requestId=$requestId&requestType=$requestType";
        $signature = hash_hmac("sha256", $rawHash, $secretKey);

        $data = [
            'partnerCode' => $partnerCode,
            'accessKey' => $accessKey,
            'requestId' => $requestId,
            'amount' => $amount,
            'orderId' => $orderId,
            'orderInfo' => "Thanh toán đặt phòng",
            'redirectUrl' => $redirectUrl,
            'ipnUrl' => $ipnUrl,
            'extraData' => "",
            'requestType' => $requestType,
            'signature' => $signature,
            'lang' => 'vi'
        ];

        try {
            $ch = curl_init($endpoint);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
            curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
            $result = curl_exec($ch);
            curl_close($ch);

            Log::info('MoMo Response:', [$result]);

            $jsonResult = json_decode($result, true);

            if (!$jsonResult || !isset($jsonResult['payUrl'])) {
                Log::error('Tạo liên kết thanh toán thất bại:', ['response' => $result]);
                return response()->json([
                    'message' => 'Không thể tạo liên kết thanh toán',
                    'error' => $jsonResult
                ], 500);
            }

            Payment::create([
                'booking_id' => $bookingId,
                'amount' => $amount,
                'method' => $method,
                'status' => 'unpaid',
                'payment_date' => now(),
                'momo_order_id' => $orderId,
            ]);

            $selectedServices = $request->input('selectedServices', []);
            Cache::put('booking_services_' . $bookingId, $selectedServices, now()->addMinutes(10));

            return response()->json([
                'payUrl' => $jsonResult['payUrl'],
                'qrCodeUrl' => $jsonResult['deeplink'] ?? '',
                'method' => $method,
                'result' => $jsonResult
            ]);
        } catch (\Exception $e) {
            Log::error('Lỗi khi gửi yêu cầu MoMo:', ['error' => $e->getMessage()]);
            return response()->json([
                'message' => 'Đã xảy ra lỗi khi gửi yêu cầu thanh toán',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function callback(Request $request)
    {
        $data = $request->all();
        Log::info('MoMo Callback:', $data);

        if (isset($data['resultCode']) && $data['resultCode'] == '0') {
            $payment = Payment::where('momo_order_id', $data['orderId'])->first();
            if ($payment) {
                $payment->update(['status' => 'paid']);

                $booking = Booking::find($payment->booking_id);
                Log::info("Booking ID {$booking->id}, discount_code: " . ($booking->discount_code ?? 'null'));

                if ($booking) {
                    $booking->update(['status' => 'confirmed']);

                    $room = Room::find($booking->room_id);
                    if ($room) {
                        //$room->update(['status' => 'booked']);
                    }

                    // Tính số ngày
                    $daysBooked = (new \DateTime($booking->check_in))->diff(new \DateTime($booking->check_out))->days;

                    // **Không cần dùng discount_usage**, chỉ giữ nguyên discount_code và discount_percent trên bảng bookings
                    if ($booking->discount_code) {
                        Log::info("Applied discount: code={$booking->discount_code}, percent={$booking->discount_percent}");
                    }

                    // Xử lý dịch vụ (nếu có)
                    $selectedServices = Cache::pull('booking_services_' . $booking->id, []);
                    foreach ($selectedServices as $serviceId) {
                        $service = Service::find($serviceId);
                        if ($service) {
                            $totalPrice = $service->price * $daysBooked;
                            Log::info("Dịch vụ: {$service->name}, Tổng: {$totalPrice}");
                            ServiceOrder::create([
                                'booking_id'  => $booking->id,
                                'service_id'  => $service->id,
                                'quantity'    => $daysBooked,
                                'total_price' => $totalPrice,
                                'order_date'  => now()
                            ]);
                        }
                    }
                }
            }

            return redirect('http://localhost:3000/bookinghistory?status=success');
        }

        return redirect('http://localhost:3000/bookinghistory?status=fail');
    }


    public function handleIpn(Request $request)
    {
        $data = $request->all();
        Log::info('MoMo IPN:', $data);

        $orderId = $data['orderId'] ?? null;
        $resultCode = $data['resultCode'] ?? -1;

        if ($orderId && $resultCode == 0) {
            Payment::where('momo_order_id', $orderId)->update(['status' => 'paid']);
        }

        return response()->json(['message' => 'IPN received', 'data' => $data]);
    }

    public function index()
    {
        try {
            // Lấy tất cả thanh toán chưa bị xóa theo thứ tự desc
            $payments = Payment::whereNull('deleted_at')->orderBy('id', 'desc')->get();

            if ($payments->isEmpty()) {
                return response()->json([
                    'status' => false,
                    'message' => 'Không có thanh toán nào.',
                    'data' => []
                ], 404);
            }

            return response()->json([
                'status' => true,
                'message' => 'Danh sách thanh toán.',
                'data' => $payments
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'status' => false,
                'message' => 'Đã xảy ra lỗi khi lấy danh sách thanh toán.',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function update(Request $request, $id)
    {
        // Validate dữ liệu đầu vào
        $request->validate([
            'method' => 'required|in:atm,qr', // Kiểm tra phương thức thanh toán
            'status' => 'required|in:unpaid,paid', // Kiểm tra trạng thái thanh toán
        ]);

        try {
            // Tìm kiếm payment theo id
            $payment = Payment::find($id);

            // Kiểm tra nếu không tìm thấy payment
            if (!$payment) {
                return response()->json([
                    'status' => false,
                    'message' => 'Thanh toán không tồn tại.'
                ], 404);
            }

            // Kiểm tra nếu status không được thay đổi thành "paid" khi payment đã được thanh toán
            if ($payment->status == 'paid' && $request->status == 'paid') {
                return response()->json([
                    'status' => false,
                    'message' => 'Thanh toán đã được xác nhận.'
                ], 400);
            }

            // Cập nhật các trường trong Payment
            $payment->payment_date = now(); // Cập nhật payment_date với thời gian hiện tại
            $payment->method = $request->input('method'); // Cập nhật phương thức thanh toán
            $payment->status = $request->input('status'); // Cập nhật trạng thái thanh toán

            // Lưu thay đổi vào cơ sở dữ liệu
            $payment->save();

            // Trả về kết quả thành công
            return response()->json([
                'status' => true,
                'message' => 'Cập nhật thanh toán thành công.',
                'data' => $payment
            ], 200);

        } catch (\Exception $e) {
            // Xử lý lỗi nếu có
            return response()->json([
                'status' => false,
                'message' => 'Đã xảy ra lỗi trong quá trình cập nhật.',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
