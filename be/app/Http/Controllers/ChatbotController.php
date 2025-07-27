<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use App\Models\Faq;
use App\Models\Conversation;
use App\Models\Message;
use App\Models\HotelInfo; 

class ChatbotController extends Controller
{
    public function handleChat(Request $request)
    {
        $question = trim($request->input('message'));
        $userId = $request->input('user_id');
        $conversationId = $request->input('conversation_id');

        // 1. Tìm trong bảng FAQ
        $faq = Faq::where('question', 'ILIKE', "%$question%")->first(); // PostgreSQL: case-insensitive
        $answer = $faq?->answer;

        // 2. Nếu không có câu trả lời -> gọi GPT với hotel_info
        if (!$answer) {
            // Lấy thông tin khách sạn
            $hotelInfo = HotelInfo::pluck('value', 'key')->toArray();

            $infoText = "";
            foreach ($hotelInfo as $key => $value) {
                $label = ucwords(str_replace('_', ' ', $key));
                $infoText .= "- $label: $value\n";
            }

            $systemMessage = "Bạn là nhân viên lễ tân khách sạn Ocean. Trả lời khách một cách thân thiện, chính xác dựa trên thông tin sau:\n" . $infoText;

            $response = Http::withToken(env('OPENAI_API_KEY'))->post('https://api.openai.com/v1/chat/completions', [
                'model' => 'gpt-3.5-turbo',
                'messages' => [
                    ['role' => 'system', 'content' => $systemMessage],
                    ['role' => 'user', 'content' => $question],
                ],
                'temperature' => 0.7,
                'max_tokens' => 500
            ]);

            if ($response->successful()) {
                $answer = $response['choices'][0]['message']['content'] ?? 'Xin lỗi, tôi chưa biết trả lời.';
            } else {
                Log::error('GPT ERROR', ['response' => $response->body()]);
                $answer = 'Xin lỗi, tôi chưa thể trả lời câu hỏi đó.';
            }
        }

        // 3. Ghi hoặc lấy cuộc hội thoại
        $conversation = $conversationId
            ? Conversation::find($conversationId)
            : Conversation::create([
                'user_id' => $userId,
                'start_time' => now(),
                'status' => 'active'
            ]);

        // 4. Ghi 2 tin nhắn: user → bot
        Message::create([
            'conversation_id' => $conversation->id,
            'sender' => 'user',
            'message' => $question,
            'timestamp' => now(),
        ]);

        Message::create([
            'conversation_id' => $conversation->id,
            'sender' => 'bot',
            'message' => $answer,
            'timestamp' => now(),
        ]);

        return response()->json([
            'answer' => $answer,
            'conversation_id' => $conversation->id,
        ]);
    }
}
