<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Contact;
use Illuminate\Support\Facades\Log;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Support\Facades\Mail;
use Exception;

class ContactController extends Controller
{
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name'    => 'required|string|max:255',
            'email'   => 'required|email',
            'phone'   => 'required|string|max:20',
            'message' => 'required|string',
        ]);

        $contact = Contact::create($validated);

        return response()->json([
            'message' => 'Liên hệ đã được lưu thành công.',
            'data'    => $contact
        ], 201);
    }

    public function index()
    {
        try {
            // Lấy tất cả các liên hệ
            $contacts = Contact::all();

            if ($contacts->isEmpty()) {
                return response()->json([
                    'status' => false,
                    'message' => 'Không có liên hệ nào.',
                    'data' => []
                ], 404);
            }

            return response()->json([
                'status' => true,
                'message' => 'Danh sách liên hệ.',
                'data' => $contacts
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'status' => false,
                'message' => 'Đã xảy ra lỗi khi lấy danh sách liên hệ.',
                'error' => $e->getMessage()
            ], 500);  // Trả về mã 500 nếu có lỗi hệ thống
        }
    }

    public function reply(Request $request, $id)
    {
        $request->validate([
            'message' => 'required|string',
        ]);

        try {
            $contact = Contact::findOrFail($id);

            if (empty($contact->email) || !filter_var($contact->email, FILTER_VALIDATE_EMAIL)) {
                return response()->json([
                    'status' => false,
                    'message' => 'Email người gửi không hợp lệ. Không thể gửi phản hồi.',
                ], 400);
            }

            // 3. Gửi email phản hồi
            try {
                Mail::send('emails.contact_reply', [
                    'name' => $contact->name,
                    'replyMessage' => $request->message
                ], function ($mail) use ($contact) {
                    $mail->to($contact->email)
                        ->subject('Phản hồi liên hệ từ Khách sạn Ocean');
                });
            } catch (Exception $e) {
                Log::error('Lỗi khi gửi email phản hồi: ' . $e->getMessage());

                return response()->json([
                    'status' => false,
                    'message' => 'Không thể gửi email phản hồi. Vui lòng kiểm tra cấu hình email hoặc địa chỉ email người nhận.',
                    'error' => $e->getMessage()
                ], 500);
            }

            // Lưu trạng thái đã trả lời
            $contact->replied = true;
            $contact->save();

            return response()->json([
                'status' => true,
                'message' => 'Đã gửi email phản hồi thành công.',
            ]);

        } catch (ModelNotFoundException $e) {
            return response()->json([
                'status' => false,
                'message' => 'Không tìm thấy liên hệ cần phản hồi.',
            ], 404);

        } catch (Exception $e) {
            Log::error('Lỗi khi xử lý phản hồi: ' . $e->getMessage());

            return response()->json([
                'status' => false,
                'message' => 'Đã xảy ra lỗi khi phản hồi liên hệ.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    public function destroy($id)
    {
        try {
            $contact = Contact::findOrFail($id);

            // Xoá mềm 
            $contact->delete();

            return response()->json([
                'status' => true,
                'message' => 'Liên hệ đã được xóa.',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => false,
                'message' => 'Không thể xóa liên hệ.',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
