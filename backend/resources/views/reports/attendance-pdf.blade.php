<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Laporan Kehadiran</title>
    <style>
        body { font-family: Helvetica, Arial, sans-serif; font-size: 8pt; margin: 10px; }
        .header { text-align: center; border-bottom: 2px solid #000; padding-bottom: 5px; margin-bottom: 10px; }
        .header h1 { font-size: 12pt; margin: 0; text-transform: uppercase; }
        .header p { font-size: 8pt; color: #444; margin: 2px 0 0 0; }
        .meta { margin-bottom: 10px; font-size: 8pt; }
        .meta .right { float: right; }
        table { width: 100%; border-collapse: collapse; font-size: 7pt; }
        th, td { border: 1px solid #000; padding: 4px 3px; text-align: left; }
        th { background: #eee; font-weight: bold; }
        .text-center { text-align: center; }
        .mono { font-family: Courier, monospace; }
    </style>
</head>
<body>
    <div class="header">
        <h1>Laporan Rekapitulasi Kehadiran Karyawan</h1>
        <p>Smart HR Portal</p>
    </div>
    <div class="meta">
        Bulan: <strong>{{ \Carbon\Carbon::parse($month . '-01')->isoFormat('MMMM Y') }}</strong>
        <span class="right">Dicetak: {{ now()->isoFormat('D MMM Y HH:mm') }}</span>
    </div>
    <table>
        <thead>
            <tr>
                <th class="text-center" style="width: 3%">No</th>
                <th style="width: 8%">Tanggal</th>
                <th style="width: 8%">NIK</th>
                <th style="width: 20%">Nama</th>
                <th style="width: 12%">Divisi</th>
                <th style="width: 12%">Jabatan</th>
                <th class="text-center" style="width: 8%">Masuk</th>
                <th class="text-center" style="width: 8%">Pulang</th>
                <th class="text-center" style="width: 6%">Late</th>
                <th class="text-center" style="width: 10%">Status</th>
            </tr>
        </thead>
        <tbody>
            @php $i = 1; @endphp
            @foreach($attendances as $att)
                <tr>
                    <td class="text-center mono">{{ $i++ }}</td>
                    <td class="mono">{{ \Carbon\Carbon::parse($att->date)->format('d-m-Y') }}</td>
                    <td class="mono">{{ $att->user_nik ?? '-' }}</td>
                    <td><strong>{{ $att->user_name ?? '-' }}</strong></td>
                    <td>{{ $att->division_name ?? '-' }}</td>
                    <td>{{ $att->position_name ?? '-' }}</td>
                    <td class="text-center mono">{{ $att->check_in_time ? substr($att->check_in_time, 0, 8) : '--:--:--' }}</td>
                    <td class="text-center mono">{{ $att->check_out_time ? substr($att->check_out_time, 0, 8) : '--:--:--' }}</td>
                    <td class="text-center mono">{{ $att->late_minutes > 0 ? $att->late_minutes : '0' }}</td>
                    <td class="text-center">{{ strtoupper($att->status) }}</td>
                </tr>
            @endforeach
        </tbody>
    </table>
</body>
</html>
