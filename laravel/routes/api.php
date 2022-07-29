<?php

use App\Http\Controllers\Api\AffiliateController;
use App\Http\Controllers\Api\AlertController;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\UserController;
use App\Http\Controllers\Api\EquipmentTypeController;
use App\Http\Controllers\Api\EquipmentController;
use App\Http\Controllers\Api\ConsumptionController;
use App\Http\Controllers\Api\DivisionController;
use App\Http\Controllers\Api\ObservationController;
use App\Http\Controllers\Api\StatisticController;
use App\Http\Controllers\Api\TrainingExampleController;
use App\Http\Controllers\Auth\VerificationController;

//Auth
Route::post('login', [AuthController::class, 'login']); //checked
Route::post('refresh', [AuthController::class, 'refresh']); //checked

//User
Route::post('users', [UserController::class, 'postUser']); //checked

Route::middleware(['auth:api'])->group(function () {

    //Email
    //Route::get('email/verify/{id}/{hash}', [VerificationController::class, 'verify'])->name('verification.verify');
    //Route::post('email/resend', [VerificationController::class, 'resend'])->name('verification.resend');

    //Auth
    Route::post('logout', [AuthController::class, 'logout']); //checked

    //User
    Route::get('users', [UserController::class, 'getUsers'])->middleware('can:viewAny,App\Models\User'); //checked
    Route::get('user', [UserController::class, 'getAuthUser']);
    Route::get('users/{user}', [UserController::class, 'getUser'])->middleware('can:view,user');
    Route::put('users/{user}', [UserController::class, 'putUser'])->middleware('can:update,user');
    Route::patch('users/{user}/password', [UserController::class, 'patchUserPassword'])->middleware('can:update,user');
    Route::patch('users/{user}/password/reset', [UserController::class, 'patchUserPasswordReset'])->middleware('can:updatePasswordReset,user');
    Route::patch('users/{user}/price', [UserController::class, 'patchUserEnergyPrice'])->middleware('can:update,user');
    Route::patch('users/{user}/status', [UserController::class, 'patchGetStarted'])->middleware('can:update,user');
    Route::patch('users/{user}/notifications', [UserController::class, 'patchUserNotifications'])->middleware('can:update,user');
    Route::patch('users/{user}/locked', [UserController::class, 'patchUserLocked'])->middleware('can:updateLocked,user');
    Route::delete('users/{user}', [UserController::class, 'deleteUser'])->middleware('can:delete,user');
    Route::get('users/{user}/stats', [UserController::class, 'getUserStats'])->middleware('can:update,user');
    Route::get('users/{user}/notifications', [UserController::class, 'getNotifications'])->middleware('can:update,user');

    //Affiliate
    Route::get('users/{user}/affiliates', [AffiliateController::class, 'getUserAffiliates'])->middleware('can:view,user');
    Route::get('users/{user}/affiliates/my', [AffiliateController::class, 'getUserAffiliatesMy'])->middleware('can:view,user');
    Route::post('users/{user}/affiliates', [AffiliateController::class, 'postUserAffiliate'])->middleware('can:view,user');
    Route::delete('users/{user}/affiliates/{affiliate}', [AffiliateController::class, 'deleteUserAffiliate'])->middleware('can:view,user');

    //Observations
    Route::get('users/{user}/observations', [ObservationController::class, 'getUserObservations'])->middleware('can:viewAny,App\Models\Observation,user');
    Route::get('users/{user}/observations/last', [ObservationController::class, 'getUserLastObservation'])->middleware('can:viewLast,App\Models\Observation,user');
    Route::get('users/{user}/observations/{observation}', [ObservationController::class, 'getUserObservation'])->middleware('can:view,observation,user');
    Route::post('users/{user}/observations', [ObservationController::class, 'postUserObservation'])->middleware('can:create,App\Models\Observation,user');
    Route::delete('users/{user}/observations/{observation}', [ObservationController::class, 'deleteUserObservation'])->middleware('can:delete,observation,user');


    //Consumptions
    Route::get('users/{user}/consumptions', [ConsumptionController::class, 'getUserConsumptions'])->middleware('can:viewAny,App\Models\Consumption,user');
    Route::get('users/{user}/consumptions/data', [ConsumptionController::class, 'getUserConsumptionsData'])->middleware('can:viewAny,App\Models\Consumption,user');
    Route::get('users/{user}/consumptions/{consumption}', [ConsumptionController::class, 'getUserConsumption'])->middleware('can:view,consumption,user');
    Route::post('users/{user}/consumptions', [ConsumptionController::class, 'postUserConsumption'])->middleware('can:create,App\Models\Consumption,user');
    Route::delete('users/{user}/consumptions/{consumption}', [ConsumptionController::class, 'deleteUserConsumption'])->middleware('can:delete,consumption,user');

    //Equipment
    Route::get('users/{user}/equipments', [EquipmentController::class, 'getUserEquipments'])->middleware('can:viewAny,App\Models\Equipment,user');
    Route::get('users/{user}/equipments/{equipment}', [EquipmentController::class, 'getUserEquipment'])->middleware('can:view,equipment,user');
    Route::post('users/{user}/equipments', [EquipmentController::class, 'postUserEquipment'])->middleware('can:create,App\Models\Equipment,user');
    Route::put('users/{user}/equipments/{equipment}', [EquipmentController::class, 'putUserEquipment'])->middleware('can:update,equipment,user');
    Route::delete('users/{user}/equipments/{equipment}', [EquipmentController::class, 'deleteUserEquipment'])->middleware('can:delete,equipment,user');
    Route::patch('users/{user}/equipments/{equipment}', [EquipmentController::class, 'patchNotifications'])->middleware('can:delete,equipment,user');


    //EquipmentType
    Route::get('equipment-types', [EquipmentTypeController::class, 'getEquipmentTypes'])->middleware('can:viewAny,App\Models\EquipmentType');
    Route::get('equipment-types/{type}', [EquipmentTypeController::class, 'getEquipmentType'])->middleware('can:view,type');
    Route::post('equipment-types', [EquipmentTypeController::class, 'postEquipmentType'])->middleware('can:create,App\Models\EquipmentType');
    Route::put('equipment-types/{type}', [EquipmentTypeController::class, 'putEquipmentType'])->middleware('can:update,type');
    Route::delete('equipment-types/{type}', [EquipmentTypeController::class, 'deleteEquipmentType'])->middleware('can:delete,type');

    //Division
    Route::get('users/{user}/divisions', [DivisionController::class, 'getUserDivisions'])->middleware('can:viewAny,App\Models\Division,user');
    Route::get('users/{user}/divisions/{division}', [DivisionController::class, 'getUserDivision'])->middleware('can:view,division,user');
    Route::post('users/{user}/divisions', [DivisionController::class, 'postUserDivision'])->middleware('can:create,App\Models\Division,user');
    Route::put('users/{user}/divisions/{division}', [DivisionController::class, 'putUserDivision'])->middleware('can:update,division,user');
    Route::delete('users/{user}/divisions/{division}', [DivisionController::class, 'deleteUserDivision'])->middleware('can:delete,division,user');

    //Alert
    Route::get('users/{user}/alerts', [AlertController::class, 'getUserAlerts'])->middleware('can:viewAny,App\Models\Alert,user');
    Route::get('users/{user}/alerts/{alert}', [AlertController::class, 'getUserAlert'])->middleware('can:view,alert,user');
    Route::post('users/{user}/alerts', [AlertController::class, 'postUserAlert'])->middleware('can:create,App\Models\Alert,user');
    Route::put('users/{user}/alerts/{alert}', [AlertController::class, 'putUserAlert'])->middleware('can:update,alert,user');
    Route::delete('users/{user}/alerts/{alert}', [AlertController::class, 'deleteUserAlert'])->middleware('can:delete,alert,user');

    //TrainingExample
    Route::get('users/{user}/training-examples', [TrainingExampleController::class, 'getUserTrainingExamples'])->middleware('can:viewAny,App\Models\TrainingExample,user');
    Route::post('users/{user}/training-examples', [TrainingExampleController::class, 'postUserTrainingExample'])->middleware('can:create,App\Models\TrainingExample,user');

    //Statistic
    Route::get('users/{user}/statistics/kwh', [StatisticController::class, 'getUserEnergyStatistics']);
    Route::get('statistics', [StatisticController::class, 'getAdminStatistics']);
    Route::get('statistics/users', [StatisticController::class, 'getAdminUsersStatistics']);

});
