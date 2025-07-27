<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Service extends Model
{
    use HasFactory;
    use SoftDeletes;
    
    public $timestamps = false;

    protected $fillable = ['name', 'price', 'description'];

    public function serviceOrders()
    {
        return $this->hasMany(ServiceOrder::class);
    }
}
