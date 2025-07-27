<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;
use App\Models\User;

class UserController extends Controller
{
    public function index()
    {
        // Lấy tất cả user, sắp xếp theo id tăng dần
        $users = User::orderBy('id', 'asc')->get();

        return response()->json([
            'status' => 'success',
            'data' => $users
        ]);
    }

    public function update(Request $request, $id)
    {
        // Tìm người dùng cần cập nhật
        $user = User::find($id);

        if (!$user) {
            return response()->json([
                'status' => false,
                'message' => 'Người dùng không tồn tại.'
            ], 404);
        }

        // Cập nhật các trường thông tin nếu có
        if ($request->has('name')) {
            $user->name = $request->input('name');
        }
        if ($request->has('email')) {
            $user->email = $request->input('email');
        }
        if ($request->has('phone')) {
            $user->phone = $request->input('phone');
        }
        if ($request->has('password')) {
            $user->password = Hash::make($request->input('password'));
        }

        // Cập nhật thủ công trường updated_at
        $user->updated_at = now();  // Cập nhật thủ công thời gian hiện tại

        // Lưu thông tin người dùng sau khi cập nhật
        $user->save();

        return response()->json([
            'status' => true,
            'message' => 'Cập nhật thông tin người dùng thành công.',
            'data' => $user
        ], 200);
    }

    public function destroy($id)
    {
        // Tìm người dùng theo ID
        $user = User::find($id);

        // Kiểm tra nếu người dùng không tồn tại
        if (!$user) {
            return response()->json([
                'status' => false,
                'message' => 'Người dùng không tồn tại.'
            ], 404);
        }

        // Xóa người dùng
        $user->delete();

        return response()->json([
            'status' => true,
            'message' => 'Người dùng đã được xóa thành công.'
        ], 200);
    }

    public function getProfile(Request $request)
    {
        return response()->json([
            'status' => true,
            'message' => 'Lấy thông tin người dùng thành công',
            'data' => $request->user()
        ]);
    }

    public function updateProfile(Request $request)
    {
        $user = $request->user();

        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'email' => ['sometimes', 'required', 'email', Rule::unique('users')->ignore($user->id)],
            'phone' => ['sometimes', 'required', 'regex:/^0[0-9]{9}$/', Rule::unique('users')->ignore($user->id)],
            'current_password' => 'nullable|required_with:new_password|string',
            'new_password' => 'nullable|required_with:current_password|string|min:6|confirmed',
        ]);

        // Cập nhật thông tin cơ bản
        if (isset($validated['name'])) $user->name = $validated['name'];
        if (isset($validated['email'])) $user->email = $validated['email'];
        if (isset($validated['phone'])) $user->phone = $validated['phone'];

        // Cập nhật mật khẩu nếu có
        if (!empty($validated['current_password']) && !empty($validated['new_password'])) {
            if (!Hash::check($validated['current_password'], $user->password)) {
                return response()->json([
                    'status' => false,
                    'message' => 'Mật khẩu hiện tại không đúng.'
                ], 422);
            }

            $user->password = Hash::make($validated['new_password']);
        }

        $user->save();

        return response()->json([
            'status' => true,
            'message' => 'Cập nhật hồ sơ thành công',
            'data' => $user
        ]);
    }
}
