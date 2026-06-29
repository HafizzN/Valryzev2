import { LayoutDashboard, Users, Clock, BarChart3, Settings, Bell, ChevronRight, Zap } from "lucide-react";

interface SidebarProps {
  activeTab: string;
  onTabChange: (tab: string) => void;
}

const navItems = [
  { id: "overview", label: "Overview", icon: LayoutDashboard },
  { id: "karyawan", label: "Karyawan", icon: Users },
  { id: "kehadiran", label: "Kehadiran", icon: Clock },
  { id: "laporan", label: "Laporan", icon: BarChart3 },
];

export function Sidebar({ activeTab, onTabChange }: SidebarProps) {
  return (
    <aside className="w-56 flex flex-col h-full bg-[#312E81] text-white shrink-0" style={{ borderRight: "1px solid rgba(255,255,255,0.06)" }}>
      {/* Logo */}
      <div className="px-5 pt-6 pb-8">
        <div className="flex items-center gap-2">
          <div className="w-7 h-7 rounded-lg bg-[#E11D48] flex items-center justify-center">
            <Zap size={14} className="text-white fill-white" />
          </div>
          <div>
            <div className="tracking-[0.15em] text-white" style={{ fontFamily: "'Plus Jakarta Sans', sans-serif", fontWeight: 700, fontSize: "13px" }}>
              VAL<span className="text-[#E11D48]">RYZE</span>
            </div>
          </div>
        </div>
      </div>

      {/* Navigation */}
      <nav className="flex-1 px-3 space-y-0.5">
        <div className="mb-3 px-2">
          <span style={{ fontFamily: "'Plus Jakarta Sans', sans-serif", fontSize: "10px", fontWeight: 600, letterSpacing: "0.1em" }} className="text-white/30 uppercase">
            Menu Utama
          </span>
        </div>
        {navItems.map((item) => {
          const Icon = item.icon;
          const isActive = activeTab === item.id;
          return (
            <button
              key={item.id}
              onClick={() => onTabChange(item.id)}
              className={`w-full flex items-center gap-3 px-3 py-2.5 rounded-xl transition-all duration-200 group ${
                isActive
                  ? "bg-white/15 text-white"
                  : "text-white/50 hover:bg-white/8 hover:text-white/80"
              }`}
            >
              <Icon size={16} strokeWidth={isActive ? 2.5 : 1.8} />
              <span style={{ fontFamily: "'Plus Jakarta Sans', sans-serif", fontSize: "13px", fontWeight: isActive ? 600 : 400 }}>
                {item.label}
              </span>
              {isActive && (
                <span className="ml-auto w-1.5 h-1.5 rounded-full bg-[#E11D48]" />
              )}
            </button>
          );
        })}
      </nav>

      {/* Bottom */}
      <div className="px-3 pb-5 space-y-0.5">
        <div className="mb-3 px-2">
          <span style={{ fontFamily: "'Plus Jakarta Sans', sans-serif", fontSize: "10px", fontWeight: 600, letterSpacing: "0.1em" }} className="text-white/30 uppercase">
            Sistem
          </span>
        </div>
        <button className="w-full flex items-center gap-3 px-3 py-2.5 rounded-xl text-white/50 hover:bg-white/8 hover:text-white/80 transition-all duration-200">
          <Bell size={16} strokeWidth={1.8} />
          <span style={{ fontFamily: "'Plus Jakarta Sans', sans-serif", fontSize: "13px" }}>Notifikasi</span>
          <span className="ml-auto w-4 h-4 rounded-full bg-[#E11D48] flex items-center justify-center" style={{ fontSize: "9px", fontWeight: 700 }}>3</span>
        </button>
        <button className="w-full flex items-center gap-3 px-3 py-2.5 rounded-xl text-white/50 hover:bg-white/8 hover:text-white/80 transition-all duration-200">
          <Settings size={16} strokeWidth={1.8} />
          <span style={{ fontFamily: "'Plus Jakarta Sans', sans-serif", fontSize: "13px" }}>Pengaturan</span>
        </button>

        {/* User */}
        <div className="mt-4 pt-4 border-t border-white/10 flex items-center gap-3 px-2">
          <div className="w-8 h-8 rounded-full bg-[#4F46E5] flex items-center justify-center shrink-0">
            <span style={{ fontFamily: "'Plus Jakarta Sans', sans-serif", fontSize: "11px", fontWeight: 700 }} className="text-white">H</span>
          </div>
          <div className="min-w-0">
            <div style={{ fontFamily: "'Plus Jakarta Sans', sans-serif", fontSize: "12px", fontWeight: 600 }} className="text-white truncate">Hafiz Maulana</div>
            <div style={{ fontFamily: "'Plus Jakarta Sans', sans-serif", fontSize: "10px" }} className="text-white/40 truncate">Admin HR</div>
          </div>
        </div>
      </div>
    </aside>
  );
}
