<?php

namespace App\Http\Controllers;
use App\Models\Invoice;
use Illuminate\Http\Request;

class InvoiceController extends Controller
{
    public function index()
    {
        // Lấy danh sách hóa đơn và chi tiết hóa đơn liên kết (Eager Load) theo thứ tự desc và chưa bị xóa (deleted_at IS NULL)
        $invoices = Invoice::with('items')->whereNull('deleted_at')->orderBy('id', 'desc')->get();

        return response()->json([
            'message' => 'Danh sách hóa đơn',
            'data' => $invoices
        ]);
    }

    public function show($id)
    {
        // Lấy hóa đơn kèm các mục item và liên kết booking, serviceOrders
        $invoice = Invoice::with(['items', 'booking.serviceOrders.service'])->find($id);

        if (!$invoice) {
            return response()->json([
                'status' => false,
                'message' => 'Hóa đơn không tồn tại.',
                'data' => []
            ], 404);
        }

        // Bắt đầu danh sách item từ các mục đã lưu sẵn trong DB (phòng)
        $invoiceItems = collect($invoice->items)->map(function ($item) {
            return [
                'description'   => $item->description,
                'amount'        => $item->amount,
                'quantity'      => $item->quantity,
                'total_amount'  => $item->total_amount,
            ];
        });

        // Thêm các dịch vụ (nếu có)
        foreach ($invoice->booking->serviceOrders as $so) {
            $invoiceItems->push([
                'description'   => 'Dịch vụ ' . ($so->service->name ?? 'Không xác định'),
                'amount'        => round($so->total_price / $so->quantity, 2),
                'quantity'      => $so->quantity,
                'total_amount'  => $so->total_price,
            ]);
        }

        // Thêm mục giảm giá (nếu có discount)
        $discountPercent = $invoice->booking->discount_percent ?? 0;

        if ($discountPercent > 0) {
            // Tổng trước khi giảm = tổng của tất cả các mục
            $totalBeforeDiscount = $invoiceItems->sum('total_amount');

            $discountAmount = ($totalBeforeDiscount * $discountPercent) / 100;

            $invoiceItems->push([
                'description'   => 'Giảm giá ' . $discountPercent . '%',
                'amount'        => -round($discountAmount, 2),
                'quantity'      => 1,
                'total_amount'  => -round($discountAmount, 2),
            ]);
        }

        return response()->json([
            'status'  => true,
            'message' => 'Chi tiết hóa đơn.',
            'data'    => $invoiceItems
        ]);
    }
}
