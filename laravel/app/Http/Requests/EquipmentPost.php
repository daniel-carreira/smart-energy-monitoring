<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class EquipmentPost extends FormRequest
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
            'division_id' => 'required|integer',
            'equipment_type_id' => 'required|integer',
            'consumption' => 'required|numeric|min:0.01|max:9999.99',
            'activity' => 'required|string|max:3',
            'notify_when_passed' => 'nullable|integer|min:0'
        ];
    }

    public function messages()
    {
        return [
            'name.required' => 'Name is mandatory',
            'name.string' => 'Name must contain only letters',
            'name.max' => 'Name cannot have more than 255 characters',
            'division_id.required' => 'Division id is required',
            'division_id.integer' => 'Division id must be a number',
            'equipment_type_id.required' => 'Type is mandatory',
            'equipment_type_id.integer' => 'Type id must be a number',
            'consumption.required' => 'Consumption value is mandatory',
            'consumption.numeric' => 'Consumption must be a number',
            'consumption.min' => 'Consumption minimum value is 0.01',
            'consumption.max' => 'Consumption maximum value is 9999.99',
            'activity.required' => 'Activity is mandatory',
            'activity.string' => 'Activity must contain only letters',
            'activity.max' => 'Activity cannot have more than 3 characters',
        ];
    }
}
