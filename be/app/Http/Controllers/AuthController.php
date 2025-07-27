<?php

namespace App\Http\Controllers;


use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        // Validate đầu vào
        $validator = Validator::make($request->all(), [
            'name'     => 'required|string|max:255',
            'email'    => 'required|email|unique:users,email',
            'password' => 'required|string|min:6|confirmed',
            'phone'    => 'required|string|max:20|unique:users,phone'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'succcess' => false,
                'message'  => 'Dữ liệu không hợp lệ',
                'errors'   => $validator->errors()
            ], 200);
        }

        // Tạo user
        $user = User::create([
            'name'     => $request->name,
            'email'    => $request->email,
            'phone'    => $request->phone,
            'password' => Hash::make($request->password),
        ]);

        $token = $user->createToken('authToken')->plainTextToken;

        return response()->json([
            'status'  => true,
            'message' => 'Đăng ký thành công',
            'data'    => $user,
            'token'   => $token
        ], 201);
    }


    public function login(Request $request)
    {
        $credentials = $request->only('email', 'password');

        // Tìm user theo email
        $user = User::where('email', $credentials['email'])->first();

        if (!$user || !Hash::check($credentials['password'], $user->password)) {
            return response()->json([
                'status' => false,
                'message' => 'Sai email hoặc mật khẩu'
            ], 200);
        }

        $token = $user->createToken('authToken')->plainTextToken;
        
        return response()->json([
            'status' => true,
            'message' => 'Đăng nhập thành công',
            'data' => $user,
            'token' => $token
        ]);
    }

    public function profile(Request $request)
    {
        return response()->json([
            'status' => true,
            'user' => $request->user() // lấy user hiện tại từ token
        ]);
    }
}
