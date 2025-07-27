<?php

namespace App\Http\Controllers;

use App\Models\Faq;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class FaqController extends Controller
{
    public function index()
    {
        try {
            // Lấy tất cả các câu hỏi thường gặp
            $faqs = Faq::all();

            if ($faqs->isEmpty()) {
                return response()->json([
                    'status' => false,
                    'message' => 'Không có câu hỏi thường gặp nào.',
                    'data' => []
                ], 404);
            }

            return response()->json([
                'status' => true,
                'message' => 'Danh sách câu hỏi thường gặp.',
                'data' => $faqs
            ], 200);  // Trả về mã 200 nếu thành công

        } catch (\Exception $e) {
            return response()->json([
                'status' => false,
                'message' => 'Đã xảy ra lỗi khi lấy danh sách câu hỏi thường gặp.',
                'error' => $e->getMessage()
            ], 500);  // Trả về mã 500 nếu có lỗi hệ thống
        }
    }

    public function store(Request $request)
{
    Log::info("Received Request Data", $request->all());  // Thêm log để xem request dữ liệu

    $request->validate([
        'question' => 'required|string|max:255',
        'answer' => 'required|string',
        'category' => 'nullable|string|max:255',  // Cho phép category là null
    ]);

    try {
        $faq = Faq::create([
            'question' => $request->question,
            'answer' => $request->answer,
            'category' => $request->category,  // Lưu category
        ]);

        Log::info("FAQ Created Successfully", ['faq' => $faq]);  // Log thông tin đã được tạo thành công

        return response()->json([
            'status' => true,
            'message' => 'Câu hỏi đã được thêm thành công.',
            'data' => $faq
        ], 201);
    } catch (\Exception $e) {
        Log::error("Error Creating FAQ", ['error' => $e->getMessage()]);
        return response()->json([
            'status' => false,
            'message' => 'Đã xảy ra lỗi khi thêm câu hỏi.',
            'error' => $e->getMessage()
        ], 500);
    }
}

    public function update(Request $request, $id)
    {
        $faq = Faq::find($id);

        if (!$faq) {
            return response()->json([
                'status' => false,
                'message' => 'Câu hỏi không tồn tại.'
            ], 404);
        }

        $request->validate([
            'question' => 'required|string|max:255',
            'answer' => 'required|string',
            'category' => 'nullable|string|max:255',
        ]);

        try {
            $faq->update([
                'question' => $request->question,
                'answer' => $request->answer,
                'category' => $request->category,
            ]);

            return response()->json([
                'status' => true,
                'message' => 'Câu hỏi đã được cập nhật thành công.',
                'data' => $faq
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'status' => false,
                'message' => 'Đã xảy ra lỗi khi cập nhật câu hỏi.',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function destroy($id)
    {
        $faq = Faq::find($id);

        if (!$faq) {
            return response()->json([
                'status' => false,
                'message' => 'Câu hỏi không tồn tại.'
            ], 404);
        }

        try {
            $faq->delete();

            return response()->json([
                'status' => true,
                'message' => 'Câu hỏi đã được xóa thành công.'
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'status' => false,
                'message' => 'Đã xảy ra lỗi khi xóa câu hỏi.',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
