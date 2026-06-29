<?php

namespace App\Exports;

use Maatwebsite\Excel\Concerns\FromQuery;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Concerns\WithStyles;
use Maatwebsite\Excel\Concerns\WithTitle;
use Maatwebsite\Excel\Concerns\WithMapping;
use PhpOffice\PhpSpreadsheet\Worksheet\Worksheet;
use Illuminate\Database\Eloquent\Builder;

class AttendanceReportExport implements FromQuery, WithHeadings, WithStyles, WithTitle, WithMapping
{
    public function __construct(private Builder $query) {}

    public function query()
    {
        return $this->query->orderBy('date')->orderBy('user_id');
    }

    public function map($a): array
    {
        // Handle date formatting (works with both string and Carbon instances)
        $date = is_string($a->date) ? \Carbon\Carbon::parse($a->date) : $a->date;
        
        return [
            $date->format('d/m/Y'),
            $a->user_nik ?? '-',
            $a->user_name ?? '-',
            $a->division_name ?? '-',
            $a->check_in_time ?? '-',
            $a->check_out_time ?? '-',
            match($a->status) {
                'present' => 'Hadir', 'late' => 'Terlambat',
                'absent' => 'Absen', 'permission' => 'Izin',
                'leave' => 'Cuti', 'sick' => 'Sakit',
                'holiday' => 'Libur', default => '-'
            },
            $a->late_minutes > 0 ? $a->late_minutes . ' menit' : '-',
            $a->check_in_distance ? $a->check_in_distance . ' m' : '-',
        ];
    }

    public function headings(): array
    {
        return ['Tanggal', 'NIK', 'Nama', 'Divisi', 'Jam Masuk', 'Jam Pulang', 'Status', 'Keterlambatan', 'Jarak'];
    }

    public function styles(Worksheet $sheet): array
    {
        return [
            1 => [
                'font' => ['bold' => true, 'color' => ['rgb' => 'FFFFFF']],
                'fill' => ['fillType' => 'solid', 'startColor' => ['rgb' => '1E3A5F']],
            ],
        ];
    }

    public function title(): string
    {
        return 'Laporan Kehadiran';
    }
}
