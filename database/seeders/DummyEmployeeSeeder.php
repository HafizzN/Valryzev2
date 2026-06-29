<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Division;
use App\Models\Position;
use App\Models\Shift;
use App\Models\OfficeLocation;
use App\Models\Attendance;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Spatie\Permission\Models\Role;
use Carbon\Carbon;

class DummyEmployeeSeeder extends Seeder
{
    public function run(): void
    {
        // ─── Tambah 300 Karyawan Baru ──────────────────────────────────
        $divisions = Division::all();
        $positions = Position::all();
        $shifts = Shift::all();
        $officeLocations = OfficeLocation::all();
        $karyawanRole = Role::where('name', 'karyawan')->first();

        $newEmployees = [];
        for ($i = 1; $i <= 300; $i++) {
            $division = $divisions->random();
            $position = $positions->where('division_id', $division->id)->isNotEmpty() 
                ? $positions->where('division_id', $division->id)->random() 
                : $positions->random();
            $shift = $shifts->random();
            $office = $officeLocations->random();
            
            $nik = 'KRY' . str_pad($i, 5, '0', STR_PAD_LEFT);
            
            $employee = User::create([
                'name'                 => fake()->name(),
                'email'                => fake()->unique()->safeEmail(),
                'password'             => Hash::make('password'),
                'nik'                  => $nik,
                'phone'                => fake()->phoneNumber(),
                'address'              => fake()->address(),
                'gender'               => rand(0, 1) ? 'male' : 'female',
                'birth_date'           => fake()->date('Y-m-d', '2005-01-01'),
                'birth_place'          => fake()->city(),
                'religion'             => fake()->randomElement(['islam', 'kristen', 'katolik', 'hindu', 'buddha', 'konghucu']),
                'marital_status'       => fake()->randomElement(['single', 'married', 'divorced', 'widowed']),
                'division_id'          => $division->id,
                'position_id'          => $position->id,
                'shift_id'             => $shift->id,
                'join_date'            => fake()->date('Y-m-d', '2024-01-01'),
                'employment_type'      => fake()->randomElement(['permanent', 'contract', 'internship']),
                'status'               => 'active',
                'annual_leave_quota'   => 12,
                'annual_leave_used'    => rand(0, 6),
                'basic_salary'         => rand(3000000, 15000000),
                'allowance'            => rand(500000, 3000000),
            ]);
            $employee->assignRole($karyawanRole);
            $newEmployees[] = $employee;
        }

        // ─── Catat Absensi Masuk Malam Ini untuk 300 Karyawan ─────────────────
        $now = Carbon::now('Asia/Jakarta');
        foreach ($newEmployees as $emp) {
            $office = $officeLocations->random();
            $lateMinutes = rand(0, 30);
            $status = $lateMinutes > $emp->shift->late_tolerance_minutes ? 'late' : 'present';
            
            Attendance::create([
                'user_id'              => $emp->id,
                'office_location_id'   => $office->id,
                'shift_id'             => $emp->shift_id,
                'date'                 => $now->toDateString(),
                'check_in_time'        => $now->toTimeString(),
                'check_in_latitude'    => $office->latitude,
                'check_in_longitude'   => $office->longitude,
                'check_in_address'     => $office->address,
                'check_in_distance'    => rand(5, 50),
                'is_fake_gps'          => false,
                'status'               => $status,
                'late_minutes'         => $status === 'late' ? $lateMinutes : 0,
            ]);
        }

        $this->command->info('Successfully added 300 dummy employees and their check-in attendance!');
    }
}
