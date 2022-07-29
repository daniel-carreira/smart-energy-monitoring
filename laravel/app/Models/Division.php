<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Division extends Model
{
    use HasFactory, SoftDeletes;

    public $timestamps = true;

    protected $fillable = [
        'name',
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id', 'id');
    }

    public function equipments()
    {
        return $this->hasMany(Equipment::class, 'division_id', 'id');
    }

    public function observations()
    {
        return $this->hasMany(Observation::class, 'divisions_observations', 'division_id', 'observation_id');
    }
}
