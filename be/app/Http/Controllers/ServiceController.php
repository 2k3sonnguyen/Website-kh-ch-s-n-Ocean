<?php

namespace App\Http\Controllers;

use App\Models\Service;
use App\Models\ServiceOrder;
use Illuminate\Http\Request;
use App\Models\Image;

class ServiceController extends Controller
{
    // Lấy danh sách dịch vụ
    public function index()
    {
        try {
            $services = Service::all();
    
            if ($services->isEmpty()) {
                return response()->json([
                    'status' => false,
                    'message' => 'Không có dịch vụ nào được tìm thấy.',
                    'data' => []
                ], 404);
            }
    
            return response()->json([
                'status' => true,
                'message' => 'Danh sách dịch vụ.',
                'data' => $services
            ], 200);
    
        } catch (\Exception $e) {
            return response()->json([
                'status' => false,
                'message' => 'Đã xảy ra lỗi khi lấy danh sách dịch vụ.',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'booking_id' => 'required|exists:bookings,id',
            'services' => 'required|array',
            'services.*.service_id' => 'required|exists:services,id',
            'services.*.quantity' => 'required|integer|min:1',
        ]);

        $orders = [];

        try {
            foreach ($validated['services'] as $item) {
                // Lấy thông tin dịch vụ từ CSDL
                 $service = Service::findOrFail($item['service_id']);

                // Tính tổng tiền cho dịch vụ này
                $totalPrice = $service->price * $item['quantity'];

                // Tạo bản ghi service order
                $orders[] = ServiceOrder::create([
                    'booking_id' => $validated['booking_id'],
                    'service_id' => $item['service_id'],
                    'quantity' => $item['quantity'],
                    'total_price' => $totalPrice
                ]);
            }

            return response()->json([
                'status' => true,
                'message' => 'Đặt dịch vụ thành công',
                'data' => $orders
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'status' => false,
                'message' => 'Lỗi khi đặt dịch vụ',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function getByBookingId($booking_id){
        try{
            $orders = ServiceOrder::where('booking_id', $booking_id)->get();
            if ($orders->isEmpty()) {
                return response()->json([
                    'status' => false,
                    'message' => 'Không tìm thấy dịch vụ nào cho booking này.',
                    'data' => []
                ], 404);
            }

            return response()->json([
                'status' => true,
                'message' => 'Danh sách dịch vụ đã đặt',
                'data' => $orders
            ], 200);
        }catch (\Exception $e) {
            return response()->json([
                'status' => false,
                'message' => 'Đã xảy ra lỗi.',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function storee(Request $request)
    {
        $request->validate([
            'name'        => 'required|string|unique:services,name',
            'price'       => 'required|numeric|min:0',
            'description' => 'nullable|string',
            'images'      => 'required|array',
            'images.*'    => 'mimes:jpeg,png,jpg,gif,svg|max:10000',
        ]);

        $service = Service::create($request->only(['name', 'price', 'description']));

        foreach ($request->file('images') as $file) {
            if ($file->isValid()) {
                $originalName = $file->getClientOriginalName();
                $destination = public_path('uploads/services');

                if (!is_dir($destination)) {
                    mkdir($destination, 0755, true);
                }

                $file->move($destination, $originalName);

                $imageUrl = '/uploads/services/' . $originalName;

                Image::create([
                    'object_type' => 'service',
                    'object_id'   => $service->id,
                    'image_url'   => $imageUrl,
                    'full_url'    => $imageUrl,
                ]);
            }
        }

        return response()->json([
            'message' => 'Thêm dịch vụ thành công',
            'data'    => $service
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $service = Service::findOrFail($id);

        $request->validate([
            'name'        => 'sometimes|string|unique:services,name,' . $service->id,
            'price'       => 'sometimes|numeric|min:0',
            'description' => 'nullable|string',
            'images.*'    => 'mimes:jpeg,png,jpg,gif,svg|max:10000',
        ]);

        $service->update($request->only(['name', 'price', 'description']));

        // Nếu có ảnh mới được gửi lên thì mới xóa ảnh cũ và thêm ảnh mới
        if ($request->hasFile('images')) {
            // Xóa ảnh cũ
            $oldImages = Image::where('object_type', 'service')
                            ->where('object_id', $service->id)
                            ->get();

            foreach ($oldImages as $img) {
                if (file_exists(public_path($img->image_url))) {
                    unlink(public_path($img->image_url));
                }
                $img->delete();
            }

            // Thêm ảnh mới
            foreach ($request->file('images') as $file) {
                if ($file->isValid()) {
                    $originalName = time() . '_' . $file->getClientOriginalName(); // tránh trùng tên
                    $destination = public_path('uploads/services');

                    if (!is_dir($destination)) {
                        mkdir($destination, 0755, true);
                    }

                    $file->move($destination, $originalName);

                    $imageUrl = '/uploads/services/' . $originalName;

                    Image::create([
                        'object_type' => 'service',
                        'object_id'   => $service->id,
                        'image_url'   => $imageUrl,
                        'full_url'    => $imageUrl,
                    ]);
                }
            }
        }

        return response()->json([
            'message' => 'Cập nhật dịch vụ thành công',
            'data'    => $service
        ], 200);
    }

    public function destroy($id)
    {
        $service = Service::find($id);
        if (!$service) {
            return response()->json(['message' => 'Không tìm thấy dịch vụ'], 404);
        }

        $service->delete();

        return response()->json(['message' => 'Dịch vụ đã được xóa (soft delete)'], 200);
    }
}

