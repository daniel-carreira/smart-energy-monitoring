<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class EquipmentType extends Model
{
    use HasFactory, SoftDeletes;

    protected $table = "equipment_types";

    protected $fillable = [
        'name',
        'activity'
    ];

    public $timestamps = true;
}
