<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class TrainingExampleResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return array|\Illuminate\Contracts\Support\Arrayable|\JsonSerializable
     */
    public function toArray($request)
    {
        return [
            "id" => $this->id,
            "consumption" => $this->consumption,
            "consumption_variance" => $this->consumption_variance,
            "time" => strtotime($this->time),
            "equipment_id" => $this->equipment_id,
            "equipment_type_id" => $this->equipment_type_id,
            "equipment_status" => $this->equipment_status,
        ];
    }
}
