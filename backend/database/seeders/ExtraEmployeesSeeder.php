<?php

namespace Database\Seeders;

use App\Models\Division;
use App\Models\Position;
use App\Models\Shift;
use App\Models\OfficeLocation;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Spatie\Permission\Models\Role;
use Carbon\Carbon;
use App\Models\Attendance;
use Illuminate\Support\Facades\Storage;

class ExtraEmployeesSeeder extends Seeder
{
    public function run(): void
    {
        $this->command->info('Starting to seed 500 employees...');
        
        $divisions = Division::all();
        $positions = Position::all();
        $shifts = Shift::all();
        $officeLocations = OfficeLocation::all();
        $karyawanRole = Role::where('name', 'karyawan')->first();
        
        $currentCount = User::count();
        $this->command->info("Current employees: {$currentCount}");
        
        $start = microtime(true);
        
        for ($i = 1; $i <= 500; $i++) {
            if ($i % 100 === 0) {
                $elapsed = round(microtime(true) - $start, 2);
                $this->command->info("Created {$i}/500 employees... ({$elapsed}s)");
            }
            
            $division = $divisions->random();
            $position = $positions->where('division_id', $division->id)->random() ?? $positions->random();
            $shift = $shifts->random();
            
            $nik = 'KRY' . str_pad($i + 300, 5, '0', STR_PAD_LEFT);
            
            // Generate photo quickly (every 10th user to avoid hitting API limits)
            $photo = null;
            if ($i % 10 === 0) {
                $photo = $this->generateProfilePhoto();
            }
            
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
                'photo'                => $photo,
                'annual_leave_quota'   => 12,
                'annual_leave_used'    => rand(0, 6),
                'basic_salary'         => rand(3000000, 15000000),
                'allowance'            => rand(500000, 3000000),
            ]);
            $employee->assignRole($karyawanRole);
            
            // Add today's attendance
            $office = $officeLocations->random();
            $lateMinutes = rand(0, 30);
            $status = $lateMinutes > $employee->shift->late_tolerance_minutes ? 'late' : 'present';
            
            Attendance::create([
                'user_id'              => $employee->id,
                'office_location_id'   => $office->id,
                'shift_id'             => $employee->shift_id,
                'date'                 => Carbon::now('Asia/Jakarta')->toDateString(),
                'check_in_time'        => Carbon::now('Asia/Jakarta')->toTimeString(),
                'check_in_latitude'    => $office->latitude,
                'check_in_longitude'   => $office->longitude,
                'check_in_address'     => $office->address,
                'check_in_distance'    => rand(5, 50),
                'is_fake_gps'          => false,
                'status'               => $status,
                'late_minutes'         => $status === 'late' ? $lateMinutes : 0,
            ]);
        }
        
        $totalTime = round(microtime(true) - $start, 2);
        $this->command->info("✅ Done! Created 500 employees in {$totalTime}s!");
        $this->command->info("Total employees now: " . User::count());
    }

    private function generateProfilePhoto(): ?string
    {
        try {
            $gender = fake()->randomElement(['men', 'women']);
            $id = rand(1, 99);
            $url = "https://randomuser.me/api/portraits/{$gender}/{$id}.jpg";
            $imageContent = @file_get_contents($url);
            
            if ($imageContent === false) {
                return null;
            }
            
            $path = 'public/photos/' . uniqid() . '.jpg';
            Storage::put($path, $imageContent);
            return $path;
        } catch (\Exception $e) {
            return null;
        }
    }
}
