<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class ConsumptionPost extends FormRequest
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
            'consumptions' => 'required|array',
            'consumptions.*.value' => 'required|numeric',
            'consumptions.*.variance' => 'required|numeric',
            'consumptions.*.timestamp' => 'required|integer'
        ];
    }

    public function messages()
    {
        return [
            'consumptions.*.value.required' => 'Value is mandatory',
            'consumptions.*.value.numeric' => 'Value must be a number',
            'consumptions.*.variance.required' => 'Variance is mandatory',
            'consumptions.*.variance.numeric' => 'Variance must be a number',
            'consumptions.*.timestamp.required' => 'Timestamp is mandatory',
            'consumptions.*.timestamp.integer' => 'Timestamp must be a integer',
        ];
    }
}
