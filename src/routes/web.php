<?php

use App\Jobs\ProcessSomething;
use Illuminate\Support\Facades\Redis;
use Illuminate\Support\Facades\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "web" middleware group. Make something great!
|
*/

Route::get('/', function () {
    return view('welcome');
});

Route::get('/redis-test', function (Request $request) {
    try{
        $redis = Redis::connect('redis', 6379);
        return response('Redis is working');
    } catch (Exception $e) { 
        return response('error connection redis' . print_r($e, true));
    }
});

Route::get('/add-job', function () {
    ProcessSomething::dispatch('hello world');
    return response('Job added to queue ' . date("Y-m-d H:i:s"));
});