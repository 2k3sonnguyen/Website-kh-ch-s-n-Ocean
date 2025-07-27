<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Booking extends Model
{
    use HasFactory, SoftDeletes;
    public $timestamps = false;

    protected $fillable = [
        'user_id',
        'room_id',
        'check_in',
        'check_out',
        'total_price',
        'status',
        'discount_code',
        'discount_percent',
    ];

    protected $dates = ['check_in', 'check_out', 'deleted_at'];

    /**
     * Quan hệ với bảng payments
     */
    public function payments(): HasMany
    {
        return $this->hasMany(Payment::class)->withTrashed();
    }

    /**
     * Quan hệ với bảng service_orders
     */
    public function serviceOrders(): HasMany
    {
        return $this->hasMany(ServiceOrder::class)->withTrashed();
    }

    /**
     * Quan hệ với bảng invoices
     */
    public function invoices(): HasMany
    {
        return $this->hasMany(Invoice::class)->withTrashed();
    }

    /**
     * Khi xóa Booking, xóa mềm các bản ghi liên quan
     */
    protected static function booted(): void
    {
        static::deleting(function ($booking) {
            $now = now();
            $booking->payments()->update(['deleted_at' => $now]);
            $booking->serviceOrders()->update(['deleted_at' => $now]);
            $booking->invoices()->update(['deleted_at' => $now]);
        });
    }
}
