<?php

namespace App\Jobs;

use App\Models\Attendance;
use App\Services\WatermarkService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Storage;

class ProcessAttendanceWatermark implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public function __construct(public Attendance $attendance, public array $watermarkData, public ?string $photoField = 'check_in_photo')
    {
        //
    }

    public function handle(WatermarkService $watermarkService): void
    {
        if (!$this->attendance->{$this->photoField}) {
            return;
        }

        $photoPath = $this->attendance->{$this->photoField};
        if (str_contains($photoPath, '_wm')) {
            return;
        }

        $fullPath = Storage::disk('public')->path($photoPath);
        if (!file_exists($fullPath)) {
            return;
        }

        $watermarkedPath = $watermarkService->applyWatermark($fullPath, $this->watermarkData);
        $finalPhotoPath = str_replace(Storage::disk('public')->path(''), '', $watermarkedPath);

        $this->attendance->update([
            $this->photoField => $finalPhotoPath
        ]);
    }
}
