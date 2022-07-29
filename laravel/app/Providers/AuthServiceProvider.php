<?php

namespace App\Providers;

use App\Models\User;
use App\Models\Alert;
use App\Models\Division;
use App\Models\Equipment;
use App\Models\Consumption;
use App\Models\Observation;
use App\Policies\UserPolicy;
use App\Models\EquipmentType;
use App\Policies\AlertPolicy;
use Laravel\Passport\Passport;
use App\Models\TrainingExample;
use App\Policies\DivisionPolicy;
use App\Policies\EquipmentPolicy;
use App\Policies\ConsumptionPolicy;
use App\Policies\ObservationPolicy;
use App\Policies\EquipmentTypePolicy;
use App\Policies\TrainingExamplePolicy;
use Illuminate\Foundation\Support\Providers\AuthServiceProvider as ServiceProvider;

class AuthServiceProvider extends ServiceProvider
{
    /**
     * The policy mappings for the application.
     *
     * @var array<class-string, class-string>
     */
    protected $policies = [
        User::class => UserPolicy::class,
        EquipmentType::class => EquipmentTypePolicy::class,
        Consumption::class => ConsumptionPolicy::class,
        Division::class => DivisionPolicy::class,
        Equipment::class => EquipmentPolicy::class,
        Observation::class => ObservationPolicy::class,
        TrainingExample::class => TrainingExamplePolicy::class,
        Alert::class => AlertPolicy::class
    ];

    /**
     * Register any authentication / authorization services.
     *
     * @return void
     */
    public function boot()
    {
        $this->registerPolicies();

        if (!$this->app->routesAreCached()) {
            Passport::routes();
        }
    }
}
