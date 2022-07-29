<?php

namespace App\Policies;

use App\Models\User;
use App\Models\TrainingExample;
use Illuminate\Support\Facades\Auth;
use Illuminate\Auth\Access\HandlesAuthorization;

class TrainingExamplePolicy
{
    use HandlesAuthorization;

    /**
     * Determine whether the user can view any models.
     *
     * @param  \App\Models\User  $user
     * @param  \App\Models\User  $model
     * @return \Illuminate\Auth\Access\Response|bool
     */
    public function viewAny(User $user, User $model)
    {
        return $user->type === 'P' || ($user->id === $model->id);
    }

    /**
     * Determine whether the user can create models.
     *
     * @param  \App\Models\User  $user
     * @param  \App\Models\User  $model
     * @return \Illuminate\Auth\Access\Response|bool
     */
    public function create(User $user, User $model)
    {
        return $user->type === 'P' || ($user->id === $model->id);
    }
}
