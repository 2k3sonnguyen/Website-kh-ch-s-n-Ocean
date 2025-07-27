<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Payment extends Model
{
    use HasFactory;
    use SoftDeletes;
    public $timestamps = false;
    protected $dates = ['deleted_at'];

    protected $fillable = [
        'booking_id',
        'amount',
        'method',
        'status',
        'payment_date',
        'momo_order_id'
    ];
}
