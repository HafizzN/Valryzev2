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

class ThousandEmployeesSeeder extends Seeder
{
    public function run(): void
    {
        $this->command->info('🚀 Starting to seed 1000 employees with full data!');
        
        $divisions = Division::all();
        $positions = Position::all();
        $shifts = Shift::all();
        $officeLocations = OfficeLocation::all();
        $karyawanRole = Role::where('name', 'karyawan')->first();
        
        $currentCount = User::count();
        $this->command->info("Current employees: {$currentCount}");
        
        $start = microtime(true);
        
        for ($i = 1; $i <= 1000; $i++) {
            if ($i % 100 === 0) {
                $elapsed = round(microtime(true) - $start, 2);
                $this->command->info("Created {$i}/1000 employees... ({$elapsed}s)");
            }
            
            $division = $divisions->random();
            $position = $positions->where('division_id', $division->id)->random() ?? $positions->random();
            $shift = $shifts->random();
            
            $nik = 'KRY' . str_pad($i + 2000, 6, '0', STR_PAD_LEFT);
            
            // Generate photo for every 5th user to keep it fast
            $photo = null;
            if ($i % 5 === 0) {
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
            
            // Generate attendance for past 7 days (weekdays only)
            $today = Carbon::now('Asia/Jakarta');
            for ($d = 0; $d < 7; $d++) {
                $date = $today->copy()->subDays($d);
                if ($date->isWeekend()) {
                    continue;
                }
                
                $office = $officeLocations->random();
                $rand = rand(1, 100);
                if ($rand <= 80) { // Hadir tepat waktu
                    $checkInOffset = rand(5, 45);
                    $checkInTime = Carbon::parse($shift->start_time)->subMinutes($checkInOffset);
                    $checkOutOffset = rand(10, 40);
                    $checkOutTime = Carbon::parse($shift->end_time)->addMinutes($checkOutOffset);
                    
                    Attendance::create([
                        'user_id'              => $employee->id,
                        'office_location_id'   => $office->id,
                        'shift_id'             => $shift->id,
                        'date'                 => $date->toDateString(),
                        'check_in_time'        => $checkInTime->toTimeString(),
                        'check_out_time'       => $checkOutTime->toTimeString(),
                        'check_in_latitude'    => $office->latitude,
                        'check_in_longitude'   => $office->longitude,
                        'check_in_address'     => $office->address,
                        'check_in_distance'    => rand(5, 50),
                        'check_out_latitude'   => $office->latitude,
                        'check_out_longitude'  => $office->longitude,
                        'check_out_address'    => $office->address,
                        'check_out_distance'   => rand(5, 50),
                        'is_fake_gps'          => false,
                        'status'               => 'present',
                        'late_minutes'         => 0,
                    ]);
                } elseif ($rand <= 92) { // Terlambat
                    $lateMinutes = rand(16, 60);
                    $checkInTime = Carbon::parse($shift->start_time)->addMinutes($lateMinutes);
                    $checkOutOffset = rand(10, 40);
                    $checkOutTime = Carbon::parse($shift->end_time)->addMinutes($checkOutOffset);
                    
                    Attendance::create([
                        'user_id'              => $employee->id,
                        'office_location_id'   => $office->id,
                        'shift_id'             => $shift->id,
                        'date'                 => $date->toDateString(),
                        'check_in_time'        => $checkInTime->toTimeString(),
                        'check_out_time'       => $checkOutTime->toTimeString(),
                        'check_in_latitude'    => $office->latitude,
                        'check_in_longitude'   => $office->longitude,
                        'check_in_address'     => $office->address,
                        'check_in_distance'    => rand(5, 50),
                        'check_out_latitude'   => $office->latitude,
                        'check_out_longitude'  => $office->longitude,
                        'check_out_address'    => $office->address,
                        'check_out_distance'   => rand(5, 50),
                        'is_fake_gps'          => false,
                        'status'               => 'late',
                        'late_minutes'         => $lateMinutes,
                    ]);
                } else { // Absen
                    Attendance::create([
                        'user_id'              => $employee->id,
                        'office_location_id'   => $office->id,
                        'shift_id'             => $shift->id,
                        'date'                 => $date->toDateString(),
                        'status'               => 'absent',
                        'late_minutes'         => 0,
                    ]);
                }
            }
        }
        
        $totalTime = round(microtime(true) - $start, 2);
        $this->command->info("\n✅ Done! Added 1000 employees in {$totalTime}s!");
        $this->command->info("Total employees now: " . User::count());
        $this->command->info("Total attendance records: " . Attendance::count());
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
