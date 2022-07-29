<?php

namespace App\Models;

use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Passport\HasApiTokens;
use \Illuminate\Database\Eloquent\SoftDeletes;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, SoftDeletes;
    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'name',
        'email'
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var array<int, string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'email_verified_at' => 'datetime',
    ];

    public function trainingExamples()
    {
        return $this->hasMany(TrainingExample::class, 'user_id', 'id');
    }

    public function consumptions()
    {
        return $this->hasMany(Consumption::class, 'user_id', 'id');
    }

    public function divisions()
    {
        return $this->hasMany(Division::class, 'user_id', 'id');
    }

    public function alerts()
    {
        return $this->hasMany(Alert::class, 'user_id', 'id');
    }

    public function observations()
    {
        return $this->hasMany(Observation::class, 'user_id', 'id');
    }

    public function equipments()
    {
        return $this->hasMany(Equipment::class, 'user_id', 'id');
    }

    public function affiliates()
    {
        return $this->belongsToMany(User::class, 'users_affiliates', 'affiliate_id', 'user_id');
    }
}
