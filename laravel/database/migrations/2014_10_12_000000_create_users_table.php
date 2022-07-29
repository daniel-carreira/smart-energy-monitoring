<?php

use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class CreateUsersTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('name', 255);
            $table->string('email', 255);
            $table->string('password', 255);
            $table->timestamp('birthdate');
            $table->integer('get_started')->default(0)->nullable();;
            $table->unsignedTinyInteger('notifications')->default(0)->nullable();;
            $table->unsignedTinyInteger('locked')->default(0);
            $table->timestamp('no_activity_start')->default(new Carbon('22:00:00'))->nullable();;
            $table->timestamp('no_activity_end')->default(new Carbon('07:00:00'))->nullable();;
            $table->timestamp('email_verified_at')->nullable();
            $table->string('type', 1)->default('C');
            $table->decimal('energy_price', 5, 4, true)->default(0.151)->nullable();;
            $table->timestamps();
            $table->softDeletes();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('users');
    }
}
