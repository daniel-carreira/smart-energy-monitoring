<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateTables extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('divisions', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id');
            $table->foreign('user_id')->references('id')->on('users');
            $table->string('name', 255);
            $table->timestamps();
            $table->softDeletes();
        });

        Schema::create('consumptions', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id');
            $table->foreign('user_id')->references('id')->on('users');
            $table->decimal('value', 10, 2);
            $table->decimal('variance', 10, 2);
            $table->unsignedBigInteger('observation_id');
            $table->timestamp('timestamp');
            $table->timestamps();
            $table->softDeletes();
        });

        Schema::create('observations', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id');
            $table->foreign('user_id')->references('id')->on('users');
            $table->unsignedBigInteger('consumption_id');
            $table->foreign('consumption_id')->references('id')->on('consumptions');
            $table->timestamps();
            $table->softDeletes();
        });

        Schema::create('equipment_types', function (Blueprint $table) {
            $table->id();
            $table->string('name', 255);
            $table->string('activity', 3)->nullable();
            $table->timestamps();
            $table->softDeletes();
        });

        Schema::create('equipments', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id');
            $table->foreign('user_id')->references('id')->on('users');
            $table->unsignedBigInteger('equipment_type_id');
            $table->foreign('equipment_type_id')->references('id')->on('equipment_types');
            $table->string('name', 255);
            $table->unsignedBigInteger('division_id');
            $table->foreign('division_id')->references('id')->on('divisions');
            $table->decimal('consumption', 6, 2);
            $table->string('activity', 3);
            $table->unsignedBigInteger('examples')->default(0);
            $table->timestamp('init_status_on')->nullable();
            $table->unsignedBigInteger('notify_when_passed')->nullable();
            $table->unsignedBigInteger('notifications')->default(0);
            $table->timestamps();
            $table->softDeletes();
        });

        Schema::create('alerts', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id');
            $table->foreign('user_id')->references('id')->on('users');
            $table->string('alert', 255);
            $table->timestamps();
            $table->softDeletes();
        });

        Schema::table('consumptions', function ($table) {
            $table->unsignedBigInteger('observation_id')->nullable()->change();
            $table->foreign('observation_id')->references('id')->on('observations');
        });

        Schema::create('equipments_observations', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('observation_id');
            $table->foreign('observation_id')->references('id')->on('observations');
            $table->unsignedBigInteger('equipment_id');
            $table->foreign('equipment_id')->references('id')->on('equipments');
            $table->decimal('consumptions', 6, 2);
            $table->softDeletes();
        });

        Schema::create('divisions_observations', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('observation_id');
            $table->foreign('observation_id')->references('id')->on('observations');
            $table->unsignedBigInteger('division_id');
            $table->foreign('division_id')->references('id')->on('divisions');
            $table->softDeletes();
        });

        Schema::create('users_affiliates', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id');
            $table->foreign('user_id')->references('id')->on('users');
            $table->unsignedBigInteger('affiliate_id');
            $table->foreign('affiliate_id')->references('id')->on('users');
            $table->softDeletes();
        });

        Schema::create('training_examples', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id');
            $table->timestamp('time');
            $table->decimal('consumption', 10, 2);
            $table->decimal('consumption_variance', 10, 2);
            $table->string('day_week', 10);
            $table->string('weekend', 3);
            $table->string('season', 10);
            $table->unsignedBigInteger('equipment_id');
            $table->decimal('equipment_consumption', 10, 2);
            $table->string('equipment_division', 255);
            $table->string('equipment_type', 255);
            $table->string('equipment_activity', 3);
            $table->string('equipment_status', 3);
            $table->timestamps();
        });
    }



    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('consumptions');
        Schema::dropIfExists('observations');
        Schema::dropIfExists('equipments');
        Schema::dropIfExists('divisions');
        Schema::dropIfExists('equipment_types');
        Schema::dropIfExists('alerts');
        Schema::dropIfExists('training_examples');
        Schema::dropIfExists('equipments_observations');
    }
}
