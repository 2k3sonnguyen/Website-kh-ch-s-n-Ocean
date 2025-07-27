<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Invoice extends Model
{
    use HasFactory;
    use SoftDeletes;
    public $timestamps = false; 
    protected $fillable = ['booking_id', 'total_amount', 'status'];
    protected $dates = ['deleted_at'];

    public function items()
    {
        return $this->hasMany(InvoiceItem::class);
    }

    public function booking()
    {
        return $this->belongsTo(Booking::class);
    }
}
