<?php

namespace App\Http\Controllers\Api;

use DateTime;
use Exception;
use DateTimeZone;
use App\Models\User;
use App\Models\Consumption;
use App\Models\TrainingExample;
use App\Http\Controllers\Controller;
use App\Http\Requests\TrainingExamplePost;
use App\Http\Resources\TrainingExampleResource;

class TrainingExampleController extends Controller
{
    public function getUserTrainingExamples(User $user)
    {
        return TrainingExampleResource::collection($user->trainingExamples);
    }

    public function postUserTrainingExample(TrainingExamplePost $request, User $user)
    {

        $equipmentsON = !is_array($request->equipments_on) ? [] : $request->equipments_on;
        $count = 0;

        $consumptions = Consumption::where('user_id', $user->id)
            ->whereRaw('timestamp >= FROM_UNIXTIME(' . $request->start . ')')
            ->whereRaw('timestamp <= FROM_UNIXTIME(' . $request->end . ')')
            ->get();

        foreach ($consumptions as $consumption) {
            try {
                $this->storeExamplesFor($user, $consumption, $equipmentsON, $request->individual);
                $count++;
            } catch (Exception $e) {
                return response(['error' => 'Something went wrong when creating the training examples'], 500);
            }
        }

        if ($user->get_started == 2) {
            $getStartedFinished = true;
            foreach ($user->equipments() as $equipment) {
                if ($equipment->examples == 0) {
                    $getStartedFinished = false;
                    break;
                }
            }
            if ($getStartedFinished == true) {
                $user->get_started = 3;
                $user->save();
            }
        }


        return response(['msg' => $count . ' examples created with success'], 201);
    }

    private function getSeasonFrom($day_year)
    {
        if ($day_year < 79) return 'Winter';
        if ($day_year < 172) return 'Spring';
        if ($day_year < 266) return 'Summer';
        if ($day_year < 355) return 'Autumn';
        return 'Winter';
    }

    private function storeExamplesFor($user, $consumption, $equipmentsON, $individual = false)
    {
        foreach ($user->equipments as $equipment) {
            //CREATE ONE ROW FOR EACH EQUIPMENT
            $trainingExample = new TrainingExample();
            $equipmentStatusON = in_array($equipment->id, $equipmentsON);
            $trainingExample->user_id = $user->type == 'A' ? null : $user->id;
            $trainingExample->consumption = $consumption->value;
            $trainingExample->consumption_variance = $consumption->variance;
            $trainingExample->time = $consumption->created_at;
            $trainingExample->weekend = $consumption->created_at->format("w") == '0' || $consumption->created_at->format("w") == '6' ? "Yes" : "No";
            $trainingExample->day_week = $this->getDayWeekByInteger(intval($consumption->created_at->format("w")));
            $trainingExample->season = $this->getSeasonFrom(intval($consumption->created_at->format("z")) + 1);
            $trainingExample->equipment_id = $equipment->id;
            $trainingExample->equipment_consumption = $equipmentStatusON ? ($individual ? $consumption->value : $equipment->consumption) : 0;
            $trainingExample->equipment_division = $equipment->division->name;
            $trainingExample->equipment_type = $equipment->type ? $equipment->type->name : 'N/A';
            $trainingExample->equipment_activity = $equipment->activity;
            $trainingExample->equipment_status = $equipmentStatusON ? 'ON' : 'OFF';

            if ($equipmentStatusON) {
                $equipment->examples = $equipment->examples + 1;
                $equipment->save();
            }

            $trainingExample->save();
        }
    }

    private function getDayWeekByInteger($number)
    {
        switch ($number) {
            case 0:
                return "Sunday";
            case 1:
                return "Monday";
            case 2:
                return "Tuesday";
            case 3:
                return "Wednesday";
            case 4:
                return "Thursday";
            case 5:
                return "Friday";
            case 6:
                return "Saturday";
        }
    }
}
