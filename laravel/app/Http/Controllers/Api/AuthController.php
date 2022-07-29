<?php

namespace App\Http\Controllers\api;

use App\Models\User;
use Illuminate\Support\Str;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Auth;


class AuthController extends Controller
{
    public function login(Request $request)
    {
        try {
            $bodyHttpRequest = [
                'form_params' => [
                    'grant_type' => 'password',
                    'client_id' => env('CLIENT_ID'),
                    'client_secret' => env('CLIENT_SECRET'),
                    'username' => $request->username,
                    'password' => $request->password,
                    'scope' => ''
                ],
                'exceptions' => false,
            ];
            $url = env("URL") . '/oauth/token';
            $http = new \GuzzleHttp\Client;
            $response = $http->post($url, $bodyHttpRequest);
            $user = User::where('email', '=', $request->username)->firstOrFail();
            if($user->locked == 1){
                return response(
                    ['block' => 'User is blocked'], 401);
            }
            if($user->deleted_at!=null){
                return response(
                    ['exist' => 'User does not exist'], 401);
            }
            $errorCode = $response->getStatusCode();
            if ($errorCode == '200') {
                return json_decode((string) $response->getBody(), true);
            } else {
                return response(['error' => 'User credentials are invalid'], $errorCode);
            }
        } catch (\GuzzleHttp\Exception\BadResponseException $e) {
            if ($e->getCode() === 400) {
                if ($request->username == null) {
                    return response(['username' => 'Username is mandatory'], 400);
                }
                if ($request->password == null) {
                    return response(['password' => 'Password is mandatory'], 400);
                }
                return response(['error' => 'The credentials are invalid'], 400);
            } else if ($e->getCode() === 401) {
                return response(['error' => 'The credentials are invalid'], 401);
            }
            return response(['error' => 'Something went wrong with the server'], $e->getCode());
        }
    }

    public function logout(Request $request)
    {
        $accessToken = $request->user()->token();
        $token = $request->user()->tokens->find($accessToken);
        $token->revoke();
        $token->delete();
        return response(['msg' => 'Token revoked']);
    }

    public function refresh(Request $request)
    {
        $http = new \GuzzleHttp\Client;

        $url = env("URL") . '/oauth/token';
        $response = $http->post($url, [
            'form_params' => [
                'grant_type' => 'refresh_token',
                'refresh_token' => $request->refresh_token,
                'client_id' => env('CLIENT_ID'),
                'client_secret' => env('CLIENT_SECRET'),
                'scope' => '',
            ],
        ]);

        return json_decode((string) $response->getBody(), true);
    }
}
