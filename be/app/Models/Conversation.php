<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Conversation extends Model
{
    use HasFactory;
    public $timestamps = false;
    protected $fillable = ['user_id', 'start_time', 'status'];
}
