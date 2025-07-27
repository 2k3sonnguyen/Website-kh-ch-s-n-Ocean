<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class ServiceOrder extends Model
{
    use HasFactory;
    use SoftDeletes;
    public $timestamps = false;
    protected $dates = ['deleted_at'];

    protected $fillable = [
        'booking_id',
        'service_id',
        'quantity',
        'total_price',
        'order_date',
    ];

    public function service()
    {
        return $this->belongsTo(Service::class, 'service_id');
    }
}
