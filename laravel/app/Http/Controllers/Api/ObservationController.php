<?php

namespace App\Http\Controllers\Api;

use Exception;
use App\Models\User;
use App\Models\Alert;
use App\Models\Division;
use App\Models\Equipment;
use App\Models\Consumption;
use App\Models\Observation;
use Illuminate\Http\Request;
use App\Mail\AlertNotification;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Mail;
use App\Http\Requests\ObservationPost;
use App\Http\Resources\ConsumptionResource;
use App\Http\Resources\ObservationResource;


class ObservationController extends Controller
{
    public function getUserObservations(User $user, Request $request)
    {
        $response = [];
        $hasNoLimit = $request->query('limit') == null;
        $num = $request->query('limit');
        $consumptions = $hasNoLimit ? $user->observations : Consumption::where('user_id', $user->id)->whereNotNull('observation_id')->orderBy('created_at', 'desc')->limit($num)->get();
        foreach ($consumptions as $consumption) {

            ObservationResource::$detail = true;
            $item = new \stdClass();
            $item->observation = new ObservationResource($consumption->observation);
            $item->consumption = new ConsumptionResource($consumption);

            array_push($response, $item);
        }

        return response($response, 200);
    }

    public function getUserLastObservation(User $user)
    {
        $response = new \stdClass();
        $observation = Observation::where('user_id', $user->id)->orderBy('created_at', 'desc')->first();
        if ($observation == null)
            return response(null, 404);

        ObservationResource::$detail = true;
        $response->observation = new ObservationResource($observation);
        $response->consumption = new ConsumptionResource($observation->consumption);
        return $response;
    }

    public function getUserObservation(User $user, Observation $observation)
    {
        ObservationResource::$detail = true;
        return new ObservationResource($observation);
    }


    public function postUserObservation(ObservationPost $request, User $user)
    {
        $observation = new Observation();
        $observation->fill($request->validated());
        $observation->user_id = $user->id;

        $consumption = Consumption::find($request->consumption_id);
        if ($consumption == null) {
            return response(['error' => 'Consumption ' . $request->consumption_id . ' does not exist'], 404);
        }
        if ($consumption->observation_id != null) {
            $consumption->observation->delete();
        }

        try {
            $observation->save();
        } catch (Exception $e) {
            return response(['error' => 'Something went wrong when creating the observation'], 500);
        }

        $activeDivisions = [];
        foreach ($request->equipments as $key => $value) {
            $equipment = Equipment::find($value);
            if ($equipment == null) {
                return response(['error' => 'Equipment ' . $value . ' does not exist'], 404);
            }
            if ($equipment->user_id != $user->id) {
                return response(['error' => 'Equipment ' . $value . ' does not belongs to you'], 400);
            }

            $observation->equipments()->attach($equipment->id, ['consumptions' => $request->consumptions[$key]]);

            if ($request->consumptions[$key] > 0) {
                if (is_null($equipment->init_status_on)) {
                    $equipment->init_status_on = $consumption->timestamp;
                }

                //EQUIPMENT IS ON AND REQUIRE HUMAN INTERVENTION TO OPERATE
                if ($equipment->activity == "Yes") {

                    $noType1Sent = $equipment->notifications == 0 || $equipment->notifications == 2;
                    if ($noType1Sent) {
                        //NOTIFICATION TYPE 1 -> EQUIPMENT IS ON FOR LONGER THEN X TIME
                        $diffSeconds = strtotime($consumption->timestamp) - strtotime($equipment->init_status_on);
                        $diffMinutes = $diffSeconds / 60;
                        if (!is_null($equipment->notify_when_passed) && $diffMinutes > $equipment->notify_when_passed) {
                            //CREATE ALERT
                            $alert = new Alert();
                            $alert->alert = "The " . $equipment->name . " from the " . $equipment->division->name . " is already active for " . floor($diffMinutes) . " minutes. We recommend you to turn OFF this equipment if you are not using it.";
                            $alert->user_id = $user->id;
                            $alert->save();

                            if ($user->notifications) {
                                Mail::to($user->email)->send(new AlertNotification($user->name . ' warning of usage', $alert));

                                foreach ($user->affiliates as $affiliate) {
                                    Mail::to($affiliate->email)->send(new AlertNotification($user->name . ' warning of usage', $alert));
                                }
                            }
                            $equipment->notifications = $equipment->notifications + 1;
                        }
                    }

                    $noType2Sent = $equipment->notifications == 0 || $equipment->notifications == 1;
                    if ($noType2Sent) {
                        $start = strtotime($user->no_activity_start) % 86400;
                        $end = strtotime($user->no_activity_end) % 86400;
                        $time = strtotime($consumption->timestamp) % 86400;
                        if ($time > $start || $time < $end) {
                            //NOTIFICATION TYPE 2 -> EQUIPMENT IS ON WHILE USER ASLEEP
                            //CREATE ALERT
                            $alert = new Alert();
                            $alert->alert = "The " . $equipment->name . " from the " . $equipment->division->name . " is turned ON.";
                            $alert->user_id = $user->id;
                            $alert->save();

                            if ($user->notifications) {
                                Mail::to($user->email)->send(new AlertNotification($user->name . ' suspicious activity', $alert));

                                foreach ($user->affiliates as $affiliate) {
                                    Mail::to($affiliate->email)->send(new AlertNotification($user->name . ' suspicious activity', $alert));
                                }
                            }
                            $equipment->notifications = $equipment->notifications + 2;
                        }
                    }

                    //ADD DIVISION TO ACTIVE DIVISIONS
                    if (array_search($equipment->division_id, $activeDivisions) === false) {
                        array_push($activeDivisions, $equipment->division_id);
                    }
                }
            } else {
                $equipment->init_status_on = null;
                $equipment->notifications = 0;
            }
            $equipment->save();
        }

        if ($request->expected_divisions == null) {
            foreach ($activeDivisions as $value) {
                $observation->divisions()->attach($value);
            }
        } else {
            foreach ($request->expected_divisions as $value) {
                $division = Division::find($value);
                if ($division == null) {
                    return response(['error' => 'Division ' . $value . ' does not exist'], 404);
                }
                if ($division->user_id != $user->id) {
                    return response(['error' => 'Division ' . $value . ' does not belongs to you'], 400);
                }

                $observation->divisions()->attach($division->id);
            }
        }

        $consumption->observation_id = $observation->id;

        try {
            $observation->save();
            $consumption->save();
        } catch (Exception $e) {
            return response(['error' => 'Something went wrong when creating the observation'], 500);
        }

        ObservationResource::$detail = true;
        return new ObservationResource($observation);
    }

    public function putUserObservation(Request $request, User $user, Observation $observation)
    {
        $observation->fill($request->validated());
        try {
            $observation->save();
        } catch (Exception $e) {
            return response(['error' => 'Something went wrong when changing the observation'], 500);
        }
        ObservationResource::$detail = true;
        return new ObservationResource($observation);
    }

    public function deleteUserObservation(User $user, Observation $observation)
    {
        try {
            $observation->delete();
        } catch (Exception $e) {
            return response(['error' => 'Something went wrong when deleting the observation'], 500);
        }
        ObservationResource::$detail = true;
        return new ObservationResource($observation);
    }
}
