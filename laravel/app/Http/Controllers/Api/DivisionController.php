<?php

namespace App\Http\Controllers\Api;

use Exception;
use App\Models\User;
use App\Models\Division;
use Illuminate\Http\Request;
use App\Http\Requests\DivisionPost;
use App\Http\Controllers\Controller;
use App\Http\Resources\DivisionResource;
use Illuminate\Validation\ValidationException;

class DivisionController extends Controller
{
    public function getUserDivisions(User $user)
    {
        return DivisionResource::collection($user->divisions);
    }

    public function getUserDivision(User $user, Division $division)
    {
        return new DivisionResource($division);
    }

    public function postUserDivision(DivisionPost $request, User $user)
    {
        $division = new Division();
        $division->fill($request->validated());
        $division->user_id = $user->id;

        try {
            $division->save();
        } catch (Exception $e) {
            return response(['error' => 'Something went wrong when creating the division'], 500);
        }

        if ($user->get_started == 0) {
            $user->get_started = 1;
            $user->save();
        }

        return new DivisionResource($division);
    }

    public function putUserDivision(DivisionPost $request, User $user, Division $division)
    {
        $division->fill($request->validated());
        try {
            $division->save();
        } catch (Exception $e) {
            return response(['error' => 'Something went wrong when changing the division'], 500);
        }
        return new DivisionResource($division);
    }

    public function deleteUserDivision(User $user, Division $division)
    {

        try {
            if ($division->equipments()->count() == 0)
                $division->delete();
            else
                return response(['error' => 'Division has equipments associated!'], 400);
        } catch (Exception $e) {
            return response(['error' => 'Something went wrong when deleting the division'], 500);
        }

        if ($user->get_started == 1 && $user->divisions()->count() == 0) {
            $user->get_started = 0;
            $user->save();
        }

        return new DivisionResource($division);
    }
}
