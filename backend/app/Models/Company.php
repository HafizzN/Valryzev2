<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Storage;

class Company extends Model
{
    use HasFactory;

    protected $fillable = [
        'name', 'logo', 'address', 'phone', 'email',
        'website', 'npwp', 'nib', 'about',
    ];

    /**
     * Get the company's logo URL.
     *
     * @return string|null
     */
    public function getLogoUrlAttribute()
    {
        if ($this->logo && Storage::disk('public')->exists($this->logo)) {
            return Storage::url($this->logo);
        }
        return null;
    }
}
