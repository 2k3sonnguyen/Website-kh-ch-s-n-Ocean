<?php

namespace App\Http\Controllers;

use App\Models\Room;
use App\Models\Image;
use Illuminate\Support\Facades\Storage;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

use Exception;

class RoomController extends Controller
{
    public function index(): JsonResponse
    {
        try {
            // Sắp xếp theo cột 'id' giảm dần 
            $rooms = Room::orderBy('id', 'desc')->get();

            if ($rooms->isEmpty()) {
                return response()->json([
                    'status'  => false,
                    'message' => 'Không có phòng nào được tìm thấy.',
                    'data'    => []
                ], 200);
            }

            return response()->json([
                'status'  => true,
                'message' => 'Lấy danh sách phòng thành công.',
                'data'    => $rooms
            ], 200);

        } catch (Exception $e) {
            return response()->json([
                'status'  => false,
                'message' => 'Đã xảy ra lỗi khi lấy danh sách phòng.',
                'error'   => $e->getMessage()
            ], 500);
        }
    }

    public function show($id):JsonResponse
    {
        $room = Room::find($id);
        if (!$room) {
            return response()->json([
                'status' => false,
                'message' => 'Không tìm thấy phòng'
            ], 200);
        }
        return response()->json([
            'status' => true,
            'data' => $room
        ], 200);
    }
    
    public function getRoomTypes(): JsonResponse
    {
        try {
            $roomTypes = DB::table('rooms')
                ->select('room_type')
                ->distinct()
                ->orderBy('room_type')
                ->get();

            return response()->json([
                'status' => true,
                'message' => 'Lấy danh sách loại phòng thành công.',
                'data' => $roomTypes
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => false,
                'message' => 'Đã xảy ra lỗi khi lấy loại phòng.',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function getRoomsByType($type): JsonResponse
    {
        try {
            $rooms = Room::where('room_type', $type)->orderBy('room_number', 'asc')->get();

            if ($rooms->isEmpty()) {
                return response()->json([
                    'status' => false,
                    'message' => 'Không có phòng nào thuộc loại này.',
                    'data' => []
                ], 200);
            }

            return response()->json([
                'status' => true,
                'message' => 'Lấy danh sách phòng theo loại thành công.',
                'data' => $rooms
            ], 200);

        } catch (Exception $e) {
            return response()->json([
                'status' => false,
                'message' => 'Lỗi khi lấy phòng theo loại.',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function checkAvailable(Request $request)
    {
        $request->validate([
            'check_in' => 'required|date',
            'check_out' => 'required|date|after:check_in',
            'guests' => 'required|integer|min:1',
        ]);

        $checkIn = $request->check_in;
        $checkOut = $request->check_out;
        $guests = $request->guests;

        $bookedRoomIds = DB::table('bookings')
            ->where(function ($query) use ($checkIn, $checkOut) {
                $query->whereBetween('check_in', [$checkIn, $checkOut])
                    ->orWhereBetween('check_out', [$checkIn, $checkOut])
                    ->orWhere(function($q) use ($checkIn, $checkOut) {
                        $q->where('check_in', '<', $checkIn)
                            ->where('check_out', '>', $checkOut);
                    });
            })
            ->pluck('room_id');

        $room = DB::table('rooms')
            ->where('status', 'available')
            ->where('capacity', '>=', $guests) 
            ->whereNotIn('id', $bookedRoomIds)
            ->first();

        if ($room) {
            return response()->json([
                'status' => 'success',
                'room' => $room
            ]);
        } else {
            return response()->json([
                'status' => 'no_room'
            ]);
        }
    }

    public function store(Request $request)
    {
        $duplicate = Room::where('room_number', $request->room_number)->exists();

        if ($duplicate) {
            return response()->json([
                'status' => false,
                'message' => 'Phòng đã tồn tại!',
            ], 400);
        }
        
        $request->validate([
            'room_number'  => 'required|string|unique:rooms,room_number',
            'room_type'    => 'required|string',
            'price'        => 'required|numeric|min:0',
            'status'       => 'required|in:available,booked,maintenance',
            'capacity'     => 'required|integer|min:1',
            'description'  => 'nullable|string',
            'images'       => 'required|array',
            'images.*'     => 'mimes:jpeg,png,jpg,gif,svg|max:10000',
        ]);

        $room = Room::create($request->only([
            'room_number', 'room_type', 'price', 'status', 'capacity', 'description'
        ]));

        foreach ($request->file('images') as $file) {
            if ($file->isValid()) {
                // Lấy tên gốc
                $originalName = $file->getClientOriginalName();

                // Đường dẫn đích: public/uploads/rooms
                $destination = public_path('uploads/rooms');

                // Tạo thư mục nếu chưa có
                if (!is_dir($destination)) {
                    mkdir($destination, 0755, true);
                }

                // Di chuyển file từ temp sang public
                $file->move($destination, $originalName);

                // Đường dẫn để lưu vào DB
                $imageUrl = '/uploads/rooms/' . $originalName;
                $fullUrl = $imageUrl; // do file nằm public

                Image::create([
                    'object_type' => 'room',
                    'object_id'   => $room->id,
                    'image_url'   => $imageUrl,
                    'full_url'    => $fullUrl,
                ]);
            }
        }

        return response()->json([
            'message' => 'Thêm phòng thành công',
            'data'    => $room
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $room = Room::findOrFail($id);

        // Kiểm tra nếu room_number đã tồn tại ở phòng khác
        $duplicate = Room::where('room_number', $request->room_number)
                        ->where('id', '!=', $room->id)
                        ->exists();

        if ($duplicate) {
            return response()->json([
                'status' => false,
                'message' => 'Phòng đã tồn tại!'
            ], 400);
        }

        $room->update($request->only(['room_number', 'room_type', 'price', 'status', 'capacity', 'description']));

        if ($request->hasFile('images')) {
            $img = Image::where('object_type', 'room')
                        ->where('object_id', $room->id)
                        ->first();

            if ($img) {
                Storage::disk('public')->delete(ltrim($img->image_url, '/'));
            }

            $file = $request->file('images')[0];
            if ($file->isValid()) {
                $name = $file->getClientOriginalName();
                $dest = public_path('uploads/rooms');
                if (!is_dir($dest)) mkdir($dest, 0755, true);
                $file->move($dest, $name);

                $url = '/uploads/rooms/' . $name;

                if ($img) {
                    $img->update(['image_url' => $url, 'full_url' => $url]);
                } else {
                    Image::create([
                        'object_type' => 'room',
                        'object_id'   => $room->id,
                        'image_url'   => $url,
                        'full_url'    => $url,
                    ]);
                }
            }
        }

        return response()->json(['message' => 'Cập nhật phòng thành công', 'data' => $room], 200);
    }

    public function destroy($id)
    {
        $room = Room::find($id);
        if (!$room) {
            return response()->json(['message' => 'Không tìm thấy phòng'], 404);
        }

        $room->delete(); // Soft delete, chỉ cập nhật deleted_at

        return response()->json(['message' => 'Phòng đã được soft delete'], 200);
    }
}
