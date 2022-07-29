<?php

namespace App\Policies;

use App\Models\Alert;
use App\Models\User;
use Illuminate\Auth\Access\HandlesAuthorization;
use Illuminate\Support\Facades\Auth;

class AlertPolicy
{
    use HandlesAuthorization;

    /**
     * Determine whether the user can view any models.
     *
     * @param  \App\Models\User  $user
     * @return \Illuminate\Auth\Access\Response|bool
     */
    public function viewAny(User $user, User $model)
    {
        $isAffiliate = false;
        foreach ($model->affiliates as $affiliate) {
            if ($user->id === $affiliate->id) {
                $isAffiliate = true;
                break;
            }
        }
        return $model->id === $user->id || $isAffiliate;
    }

    /**
     * Determine whether the user can view the model.
     *
     * @param  \App\Models\User  $user
     * @param  \App\Models\Alert  $alert
     * @return \Illuminate\Auth\Access\Response|bool
     */
    public function view(User $user, Alert $alert, User $model)
    {
        $isAffiliate = false;
        foreach ($model->affiliates as $affiliate) {
            if ($user->id === $affiliate->id) {
                $isAffiliate = true;
                break;
            }
        }
        return ($model->id === $user->id && $user->id === $alert->user_id) || $isAffiliate;
    }

    /**
     * Determine whether the user can create models.
     *
     * @param  \App\Models\User  $user
     * @return \Illuminate\Auth\Access\Response|bool
     */
    public function create(User $user, User $model)
    {
        return $user->type === 'P' || $user->type === 'A';
    }

    /**
     * Determine whether the user can update the model.
     *
     * @param  \App\Models\User  $user
     * @param  \App\Models\Alert  $alert
     * @return \Illuminate\Auth\Access\Response|bool
     */
    public function update(User $user, Alert $alert, User $model)
    {
        return false;
    }

    /**
     * Determine whether the user can delete the model.
     *
     * @param  \App\Models\User  $user
     * @param  \App\Models\Alert  $alert
     * @return \Illuminate\Auth\Access\Response|bool
     */
    public function delete(User $user, Alert $alert, User $model)
    {
        return $model->id === $user->id && $user->id === $alert->user_id;
    }
}
