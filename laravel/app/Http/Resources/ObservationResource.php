<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class ObservationResource extends JsonResource
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
        EquipmentResource::$detail = false;

        if (ObservationResource::$detail)
            return [
                "id" => $this->id,
                "user_id" => $this->user_id,
                "consumption_id" => $this->consumption_id,
                "expected_divisions" => DivisionResource::collection($this->divisions),
                "created_at" => strtotime($this->created_at),
                "equipments" => EquipmentResource::collection($this->equipments)
            ];
        else
            return [
                "id" => $this->id,
                "user_id" => $this->user_id,
                "consumption_id" => $this->consumption_id,
                "expected_divisions" => DivisionResource::collection($this->divisions)
            ];
    }
}
