<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class ObservationPost extends FormRequest
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
            'consumption_id' => 'required|integer',
            'expected_divisions' => 'nullable|array',
            'activity' => 'nullable|string|max:3',
            'equipments' => 'nullable|array',
            'consumptions' => 'nullable|array'
        ];
    }

    public function messages()
    {
        return [
            'consumption_id.required' => 'Consumption id is mandatory',
            'consumption_id.integer' => 'consumption id must be a number',
            'expected_division.array' => 'Expected divisions must be an array',
            'activity.string' => 'Expected division must be a string',
            'activity.max' => 'Expected division cannot have more than 3 characters',
        ];
    }
}
