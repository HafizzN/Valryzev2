@extends('layouts.app')

@section('title', 'Kalender Kerja & Kehadiran')
@section('page-title', 'Kalender Kerja')
@section('breadcrumb', 'Utama › Kalender')

@section('content')
<div class="space-y-6">
    <!-- Header -->
    <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <div>
            <h2 class="text-xl font-bold text-slate-800 dark:text-slate-100">Kalender Kerja & Kehadiran</h2>
            <p class="text-xs text-slate-500 dark:text-slate-400">Tinjauan hari libur nasional, akhir pekan, dan rekap absensi bulanan secara visual</p>
        </div>
        
        <!-- Legend Summary -->
        <div class="flex flex-wrap gap-2 text-xs">
            <span class="inline-flex items-center gap-1 px-2.5 py-1 rounded-full bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">
                <span class="w-1.5 h-1.5 rounded-full bg-emerald-400"></span> Hadir / Telat
            </span>
            <span class="inline-flex items-center gap-1 px-2.5 py-1 rounded-full bg-purple-500/10 text-purple-400 border border-purple-500/20">
                <span class="w-1.5 h-1.5 rounded-full bg-purple-400"></span> Cuti
            </span>
            <span class="inline-flex items-center gap-1 px-2.5 py-1 rounded-full bg-blue-500/10 text-blue-400 border border-blue-500/20">
                <span class="w-1.5 h-1.5 rounded-full bg-blue-400"></span> Izin / Sakit
            </span>
            <span class="inline-flex items-center gap-1 px-2.5 py-1 rounded-full bg-rose-500/10 text-rose-400 border border-rose-500/20">
                <span class="w-1.5 h-1.5 rounded-full bg-rose-400"></span> Libur Resmi
            </span>
            <span class="inline-flex items-center gap-1 px-2.5 py-1 rounded-full bg-red-500/10 text-red-400 border border-red-500/20">
                <span class="w-1.5 h-1.5 rounded-full bg-red-400"></span> Alpa / Mangkir
            </span>
        </div>
    </div>

    <!-- Filters & Selection -->
    <div class="card">
        <form method="GET" action="{{ route('calendar.index') }}" class="grid grid-cols-1 md:grid-cols-4 gap-4 items-end">
            <!-- Month Picker -->
            <div class="form-group mb-0">
                <label class="form-label" for="month">Pilih Bulan</label>
                <input type="month" name="month" id="month" class="form-control" value="{{ $month }}" onchange="this.form.submit()">
            </div>

            <!-- Employee Dropdown (Admins / Managers) -->
            @if($canFilter)
            <div class="form-group mb-0">
                <label class="form-label" for="user_id">Lihat Kehadiran Karyawan</label>
                <select name="user_id" id="user_id" class="form-control" onchange="this.form.submit()">
                    @foreach($employees as $emp)
                        <option value="{{ $emp->id }}" {{ $selectedUser->id == $emp->id ? 'selected' : '' }}>
                            {{ $emp->name }} ({{ $emp->nik }})
                        </option>
                    @endforeach
                </select>
            </div>
            @endif

            <div class="md:col-span-2 flex justify-end">
                <div class="text-right">
                    <span class="text-xs text-slate-500 dark:text-slate-400">Menampilkan kalender untuk:</span>
                    <div class="font-bold text-slate-800 dark:text-slate-100 text-sm">{{ $selectedUser->name }} ({{ $selectedUser->nik }})</div>
                    <span class="badge badge-info" style="font-size: 0.65rem; margin-top: 0.2rem;">{{ $selectedUser->role_label }}</span>
                </div>
            </div>
        </form>
    </div>

    <!-- Calendar View -->
    <div class="card p-4 md:p-6">
        @php
            $carbonMonth = \Carbon\Carbon::parse($month . '-01');
            $daysInMonth = $carbonMonth->daysInMonth;
            $startDayOfWeek = $carbonMonth->dayOfWeekIso; // 1 (Mon) - 7 (Sun)
            $monthName = $carbonMonth->translatedFormat('F Y');
            
            // Generate weeks padding
            $paddingDays = $startDayOfWeek - 1;
            
            $daysOfWeek = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
            $todayStr = today()->format('Y-m-d');
        @endphp

        <div class="flex items-center justify-between mb-6">
            <h3 class="text-lg font-bold text-slate-800 dark:text-slate-100">{{ $monthName }}</h3>
            
            <!-- Navigation Buttons -->
            <div class="flex gap-2">
                <a href="{{ route('calendar.index', array_merge(request()->query(), ['month' => $carbonMonth->copy()->subMonth()->format('Y-m')])) }}" class="btn btn-secondary btn-sm" title="Bulan Sebelumnya">
                    <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/></svg>
                </a>
                <a href="{{ route('calendar.index', array_merge(request()->query(), ['month' => now()->format('Y-m')])) }}" class="btn btn-secondary btn-sm">Bulan Ini</a>
                <a href="{{ route('calendar.index', array_merge(request()->query(), ['month' => $carbonMonth->copy()->addMonth()->format('Y-m')])) }}" class="btn btn-secondary btn-sm" title="Bulan Berikutnya">
                    <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/></svg>
                </a>
            </div>
        </div>

        <!-- Days of Week Header -->
        <div class="calendar-days-header">
            @foreach($daysOfWeek as $dayName)
                <div class="{{ $dayName == 'Sabtu' || $dayName == 'Minggu' ? 'text-red-500/80' : '' }}">{{ $dayName }}</div>
            @endforeach
        </div>

        <!-- Calendar Grid -->
        <div class="calendar-grid" id="calendar-grid">
            <!-- Empty padding days -->
            @for($i = 0; $i < $paddingDays; $i++)
                <div class="calendar-day-empty"></div>
            @endfor

            <!-- Days of Month -->
            @for($day = 1; $day <= $daysInMonth; $day++)
                @php
                    $currentDate = $carbonMonth->copy()->day($day);
                    $dateStr = $currentDate->format('Y-m-d');
                    $dayOfWeek = $currentDate->dayOfWeekIso; // 1 (Mon) - 7 (Sun)
                    $isWeekend = ($dayOfWeek == 6 || $dayOfWeek == 7);
                    $isToday = ($dateStr === $todayStr);
                    
                    $holiday = $holidays->get($dateStr);
                    $attendance = $attendances->get($dateStr);
                    
                    // Style classes mapping using custom CSS
                    $cardClass = 'calendar-day-card ';
                    if ($isToday) {
                        $cardClass .= 'is-today ';
                    }
                    if ($holiday) {
                        $cardClass .= 'is-holiday ';
                    }
                    if ($isWeekend) {
                        $cardClass .= 'is-weekend ';
                    }
                @endphp

                <div class="{{ $cardClass }} group"
                     @if(auth()->user()->hasRole(['super_admin', 'hrd']))
                        onclick="handleDayClick('{{ $dateStr }}', '{{ $holiday ? $holiday->id : '' }}', '{{ $holiday ? addslashes($holiday->name) : '' }}', '{{ $holiday ? addslashes($holiday->description) : '' }}')"
                     @endif
                     data-date="{{ $dateStr }}">
                     
                    <!-- Date Number & Badge -->
                    <div class="flex items-start justify-between">
                        <span class="text-sm font-bold font-mono {{ $isToday ? 'text-emerald-500' : ($isWeekend || $holiday ? 'text-rose-500' : 'text-slate-700 dark:text-slate-300') }}">
                            {{ $day }}
                        </span>
                        
                        @if($isToday)
                            <span class="inline-flex items-center px-1.5 py-0.5 rounded text-[9px] font-semibold bg-emerald-500 text-white leading-none">Hari Ini</span>
                        @endif
                    </div>

                    <!-- Day Content Info -->
                    <div class="mt-2 flex-1 flex flex-col justify-end space-y-1">
                        @if($holiday)
                            <!-- Public Holiday -->
                            <div class="text-[10px] font-bold text-rose-600 dark:text-rose-400 leading-tight truncate" title="{{ $holiday->name }}">
                                🏮 {{ $holiday->name }}
                            </div>
                        @elseif($attendance)
                            <!-- Attendance status -->
                            @php
                                $status = $attendance->status;
                            @endphp
                            
                            @if($status === 'present')
                                <div class="badge badge-success text-[9px] py-0.5 w-full justify-center">✓ Hadir</div>
                                <div class="text-[9px] font-mono text-slate-500 text-center mt-0.5">
                                    {{ $attendance->check_in_time ? \Carbon\Carbon::parse($attendance->check_in_time)->format('H:i') : '-' }} - 
                                    {{ $attendance->check_out_time ? \Carbon\Carbon::parse($attendance->check_out_time)->format('H:i') : 'Kerja' }}
                                </div>
                            @elseif($status === 'late')
                                <div class="badge badge-warning text-[9px] py-0.5 w-full justify-center">⏰ Terlambat</div>
                                <div class="text-[9px] font-mono text-amber-500/80 text-center mt-0.5">
                                    {{ \Carbon\Carbon::parse($attendance->check_in_time)->format('H:i') }} (+{{ $attendance->late_minutes }}m)
                                </div>
                            @elseif($status === 'leave')
                                <div class="badge badge-purple text-[9px] py-0.5 w-full justify-center">🏖️ Cuti</div>
                                <div class="text-[9px] text-purple-400/80 text-center truncate leading-none mt-0.5">
                                    {{ $attendance->notes ?? 'Cuti' }}
                                </div>
                            @elseif($status === 'permission')
                                <div class="badge badge-info text-[9px] py-0.5 w-full justify-center">📋 Izin</div>
                                <div class="text-[9px] text-teal-400/80 text-center truncate leading-none mt-0.5">
                                    {{ $attendance->notes ?? 'Izin' }}
                                </div>
                            @elseif($status === 'sick')
                                <div class="badge badge-orange text-[9px] py-0.5 w-full justify-center">🤢 Sakit</div>
                                <div class="text-[9px] text-orange-400/80 text-center truncate leading-none mt-0.5">
                                    {{ $attendance->notes ?? 'Sakit' }}
                                </div>
                            @elseif($status === 'absent')
                                <div class="badge badge-danger text-[9px] py-0.5 w-full justify-center">✗ Alpa</div>
                            @elseif($status === 'holiday')
                                <!-- This handles holiday attendance records -->
                                <div class="text-[10px] font-semibold text-rose-500/80 dark:text-rose-400/70 text-center italic">Libur Kerja</div>
                            @endif
                        @else
                            <!-- No attendance record -->
                            @if($isWeekend)
                                <span class="text-[10px] text-slate-400 dark:text-slate-600 font-semibold text-center block italic">Akhir Pekan</span>
                            @elseif($currentDate->isPast() && !$isToday)
                                <!-- Past weekday without attendance record is considered Alpa (Absent) -->
                                <div class="badge badge-danger text-[9px] py-0.5 w-full justify-center">✗ Alpa</div>
                            @else
                                <span class="text-[9px] text-slate-300 dark:text-slate-700 text-center block">-</span>
                            @endif
                        @endif
                    </div>
                </div>
            @endfor
        </div>
    </div>
</div>

<!-- AJAX Holiday Modal (Super Admin & HRD Only) -->
@if(auth()->user()->hasRole(['super_admin', 'hrd']))
<div id="holiday-modal" class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-50 flex items-center justify-center hidden opacity-0 transition-opacity duration-300">
    <div class="bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 rounded-2xl w-full max-w-md p-6 shadow-2xl transform scale-95 transition-transform duration-300">
        
        <!-- Modal Header -->
        <div class="flex items-center justify-between mb-4 border-b border-slate-100 dark:border-slate-800 pb-3">
            <h3 class="text-base font-bold text-slate-800 dark:text-slate-100" id="modal-title">Atur Hari Libur</h3>
            <button onclick="closeModal()" class="text-slate-400 hover:text-slate-600 dark:hover:text-slate-200">
                <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>
            </button>
        </div>

        <!-- Modal Form -->
        <form id="holiday-form" onsubmit="submitHoliday(event)">
            @csrf
            <input type="hidden" id="holiday-id" name="holiday_id">
            
            <div class="form-group">
                <label class="form-label" for="holiday-date">Tanggal</label>
                <input type="date" id="holiday-date" name="date" class="form-control bg-slate-50 dark:bg-slate-950" readonly required>
            </div>

            <div class="form-group">
                <label class="form-label" for="holiday-name">Nama Hari Libur</label>
                <input type="text" id="holiday-name" name="name" class="form-control" placeholder="Contoh: Tahun Baru Masehi / Cuti Bersama" required>
            </div>

            <div class="form-group">
                <label class="form-label" for="holiday-description">Deskripsi (Opsional)</label>
                <textarea id="holiday-description" name="description" rows="3" class="form-control" placeholder="Keterangan tambahan mengenai hari libur ini"></textarea>
            </div>

            <!-- Error container -->
            <div id="modal-errors" class="text-xs text-red-500 mb-4 hidden"></div>

            <!-- Modal Actions -->
            <div class="flex gap-2 justify-end mt-6 border-t border-slate-100 dark:border-slate-800 pt-3">
                <button type="button" onclick="closeModal()" class="btn btn-secondary">Batal</button>
                <button type="button" id="btn-delete-holiday" onclick="deleteHoliday()" class="btn btn-danger hidden">Hapus Libur</button>
                <button type="submit" id="btn-submit-holiday" class="btn btn-primary">Simpan</button>
            </div>
        </form>
    </div>
</div>
@endif
@endsection

@push('scripts')
<script>
    // Modal controls (Admin / HRD Only)
    const modal = document.getElementById('holiday-modal');
    const form = document.getElementById('holiday-form');
    const modalTitle = document.getElementById('modal-title');
    const holidayIdInput = document.getElementById('holiday-id');
    const holidayDateInput = document.getElementById('holiday-date');
    const holidayNameInput = document.getElementById('holiday-name');
    const holidayDescInput = document.getElementById('holiday-description');
    const btnDelete = document.getElementById('btn-delete-holiday');
    const errorDiv = document.getElementById('modal-errors');

    function handleDayClick(dateStr, holidayId, holidayName, holidayDesc) {
        if (!modal) return;
        
        // Reset form errors
        errorDiv.classList.add('hidden');
        errorDiv.textContent = '';
        form.reset();

        holidayDateInput.value = dateStr;

        if (holidayId) {
            // Editing/deleting existing holiday
            modalTitle.textContent = 'Detail Hari Libur Resmi';
            holidayIdInput.value = holidayId;
            holidayNameInput.value = holidayName;
            holidayDescInput.value = holidayDesc;
            
            // Show delete button, set inputs to disabled if not editing
            btnDelete.classList.remove('hidden');
            document.getElementById('btn-submit-holiday').classList.add('hidden');
        } else {
            // Registering new holiday
            modalTitle.textContent = 'Daftarkan Hari Libur Baru';
            holidayIdInput.value = '';
            btnDelete.classList.add('hidden');
            document.getElementById('btn-submit-holiday').classList.remove('hidden');
        }

        // Open modal with smooth transition
        modal.classList.remove('hidden');
        setTimeout(() => {
            modal.classList.remove('opacity-0');
            modal.querySelector('div').classList.remove('scale-95');
        }, 10);
    }

    function closeModal() {
        if (!modal) return;
        modal.classList.add('opacity-0');
        modal.querySelector('div').classList.add('scale-95');
        setTimeout(() => {
            modal.classList.add('hidden');
        }, 300);
    }

    // Submit New Holiday via AJAX
    function submitHoliday(event) {
        event.preventDefault();
        if (!form) return;

        errorDiv.classList.add('hidden');
        errorDiv.textContent = '';

        const formData = new FormData(form);
        const data = {};
        formData.forEach((value, key) => { data[key] = value; });

        fetch('{{ route("calendar.holidays.store") }}', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-TOKEN': '{{ csrf_token() }}',
                'Accept': 'application/json'
            },
            body: JSON.stringify(data)
        })
        .then(response => response.json().then(data => ({ status: response.status, body: data })))
        .then(res => {
            if (res.status === 200 || res.body.success) {
                closeModal();
                // Show custom notification or reload
                window.location.reload();
            } else {
                // Display validation errors
                errorDiv.classList.remove('hidden');
                errorDiv.textContent = res.body.message || 'Terjadi kesalahan saat memproses data.';
            }
        })
        .catch(err => {
            errorDiv.classList.remove('hidden');
            errorDiv.textContent = 'Koneksi jaringan terganggu. Silakan coba kembali.';
        });
    }

    // Delete Holiday via AJAX
    function deleteHoliday() {
        const id = holidayIdInput.value;
        if (!id) return;

        if (!confirm('Apakah Anda yakin ingin menghapus hari libur resmi ini? Seluruh absensi otomatis karyawan pada hari tersebut juga akan dihapus.')) {
            return;
        }

        errorDiv.classList.add('hidden');
        errorDiv.textContent = '';

        fetch(`/calendar/holidays/${id}`, {
            method: 'DELETE',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-TOKEN': '{{ csrf_token() }}',
                'Accept': 'application/json'
            }
        })
        .then(response => response.json().then(data => ({ status: response.status, body: data })))
        .then(res => {
            if (res.status === 200 || res.body.success) {
                closeModal();
                window.location.reload();
            } else {
                errorDiv.classList.remove('hidden');
                errorDiv.textContent = res.body.message || 'Gagal menghapus hari libur.';
            }
        })
        .catch(err => {
            errorDiv.classList.remove('hidden');
            errorDiv.textContent = 'Koneksi jaringan terganggu. Gagal menghapus.';
        });
    }
</script>
@endpush

@push('styles')
<style>
    .calendar-days-header {
        display: grid;
        grid-template-columns: repeat(7, 1fr);
        gap: 10px;
        text-align: center;
        font-size: 0.75rem;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.05em;
        color: #64748b;
        margin-bottom: 0.75rem;
    }
    
    .calendar-grid {
        display: grid;
        grid-template-columns: repeat(7, 1fr);
        gap: 12px;
    }
    
    .calendar-day-card {
        background: var(--card-bg);
        border: 1px solid var(--border-color);
        border-radius: 14px;
        padding: 12px;
        min-height: 120px;
        display: flex;
        flex-direction: column;
        justify-content: space-between;
        transition: all 0.2s ease;
        cursor: pointer;
        position: relative;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.02);
        color: var(--text-main);
    }
    
    .calendar-day-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 10px 20px rgba(0, 0, 0, 0.12);
        border-color: var(--primary-light);
    }
    
    .calendar-day-card.is-today {
        border: 2px solid var(--primary-light);
        background: rgba(34, 197, 94, 0.04);
        box-shadow: 0 4px 12px rgba(34, 197, 94, 0.08);
    }
    
    .calendar-day-card.is-weekend {
        background: rgba(248, 250, 252, 0.4);
        border-color: #f1f5f9;
    }
    
    .dark .calendar-day-card.is-weekend {
        background: rgba(255, 255, 255, 0.01);
        border-color: #1f2937;
    }
    
    .calendar-day-card.is-holiday {
        background: rgba(239, 68, 68, 0.04);
        border-color: rgba(239, 68, 68, 0.15);
    }
    
    .calendar-day-empty {
        background: rgba(241, 245, 249, 0.4);
        border: 1px dashed #e2e8f0;
        border-radius: 14px;
        min-height: 120px;
        opacity: 0.5;
    }
    
    .dark .calendar-day-empty {
        background: rgba(255, 255, 255, 0.01);
        border-color: #1f2937;
    }
    
    @media (max-width: 1024px) {
        .calendar-day-card {
            min-height: 100px;
            padding: 8px;
        }
    }
    
    @media (max-width: 768px) {
        .calendar-days-header {
            font-size: 0.65rem;
            gap: 4px;
        }
        .calendar-grid {
            gap: 6px;
        }
        .calendar-day-card {
            min-height: 85px;
            padding: 6px;
            border-radius: 8px;
        }
        .calendar-day-empty {
            min-height: 85px;
            border-radius: 8px;
        }
    }
</style>
@endpush
