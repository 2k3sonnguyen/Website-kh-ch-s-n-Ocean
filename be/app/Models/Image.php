<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Image extends Model
{
    use HasFactory;
    protected $table = 'images';
    public $timestamps = false;
    protected $fillable = [
        'object_type', 'object_id', 'image_url'
    ];
}
