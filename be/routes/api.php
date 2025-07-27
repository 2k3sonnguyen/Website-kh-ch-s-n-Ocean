<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\AdminAuthController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\RoomController;
use App\Http\Controllers\BookingController;
use App\Http\Controllers\PaymentController;
use App\Http\Controllers\InvoiceController;
use App\Http\Controllers\ServiceController;
use App\Http\Controllers\ServiceOrderController;
use App\Http\Controllers\DiscountController;
use App\Http\Controllers\ReviewController;
use App\Http\Controllers\ImageController;
use App\Http\Controllers\FaqController;
use App\Http\Controllers\ChatbotController;
use App\Http\Controllers\ContactController;
use App\Http\Controllers\StatisticsController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

// 
Route::post('/auth/register', [AuthController::class, 'register']);
Route::post('/auth/login', [AuthController::class, 'login']);
Route::middleware('auth:sanctum')->get('/user/profile', [AuthController::class, 'profile']);
Route::post('/admin/login', [AdminAuthController::class, 'login']);


//User
Route::get('/admin/users', [UserController::class, 'index']);
Route::middleware('auth:sanctum')->get('/profile', [UserController::class, 'getProfile']);
Route::middleware('auth:sanctum')->put('/profile', [UserController::class, 'updateProfile']);
Route::put('/users/{id}', [UserController::class, 'update']);// admin
Route::delete('/users/{id}', [UserController::class, 'destroy']);// admin

// ROOM
Route::get('/rooms', [RoomController::class, 'index']); // admin, user
Route::post('/rooms', [RoomController::class, 'store']); // admin
Route::get('/rooms/{id}', [RoomController::class, 'show']);
Route::get('/room-types', [RoomController::class, 'getRoomTypes']);
Route::get('/rooms/type/{type}', [RoomController::class, 'getRoomsByType']);
Route::post('/check-available-rooms', [RoomController::class, 'checkAvailable']);
Route::post('/rooms/{id}', [RoomController::class, 'update']); // admin
Route::delete('/rooms/{id}', [RoomController::class, 'destroy']); // admin 

// Booking
Route::post('/bookings', [BookingController::class, 'store']);
Route::middleware('auth:sanctum')->get('/bookings/user', [BookingController::class, 'userBookings']);
Route::middleware('auth:sanctum')->delete('/bookings/{id}', [BookingController::class, 'destroy']);
Route::post('/bookings/check-availability', [BookingController::class, 'checkAvailability']);
Route::get('/bookings', [BookingController::class, 'getAllBookings']); // admin
Route::put('/bookings/{id}', [BookingController::class, 'update']); // admin
Route::delete('/bookings/{id}', [BookingController::class, 'deleteBooking']);// admin


//Payment
Route::post('/payments', [PaymentController::class, 'createPayment']);
Route::get('/payment/callback', [PaymentController::class, 'callback'])->name('payment.callback');
Route::post('/payment/ipn', [PaymentController::class, 'handleIpn'])->name('payment.ipn');
Route::get('/payments', [PaymentController::class, 'index']);// admin
Route::put('/payments/{id}', [PaymentController::class, 'update']); // admin

// Invoice
Route::get('/invoices', [InvoiceController::class, 'index']);// admin
Route::get('/invoices/{id}', [InvoiceController::class, 'show']);// admin

// Service
Route::get('/services', [ServiceController::class, 'index']);
Route::middleware('auth:sanctum')->post('/service-orders', [ServiceController::class, 'store']);
Route::get('/service-orders/booking/{booking_id}', [ServiceController::class, 'getByBookingId']);
Route::post('/services', [ServiceController::class, 'storee']);
Route::post('/services/{id}', [ServiceController::class, 'update']);
Route::delete('/services/{id}', [ServiceController::class, 'destroy']);

// Service_Order
Route::get('/service-orders', [ServiceOrderController::class, 'index']);
Route::get('/service-order/{orderId}', [ServiceOrderController::class, 'getServiceOrderDetails']);

// Discount
Route::get('/discounts', [DiscountController::class, 'index']);// user, admin
Route::post('/discounts/apply', [DiscountController::class, 'apply']);
Route::post('/discounts', [DiscountController::class, 'store']);// admin
Route::put('/discounts/{id}', [DiscountController::class, 'update']);// admin
Route::delete('/discounts/{id}', [DiscountController::class, 'destroy']);// admin

// Review
Route::middleware('auth:sanctum')->post('/reviews', [ReviewController::class, 'store']);
Route::get('/reviews/room/{room_id}', [ReviewController::class, 'getReviewsByRoom']);
Route::get('/reviews', [ReviewController::class, 'index']);// admin

// Images
Route::get('/images/{object_type}/{object_id}', [ImageController::class, 'showByObject']);

//FAQ
Route::get('/faqs', [FaqController::class, 'index']);
Route::post('/faqs', [FaqController::class, 'store']);
Route::put('faqs/{id}', [FaqController::class, 'update']);
Route::delete('faqs/{id}', [FaqController::class, 'destroy']);

// Chatbot
Route::post('/chat', [ChatbotController::class, 'handleChat']);
Route::post('/conversations', [ChatbotController::class, 'createConversation']);
Route::get('/conversations/{id}', [ChatbotController::class, 'getConversation']);

// Contact
Route::post('/contacts', [ContactController::class, 'store']);
Route::get('/contacts', [ContactController::class, 'index']); // admin
Route::post('/contacts/{id}/reply', [ContactController::class, 'reply']);// admin
Route::delete('/contacts/{id}', [ContactController::class, 'destroy']);// admin

// Execl
Route::get('/statistics/export-revenue', [StatisticsController::class, 'exportRevenueExcel']);
Route::get('/statistics/export-booking', [StatisticsController::class, 'exportBookingExcel']);
Route::get('/statistics/export-feedback', [StatisticsController::class, 'exportFeedbackExcel']);
