<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Review extends Model
{
    use HasFactory;
    public $timestamps = false;
    protected $fillable = [
        'booking_id', 'user_id', 'room_id', 'rating', 'comment'
    ];
    
}
