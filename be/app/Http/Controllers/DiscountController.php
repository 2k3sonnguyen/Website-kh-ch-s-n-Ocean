<?php

namespace App\Http\Controllers;

use App\Models\Discount;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;


class DiscountController extends Controller
{
    public function index()
    {
        try {
            // Lấy tất cả các discount và sắp xếp theo thứ tự giảm dần của created_at
            $discounts = Discount::orderBy('created_at', 'desc')->get();

            // Cập nhật trạng thái discount nếu ngày kết thúc đã qua
            foreach ($discounts as $discount) {
                if (Carbon::parse($discount->end_date)->isPast() && $discount->status !== 'expired') {
                    $discount->status = 'expired';
                    $discount->save();  // Lưu lại trạng thái đã thay đổi
                }
            }

            if ($discounts->isEmpty()) {
                return response()->json([
                    'status' => false,
                    'message' => 'Không có mã giảm giá nào.',
                    'data' => []
                ], 404);
            }

            return response()->json([
                'status' => true,
                'message' => 'Danh sách mã giảm giá.',
                'data' => $discounts
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'status' => false,
                'message' => 'Đã xảy ra lỗi khi lấy danh sách mã giảm.',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function apply(Request $request)
    {
        $request->validate([
            'code' => 'required|string'
        ]);

        $discount = Discount::where('code', $request->code)->first();

        if (!$discount) {
            return response()->json([
                'status' => false,
                'message' => 'Mã giảm giá không tồn tại.'
            ], 404);
        }

        // Kiểm tra hạn sử dụng
        $today = Carbon::now();
        if ($today->lt($discount->start_date) || $today->gt($discount->end_date)) {
            return response()->json([
                'status' => false,
                'message' => 'Mã giảm giá đã hết hạn hoặc chưa được kích hoạt.'
            ], 400);
        }

        return response()->json([
            'status' => true,
            'message' => 'Áp dụng mã giảm giá thành công.',
            'data' => [
                'code' => $discount->code,
                'discount_value' => $discount->discount_value
            ]
        ], 200);
    }

    // Tạo discount mới
    public function store(Request $request)
    {
        $messages = [
            'code.required' => 'Vui lòng nhập mã giảm giá.',
            'code.unique' => 'Mã giảm giá đã tồn tại.',
            'discount_type.required' => 'Vui lòng chọn loại giảm giá.',
            'discount_type.in' => 'Loại giảm giá không hợp lệ (chỉ chấp nhận "percent").',
            'discount_value.required' => 'Vui lòng nhập giá trị giảm.',
            'discount_value.numeric' => 'Giá trị giảm phải là số.',
            'discount_value.min' => 'Giá trị giảm phải lớn hơn hoặc bằng 0.',
            'start_date.required' => 'Vui lòng nhập ngày bắt đầu.',
            'start_date.date' => 'Ngày bắt đầu không hợp lệ.',
            'start_date.before_or_equal' => 'Ngày bắt đầu phải trước hoặc bằng ngày kết thúc.',
            'end_date.required' => 'Vui lòng nhập ngày kết thúc.',
            'end_date.date' => 'Ngày kết thúc không hợp lệ.',
            'end_date.after_or_equal' => 'Ngày kết thúc phải sau hoặc bằng ngày bắt đầu.',
            'status.required' => 'Vui lòng chọn trạng thái.',
            'status.in' => 'Trạng thái phải là "active" hoặc "expired".',
        ];

        $validated = $request->validate([
            'code' => 'required|string|unique:discounts,code',
            'description' => 'nullable|string',
            'discount_type' => 'required|in:percent',
            'discount_value' => 'required|numeric|min:0',
            'start_date' => 'required|date|before_or_equal:end_date',
            'end_date' => 'required|date|after_or_equal:start_date',
            'status' => 'required|in:active,expired',
        ], $messages);

        try {
            $discount = Discount::create($validated);

            return response()->json([
                'status' => true,
                'message' => 'Mã giảm giá đã được thêm thành công.',
                'data' => $discount
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'status' => false,
                'message' => 'Đã xảy ra lỗi khi thêm mã giảm giá.',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function update(Request $request, $id)
    {
        $discount = Discount::find($id);

        if (!$discount) {
            return response()->json([
                'status' => false,
                'message' => 'Mã giảm giá không tồn tại.',
            ], 404);
        }

        $messages = [
            'code.required' => 'Vui lòng nhập mã giảm giá.',
            'code.unique' => 'Mã giảm giá đã tồn tại.',
            'discount_type.required' => 'Vui lòng chọn loại giảm giá.',
            'discount_type.in' => 'Loại giảm giá không hợp lệ.',
            'discount_value.required' => 'Vui lòng nhập giá trị giảm.',
            'discount_value.numeric' => 'Giá trị giảm phải là số.',
            'discount_value.min' => 'Giá trị giảm phải lớn hơn hoặc bằng 0.',
            'start_date.required' => 'Vui lòng nhập ngày bắt đầu.',
            'start_date.date' => 'Ngày bắt đầu không hợp lệ.',
            'start_date.before_or_equal' => 'Ngày bắt đầu phải trước hoặc bằng ngày kết thúc.',
            'end_date.required' => 'Vui lòng nhập ngày kết thúc.',
            'end_date.date' => 'Ngày kết thúc không hợp lệ.',
            'end_date.after_or_equal' => 'Ngày kết thúc phải sau hoặc bằng ngày bắt đầu.',
            'status.required' => 'Vui lòng chọn trạng thái.',
            'status.in' => 'Trạng thái không hợp lệ.',
        ];

        $validated = $request->validate([
            'code' => 'required|string|unique:discounts,code,' . $id,
            'description' => 'nullable|string',
            'discount_type' => 'required|in:percent',
            'discount_value' => 'required|numeric|min:0',
            'start_date' => 'required|date|before_or_equal:end_date',
            'end_date' => 'required|date|after_or_equal:start_date',
            'status' => 'required|in:active,expired',
        ], $messages);

        try {
            $discount->update($validated);

            return response()->json([
                'status' => true,
                'message' => 'Mã giảm giá đã được cập nhật thành công.',
                'data' => $discount
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'status' => false,
                'message' => 'Đã xảy ra lỗi khi cập nhật mã giảm giá.',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function destroy($id)
    {
        try {
            // Tìm discount theo id
            $discount = Discount::find($id);

            // Kiểm tra nếu không tìm thấy discount
            if (!$discount) {
                return response()->json([
                    'status' => false,
                    'message' => 'Mã giảm giá không tồn tại.'
                ], 404);
            }

            // Thực hiện Soft Delete
            $discount->delete();

            return response()->json([
                'status' => true,
                'message' => 'Mã giảm giá đã được xóa thành công.'
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'status' => false,
                'message' => 'Đã xảy ra lỗi khi xóa mã giảm giá.',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
