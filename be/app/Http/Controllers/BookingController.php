<?php

namespace App\Http\Controllers;
use App\Models\Booking;
use App\Models\Room;
use App\Models\Payment;
use App\Models\ServiceOrder;
use App\Models\Invoice;
use App\Models\InvoiceItem;
use Illuminate\Http\Request;
use Carbon\Carbon;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;


class BookingController extends Controller
{
    public function store(Request $request)
    {
        $room = Room::findOrFail($request->room_id);

        $checkIn = Carbon::parse($request->check_in);
        $checkOut = Carbon::parse($request->check_out);
        $days = $checkOut->diffInDays($checkIn);

        // Tính tổng giá
        $totalPrice = $room->price * $days;

        // Kiểm tra phòng có đặt chồng lên nhau không
        $existingBooking = Booking::where('room_id', $request->room_id)
                                    ->where(function ($query) use ($checkIn, $checkOut) {
                                        $query->whereBetween('check_in', [$checkIn, $checkOut])
                                            ->orWhereBetween('check_out', [$checkIn, $checkOut]);
                                    })
                                    ->exists();
        if ($existingBooking) {
            return response()->json([
                'status' => false,
                'message' => 'Phòng đã được đặt trong khoảng thời gian này.'
            ], 400);
        }


        $validated = $request->validate([
            'user_id' => 'required|exists:users,id',
            'room_id' => 'required|exists:rooms,id',
            'check_in' => 'required|date|after_or_equal:today',
            'check_out' => 'required|date|after:check_in',
            'discount_code'      => 'nullable|string',
            'discount_percent'   => 'nullable|numeric',
        ]);

        // Gộp thêm các trường còn thiếu để lưu
        $validated['total_price'] = $totalPrice;
        $validated['status'] = 'pending'; // mặc định khi user đặt phòng
        
        $booking = Booking::create($validated);
        

        return response()->json([
            'status' => true,
            'message' => 'Đặt phòng thành công!',
            'data' => $booking
        ], 201);
    }

    public function userBookings()
    {
        $user = Auth::user(); // Lấy người dùng đang đăng nhập

        // Lấy tất cả đơn đặt phòng, bao gồm cả đơn đã xóa mềm
        $bookings = Booking::withTrashed()
                    ->where('user_id', $user->id)
                    ->get();

        if ($bookings->isEmpty()) {
            return response()->json([
                'status' => false,
                'message' => 'Người dùng chưa có đơn đặt phòng nào.',
                'data' => []
            ], 200);
        }

        return response()->json([
            'status' => true,
            'message' => 'Danh sách tất cả đơn đặt phòng (kể cả đã xóa).',
            'data' => $bookings
        ], 200);
    }

    public function destroy($id)
    {
        $user = Auth::user();

        // Tìm booking thuộc về user hiện tại
        $booking = Booking::where('id', $id)->where('user_id', $user->id)->first();

        if (!$booking) {
            return response()->json([
                'status' => false,
                'message' => 'Không tìm thấy đơn đặt phòng hoặc bạn không có quyền hủy.'
            ], 404);
        }

        $booking->delete();

        return response()->json([
            'status' => true,
            'message' => 'Đã hủy đơn đặt phòng thành công.'
        ], 200);
    }

    public function checkAvailability(Request $request) {
        $validator = Validator::make($request->all(), [
            'room_id' => 'required|integer|exists:rooms,id',
            'check_in' => 'required|date',
            'check_out' => 'required|date|after:check_in',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'errors' => $validator->errors()
            ], 422);
        }

        $roomId = $request->room_id;
        $checkIn = $request->check_in;
        $checkOut = $request->check_out;

        $hasConflict = Booking::where('room_id', $roomId)
            ->where(function ($query) use ($checkIn, $checkOut) {
                $query->whereBetween('check_in', [$checkIn, $checkOut])
                    ->orWhereBetween('check_out', [$checkIn, $checkOut])
                    ->orWhere(function ($q) use ($checkIn, $checkOut) {
                        $q->where('check_in', '<=', $checkIn)
                        ->where('check_out', '>=', $checkOut);
                    });
            })
            ->exists();

        return response()->json([
            'available' => !$hasConflict,
        ]);
    }

    public function getAllBookings()
    {
        // Lấy tất cả các booking chưa bị xóa (tức là không có giá trị trong 'deleted_at')
        $bookings = Booking::whereNull('deleted_at')->orderBy('id', 'desc')->get();

        return response()->json([
            'status' => true,
            'data' => $bookings
        ]);
    }

    public function update(Request $request, $id)
    {
        // Tìm booking cần cập nhật
        $booking = Booking::find($id);

        if (!$booking) {
            return response()->json(['message' => 'Booking not found'], 404);
        }
        
        // Validate dữ liệu
        $validated = $request->validate([
            'user_id' => 'exists:users,id',
            'room_id' => 'exists:rooms,id',
            'check_in' => 'date',
            'check_out' => 'date|after:check_in',
            'status' => 'in:pending,confirmed,canceled,done',
        ]);

        // Kiểm tra chuyển trạng thái hợp lệ
        $currentStatus = $booking->status;
        $newStatus = $validated['status'];

        $allowedTransitions = [
            'pending' => ['canceled'],
            'confirmed' => ['done'],
            'done' => [],
            'canceled' => [],
        ];

        if (!in_array($newStatus, $allowedTransitions[$currentStatus])) {
            return response()->json([
                'status' => false,
                'message' => 'Trạng thái không hợp lệ'
            ], 400);
        }

        // Lấy thông tin phòng từ bảng rooms dựa trên room_id
        $room = Room::find($validated['room_id']);
        if (!$room) {
            return response()->json(['message' => 'Room not found'], 404);
        }

        // Tính số ngày giữa check_in và check_out
        $check_in = new \Carbon\Carbon($validated['check_in']);
        $check_out = new \Carbon\Carbon($validated['check_out']);
        $days = $check_in->diffInDays($check_out);

        // Tính tổng tiền (total_price) = số ngày * giá phòng mỗi đêm
        $total_price = $days * $room->price;

        // Cập nhật dữ liệu booking
        $booking->update([
            'user_id' => $validated['user_id'],
            'room_id' => $validated['room_id'],
            'check_in' => $validated['check_in'],
            'check_out' => $validated['check_out'],
            'status' => $validated['status'],
            'total_price' => $total_price, // Cập nhật tổng tiền tự động
        ]);

        // KIỂM TRA VÀ TẠO HÓA ĐƠN
        if ($validated['status'] === 'done') {
            // Kiểm tra đã thanh toán chưa
            $payment = Payment::where('booking_id', $booking->id)
                                ->where('status', 'paid')
                                ->first();

            // Kiểm tra chưa có hóa đơn
            $existingInvoice = Invoice::where('booking_id', $booking->id)->first();

            if ($payment && !$existingInvoice) {
                // Lấy tổng giá dịch vụ (nếu có)
                $serviceTotal = ServiceOrder::where('booking_id', $booking->id)->sum('total_price');

                // Lấy tổng giá phòng từ booking
                $basePrice = $booking->total_price;

                // Tính phần giảm giá nếu có
                $discountPercent = $booking->discount_percent ?? 0;
                $discountAmount = ($basePrice + $serviceTotal) * ($discountPercent / 100);

                // Tính tổng tiền
                $invoiceTotal = $basePrice + $serviceTotal - $discountAmount;

                // Tạo hóa đơn
                $invoice = Invoice::create([
                    'booking_id'   => $booking->id,
                    'total_amount' => $invoiceTotal,
                    'status'       => 'paid',
                ]);

                // Tạo các mục chi tiết hóa đơn (Invoice Items)
                InvoiceItem::create([
                    'invoice_id' => $invoice->id,  // Sử dụng id của hóa đơn vừa tạo
                    'description' => 'Phòng ' . $room->name, // Mô tả chi tiết
                    'amount' => $room->price,  // Đơn giá của phòng
                    'quantity' => $days, // Số lượng (ngày thuê phòng)
                    'total_amount' => $total_price,  // Thành tiền
                ]);
            }
        }

        // Nếu status là canceled thì xóa booking 
        if ($validated['status'] === 'canceled') {
            $booking->delete(); 
            return response()->json([
                'message' => 'Booking đã bị hủy.',
                'booking' => $booking
            ]);
        }

        return response()->json([
            'message' => 'Booking updated successfully',
            'booking' => $booking
        ]);
    }

    public function deleteBooking($id)
    {
        // Tìm booking theo ID
        $booking = Booking::find($id);

        // Nếu không tìm thấy, trả về lỗi
        if (!$booking) {
            return response()->json([
                'status' => false,
                'message' => 'Không tìm thấy booking.'
            ], 404);
        }

        // Thực hiện xóa booking và các bản ghi liên quan
        $booking->delete();

        return response()->json([
            'status' => true,
            'message' => 'Booking đã được xóa.'
        ]);
    }
}
