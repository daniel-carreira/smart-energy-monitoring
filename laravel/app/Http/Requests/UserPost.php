<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UserPost extends FormRequest
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

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array
     */
    public function rules()
    {
        return [
            'name' => 'required|string|max:255',
            'email' => 'required|unique:users|string|email',
            'password' => 'required|string|max:255',
            'birthdate' => ['required', 'regex:/^([0-2][0-9]|(3)[0-1])(\/)(((0)[0-9])|((1)[0-2]))(\/)\d{4}$/'],
            'type' => 'nullable|string|max:1'
        ];
    }

    public function messages()
    {
        return [
            'name.required' => 'Name is mandatory',
            'name.max' => 'Name cannot have more than 255 characters',
            'name.string' => 'Name must be a string',
            'email.required' => 'Email is mandatory',
            'email.email' => 'Email is not valid',
            'password.required' => 'Password is mandatory',
            'password.max' => 'Password cannot have more than 255 characters',
            'birthdate.required' => 'Birthdate is mandatory',
            'birthdate.regex' => 'Birthdate date is not valid',
        ];
    }
}
