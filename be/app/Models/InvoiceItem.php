<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class InvoiceItem extends Model
{
    use HasFactory;
    public $timestamps = false; 
    
    public function invoice()
    {
        return $this->belongsTo(Invoice::class);
    }

    protected $fillable = [
        'invoice_id',
        'description',
        'amount',
        'quantity',
        'total_amount',
    ];
}
