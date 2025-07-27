<?php

namespace App\Http\Controllers;

use App\Models\ServiceOrder;
use App\Models\Service;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class ServiceOrderController extends Controller
{
    public function index(Request $request)
    {
        // Lấy tất cả service_orders chưa bị xóa theo thứ tự desc
        $serviceOrders = ServiceOrder::whereNull('deleted_at')->orderBy('id', 'desc')->get();

        // Trả về kết quả dưới dạng JSON
        return response()->json([
            'status' => true,
            'message' => 'Danh sách service_orders',
            'data' => $serviceOrders
        ], 200);
    }

    public function getServiceOrderDetails($orderId)
    {
        // Kiểm tra lại orderId có hợp lệ hay không
        Log::info("Received orderId: $orderId");

        // Lấy service order theo orderId và kèm theo thông tin dịch vụ
        $order = ServiceOrder::with('service')->find($orderId);

        // Nếu không tìm thấy đơn dịch vụ, trả về lỗi
        if (!$order) {
            return response()->json([
                'status' => false,
                'message' => 'Không tìm thấy đơn dịch vụ.',
            ], 404);
        }

        // Lấy thông tin chi tiết của dịch vụ
        $data = [
            'Dịch vụ'   => $order->service->name,
            'Mô tả'     => $order->service->description,
            'Đơn giá'   => $order->service->price,
            'Số lượng'  => $order->quantity,
            'Tổng tiền' => $order->service->price * $order->quantity,
        ];

        return response()->json([
            'status' => true,
            'message' => 'Chi tiết đơn dịch vụ.',
            'data' => $data,  // Trả về dữ liệu chi tiết
        ], 200);
    }
}
