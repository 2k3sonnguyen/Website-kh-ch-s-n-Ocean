<?php

namespace App\Http\Controllers;

use App\Models\Review;
use App\Models\Booking;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class ReviewController extends Controller
{
    public function store(Request $request)
    {
        $request->validate([
            'booking_id' => 'required|exists:bookings,id',
            'rating' => 'required|integer|min:1|max:5',
            'comment' => 'nullable|string'
        ]);

        $booking = Booking::find($request->booking_id);

        if (!$booking) {
            return response()->json([
                'status' => false,
                'message' => 'Booking không tồn tại.'
            ], 404);
        }

        $userId = Auth::id();
        if (!$userId) {
            return response()->json([
                'status' => false,
                'message' => 'Bạn chưa đăng nhập.'
            ], 401);
        }

        if ($booking->user_id !== $userId) {
            return response()->json([
                'status' => false,
                'message' => 'Bạn không có quyền đánh giá booking này.'
            ], 403);
        }

        //Chỉ cho phép đánh giá khi đã checkout
        if ($booking->status !== 'done') {
            return response()->json([
                'status' => false,
                'message' => 'Chỉ có thể đánh giá sau khi hoàn thành booking.'
            ], 403);
        }

        // Không cho đánh giá lại
        $existingReview = Review::where('booking_id', $booking->id)->first();
        if ($existingReview) {
            return response()->json([
                'status' => false,
                'message' => 'Bạn đã đánh giá booking này rồi.'
            ], 400);
        }

        try {
            $review = Review::create([
                'booking_id' => $booking->id,
                'user_id' => Auth::id(),
                'room_id' => $booking->room_id,
                'rating' => $request->rating,
                'comment' => $request->comment ?? 'Không có nhận xét.',
            ]);

            return response()->json([
                'status' => true,
                'message' => 'Cảm ơn bạn đã đánh giá!',
                'data' => $review
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'status' => false,
                'message' => 'Lỗi khi tạo đánh giá.',
                'error' => $e->getMessage()
            ], 500);
        }
    }


    public function getReviewsByRoom($room_id)
    {
        // Lấy tất cả các đánh giá của phòng tương ứng
         $reviews = Review::where('room_id', $room_id)->paginate(3); // mỗi trang 3 đánh giá

        // Kiểm tra nếu không có đánh giá nào
        if ($reviews->isEmpty()) {
            return response()->json([
                'status' => false,
                'message' => 'Không có đánh giá nào cho phòng này.'
            ], 404);
        }

        // Trả về danh sách đánh giá
        return response()->json([
            'status' => true,
            'message' => 'Danh sách đánh giá cho phòng ' . $room_id,
            'data' => $reviews
        ], 200);
    }

    public function index(): JsonResponse
    {
        try {
            // Lấy tất cả reviews từ bảng reviews
            $reviews = Review::all();

            if ($reviews->isEmpty()) {
                return response()->json([
                    'status' => true,  // Chỉ báo thành công dù không có dữ liệu
                    'message' => 'Không có review nào.',
                    'data' => []
                ], 200);  // Trả về mã 200 khi không có dữ liệu
            }

            return response()->json([
                'status' => true,
                'message' => 'Danh sách review.',
                'data' => $reviews
            ], 200);  // Trả về mã 200 khi thành công

        } catch (\Exception $e) {
            return response()->json([ // Trả về mã lỗi nếu có lỗi hệ thống
                'status' => false,
                'message' => 'Đã xảy ra lỗi khi lấy danh sách review.',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
