<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use \Illuminate\Database\Eloquent\SoftDeletes;

class Observation extends Model
{
    use HasFactory;
    use SoftDeletes;


    protected $fillable = [
        'consumption_id',
        'expected_division',
        'activity'
    ];

    public $timestamps = true;


    public function user()
    {
        return $this->belongsTo(User::class, 'user_id', 'id');
    }

    public function consumption()
    {
        return $this->belongsTo(Consumption::class, 'consumption_id', 'id');
    }

    public function equipments()
    {
        return $this->belongsToMany(Equipment::class, 'equipments_observations', 'observation_id', 'equipment_id')->withPivot('consumptions');
    }

    public function divisions()
    {
        return $this->belongsToMany(Division::class, 'divisions_observations', 'observation_id', 'division_id');
    }

    public function alerts()
    {
        return $this->hasMany(Alert::class, 'observation_id', 'id');
    }
}
