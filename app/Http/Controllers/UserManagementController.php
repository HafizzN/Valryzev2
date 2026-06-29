<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\ActivityLog;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Spatie\Permission\Models\Role;

class UserManagementController extends Controller
{
    public function index()
    {
        $users = User::with('roles')->orderBy('name')->paginate(15);
        return view('settings.users.index', compact('users'));
    }
    public function create()
    {
        $roles = Role::all();
        return view('settings.users.create', compact('roles'));
    }
    public function store(Request $request)
    {
        $request->validate([
            'name'  => 'required|string|max:255',
            'email' => 'required|email|unique:users',
            'password' => 'required|min:8|confirmed',
            'role'  => 'required|exists:roles,name',
        ]);
        $user = User::create(['name' => $request->name, 'email' => $request->email, 'password' => Hash::make($request->password)]);
        $user->assignRole($request->role);

        ActivityLog::log('create', 'User', $user->id, [
            'name' => $user->name,
            'email' => $user->email,
            'role' => $request->role
        ]);

        return redirect()->route('settings.users.index')->with('success', 'User berhasil dibuat.');
    }
    public function edit(User $user)
    {
        $roles = Role::all();
        return view('settings.users.edit', compact('user', 'roles'));
    }
    public function update(Request $request, User $user)
    {
        $request->validate([
            'name'  => 'required|string|max:255',
            'email' => 'required|email|unique:users,email,' . $user->id,
            'role'  => 'required|exists:roles,name',
        ]);

        $oldData = $user->only(['name', 'email']);
        $oldRole = $user->roles->pluck('name')->first();

        $user->update($request->only(['name', 'email']));
        if ($request->filled('password')) {
            $user->update(['password' => Hash::make($request->password)]);
        }
        $user->syncRoles([$request->role]);

        $newData = $user->only(['name', 'email']);
        $newRole = $request->role;

        ActivityLog::log('update', 'User', $user->id, [
            'old' => array_merge($oldData, ['role' => $oldRole]),
            'new' => array_merge($newData, ['role' => $newRole])
        ]);

        return redirect()->route('settings.users.index')->with('success', 'User berhasil diperbarui.');
    }
    public function destroy(User $user)
    {
        if ($user->id === auth()->id()) return back()->with('error', 'Tidak dapat menghapus akun sendiri.');
        
        $details = $user->only(['name', 'email']);
        $userId = $user->id;
        $user->delete();

        ActivityLog::log('delete', 'User', $userId, $details);

        return redirect()->route('settings.users.index')->with('success', 'User berhasil dihapus.');
    }
}
