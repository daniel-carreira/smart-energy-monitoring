<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UserPatch extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     *
     * @return bool
     */
    public function authorize()
    {
        return true;
    }
    public function rules()
    {
        return [
            'oldPassword' => 'required|string|max:255',
            'newPassword' => 'required|string|max:255',
        ];
    }

    public function messages()
    {
        return [
            'oldPassword.required' => 'Password is mandatory',
            'oldPassword.max' => 'Password cannot have more than 255 characters',
            'newPassword.required' => 'Password is mandatory',
            'newPassword.max' => 'Password cannot have more than 255 characters',
        ];
    }
}
