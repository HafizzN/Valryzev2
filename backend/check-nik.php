<?php

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\User;

$users = User::orderBy('nik', 'desc')->limit(10)->get(['nik', 'name']);

echo "Current NIKs:\n";
foreach ($users as $user) {
    echo "- {$user->nik}: {$user->name}\n";
}

$maxNik = 0;
foreach (User::all() as $user) {
    $num = (int)preg_replace('/[^0-9]/', '', $user->nik);
    if ($num > $maxNik) {
        $maxNik = $num;
    }
}

echo "\nMax numeric part of NIK: $maxNik\n";
