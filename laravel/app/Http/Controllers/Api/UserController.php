<?php

namespace App\Http\Controllers\Api;

use \DateTime;
use Exception;
use App\Models\User;
use Illuminate\Http\Request;
use App\Http\Requests\UserPut;
use App\Http\Requests\UserPost;
use App\Models\TrainingExample;
use App\Http\Requests\UserPatch;
use App\Http\Controllers\Controller;
use App\Http\Resources\UserResource;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use App\Http\Resources\EquipmentResource;
use App\Mail\PasswordResetMail;
use Illuminate\Validation\ValidationException;

class UserController extends Controller
{

    public function getAuthUser()
    {
        return Auth::user();
    }

    public function getUsers(Request $request)
    {
        $hasType = $request->query('type') != null;
        $type = $request->query('type');

        if (!$hasType) {
            return UserResource::collection(User::all());
        }

        $users = User::where('type', $type)->get();
        return UserResource::collection($users);
    }

    public function getUser(User $user)
    {
        return new UserResource($user);
    }

    public function postUser(UserPost $request)
    {
        $type = $request->type;
        if ($type == null) {
            $type = 'C';
        }
        if ($type != 'C' && (auth('api')->check() == 0 || auth('api')->user()->type != 'A')) {
            return response(['message' => 'This action is unauthorized.'], 403);
        }

        $user = new User();
        $user->fill($request->validated());
        $user->type = $type;
        $user->password = Hash::make($request->password);
        $user->birthdate = DateTime::createFromFormat('!d/m/Y', $request->birthdate);

        try {
            $user->save();

            //$newUser = User::where('email', $user->email)->first();
            //$newUser->sendEmailVerificationNotification();
        } catch (Exception $e) {
            return response(['error' => 'Something went wrong when creating the user'], 500);
        }
        return new UserResource($user);
    }

    public function putUser(UserPut $request, User $user)
    {
        $user->name = $request->name;
        $user->birthdate = DateTime::createFromFormat('!d/m/Y', $request->birthdate);
        if ($user->type == 'C') {
            $user->energy_price = $request["energy_price"];
            $user->no_activity_start = date("Y-m-d H:i:s", $request["no_activity_start"]);
            $user->no_activity_end = date("Y-m-d H:i:s", $request["no_activity_end"]);
            $user->notifications = $request["notifications"];
        }
        try {
            $user->save();
        } catch (Exception $e) {
            return response(['error' => 'Something went wrong when changing the user'], 500);
        }
        return new UserResource($user);
    }

    public function patchUserPassword(UserPatch $request, User $user)
    {
        $request->validated();
        if (!password_verify($request->oldPassword, $user->password)) {
            return response(['error' => 'Password is incorrect'], 400);
        }
        $user->password = Hash::make($request->newPassword);
        try {
            $user->save();
        } catch (Exception $e) {
            return response(['error' => 'Something went wrong when changing the user'], 500);
        }
        return new UserResource($user);
    }

    public function patchUserPasswordReset(Request $request, User $user)
    {
        $generatedPassword = $this->randomPassword();
        $user->password = Hash::make($generatedPassword);
        try {
            $user->save();

            Mail::to($user->email)->send(new PasswordResetMail($generatedPassword));
        } catch (Exception $e) {
            return response(['error' => 'Something went wrong when changing the user'], 500);
        }
        return new UserResource($user);
    }

    private function randomPassword()
    {
        $alphabet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
        $pass = array(); //remember to declare $pass as an array
        $alphaLength = strlen($alphabet) - 1; //put the length -1 in cache
        for ($i = 0; $i < 12; $i++) {
            $n = rand(0, $alphaLength);
            $pass[] = $alphabet[$n];
        }
        return implode($pass); //turn the array into a string
    }

    public function patchUserEnergyPrice(Request $request, User $user)
    {
        if ($request["energy_price"] && is_numeric($request["energy_price"])) {
            $user->energy_price = $request["energy_price"];
            try {
                $user->save();
            } catch (Exception $e) {
                return response(['error' => 'Something went wrong when changing the energy price'], 500);
            }
        }
        return response(['error' => 'Energy price is not in a valid format'], 400);
    }

    public function patchUserNotifications(User $user)
    {
        $user->notifications = !$user->notifications;
        try {
            $user->save();
        } catch (Exception $e) {
            return $e;
        }
        return $user->notifications == 0 ? 'OFF' : 'ON';
    }

    public function patchUserLocked(User $user)
    {
        $user->locked = !$user->locked;
        try {
            $user->save();
        } catch (Exception $e) {
            return $e;
        }
        return $user->locked == 0 ? 'Unlocked' : 'Locked';
    }

    public function deleteUser(User $user)
    {
        try {
            $user->delete();
        } catch (Exception $e) {
            return response(['error' => 'Something went wrong when deleting the user'], 500);
        }
        return new UserResource($user);
    }

    public function patchGetStarted(Request $request, User $user)
    {
        if (is_numeric($request["get_started"])) {
            $user->get_started = $request["get_started"];
            try {
                $user->save();
                return $user->get_started;
            } catch (Exception $e) {
                return response(['error' => 'Something went wrong when changing get started status'], 500);
            }
        }
        return response(['error' => 'Get started is not in a valid format'], 400);
    }

    public function getUserStats(User $user)
    {
        $equipments = $user->equipments;
        $trainCount = [];
        foreach ($equipments as $equipment) {
            $item = new \stdClass();
            $item->id = $equipment->id;
            $item->equipment_name = $equipment->name;
            $item->count = $equipment->examples;
            array_push($trainCount, $item);
        }
        $stats = new \stdClass();
        $stats->divisions = $user->divisions()->count();
        $stats->equipments = $user->equipments()->count();
        $stats->training_examples = $trainCount;
        return $stats;
    }


    public function getNotifications(User $user)
    {
        return $user->notifications == 0 ? 'OFF' : 'ON';
    }
}
