<?php

namespace App\Http\Controllers\Api;

use Exception;
use App\Models\EquipmentType;
use App\Http\Requests\EquipmentTypePost;
use App\Http\Controllers\Controller;
use App\Http\Resources\EquipmentTypeResource;

class EquipmentTypeController extends Controller
{
    public function getEquipmentTypes()
    {
        return EquipmentTypeResource::collection(EquipmentType::all());
    }

    public function getEquipmentType(EquipmentType $type)
    {
        return new EquipmentTypeResource($type);
    }

    public function postEquipmentType(EquipmentTypePost $request)
    {
        $type = new EquipmentType();
        $type->fill($request->validated());

        try {
            $type->save();
        } catch (Exception $e) {
            return response(['error' => 'Something went wrong when creating the equipment type'], 500);
        }

        return new EquipmentTypeResource($type);
    }

    public function putEquipmentType(EquipmentTypePost $request, EquipmentType $type)
    {
        $validated_data = $request->validated();
        $type->fill($validated_data);

        try {
            $type->save();
        } catch (Exception $e) {
            return response(['error' => 'Something went wrong when changing the equipment type'], 500);
        }

        return new EquipmentTypeResource($type);
    }

    public function deleteEquipmentType(EquipmentType $type)
    {
        try {
            $type->delete();
        } catch (Exception $e) {
            return response(['error' => 'Something went wrong when deleting the equipment type'], 500);
        }

        return new EquipmentTypeResource($type);
    }
}
