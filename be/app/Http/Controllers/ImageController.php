<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Image;

class ImageController extends Controller
{
    public function showByObject($object_type, $object_id)
    {
        $images = Image::where('object_type', $object_type)
                        ->where('object_id', $object_id)
                        ->get();

        if ($images->isEmpty()) {
            return response()->json([
                'status' => false,
                'message' => 'Không tìm thấy ảnh.'
            ], 404);
        }

        // Gắn thêm URL đầy đủ
        $images->transform(function ($item) {
            $item->full_url = url($item->image_url);
            return $item;
        });

        return response()->json([
            'status' => true,
            'data' => $images
        ]);
    }
}
