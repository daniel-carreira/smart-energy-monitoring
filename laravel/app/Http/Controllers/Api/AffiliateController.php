<?php

namespace App\Http\Controllers\Api;

use App\Models\User;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Http\Requests\AffiliatePost;
use App\Http\Resources\UserResource;
use Illuminate\Support\Facades\DB;
use Exception;

class AffiliateController extends Controller
{
    public function getUserAffiliates(User $user)
    {
        $array = [];

        $affiliatesIds = DB::table('users_affiliates')->where('user_id', $user->id)->pluck('affiliate_id');

        foreach ($affiliatesIds as $affiliateId) {
            $affiliate = User::find($affiliateId);
            $item = new \stdClass();

            $item->id = $affiliate->id;
            $item->name = $affiliate->name;
            $item->email = $affiliate->email;
            $item->energy_price = $affiliate->energy_price;

            array_push($array, $item);
        }

        return $array;
    }

    public function getUserAffiliatesMy(User $user)
    {
        $array = [];

        foreach ($user->affiliates as $affiliate) {
            $item = new \stdClass();

            $item->id = $affiliate->id;
            $item->name = $affiliate->name;
            $item->email = $affiliate->email;
            $item->energy_price = $affiliate->energy_price;

            array_push($array, $item);
        }

        return $array;
    }

    public function postUserAffiliate(AffiliatePost $request, User $user)
    {
        if ($request->email == $user->email) {
            return response(['errors' => ['email' => ['Affiliate e-mail is equal to yours']]], 400);
        }

        $affiliate = User::where('email', $request->email)->first();
        if ($affiliate == null) {
            return response(['errors' => ['email' => ['Affiliate e-mail does not exist']]], 404);
        }

        $alreadyAffiliated = false;
        foreach ($user->affiliates as $affiliated) {
            if ($affiliated->id == $affiliate->id) {
                $alreadyAffiliated = true;
                break;
            }
        }

        if ($alreadyAffiliated) {
            return response(['errors' => ['email' => ['Affiliate e-mail is already affiliated']]], 400);
        }
        $user->affiliates()->attach($affiliate->id);

        return new UserResource($affiliate);
    }

    public function deleteUserAffiliate(User $user,  User $affiliate)
    {
        try {
            $user->affiliates()->detach($affiliate->id);
        } catch (Exception $e) {
            return response(['errors' => ['email' => ['That user is not your affiliate']]], 500);
        }
    }
}
