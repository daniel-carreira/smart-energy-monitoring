<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class EquipmentResource extends JsonResource
{
    static bool $detail = false;
    /**
     * Transform the resource into an array.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return array|\Illuminate\Contracts\Support\Arrayable|\JsonSerializable
     */
    public function toArray($request)
    {
        if (EquipmentResource::$detail)
            return [
                "id" => $this->id,
                "user_id" => $this->user_id,
                "name" => $this->name,
                "division" => $this->division_id,
                "division_name" => $this->division ? $this->division->name : null,
                "type" => $this->type ? $this->type->id : -1,
                "type_name" => $this->type ? $this->type->name : 'N/A',
                "consumption" => $this->pivot ? $this->pivot->consumptions : $this->consumption,
                "activity" => $this->activity,
                "equipment_type_id" => $this->equipment_type_id,
                "examples" => $this->examples,
                "init_status_on" => $this->init_status_on,
                "notify_when_passed" => $this->notify_when_passed
            ];
        else
            return [
                "id" => $this->id,
                "name" => $this->name,
                "consumption" => $this->pivot ? $this->pivot->consumptions : $this->consumption,
                "type" => $this->type ? $this->type->name : 'N/A',
                "activity" => $this->activity,
                "division" => $this->division ? $this->division->name : "N/A",
            ];
    }
}
