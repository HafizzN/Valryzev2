import { useState, useEffect, useRef } from "react";
import {
  Bell, Home, Users, Clock, CheckCircle, User,
  BarChart3, FileText, Wallet, LogIn, LogOut,
  Sparkles, AlertCircle, TrendingUp, ChevronRight,
  MapPin, Zap, Briefcase, Search,
  CalendarCheck, Star, Plus, Download, Settings,
  Lock, HelpCircle, LogOut as Exit,
  Award, CreditCard, Check, X, ChevronLeft,
  Wifi, Battery, Send, PieChart, ArrowUpRight, ArrowDownRight,
  BadgeDollarSign, ClipboardList,
} from "lucide-react";

const F = "'Plus Jakarta Sans', sans-serif";
const M = "'JetBrains Mono', monospace";

const now     = new Date();
const DAYS    = ["Min","Sen","Sel","Rab","Kam","Jum","Sab"];
const MONTHS  = ["Jan","Feb","Mar","Apr","Mei","Jun","Jul","Agu","Sep","Okt","Nov","Des"];
const dateStr = `${DAYS[now.getDay()]}, ${now.getDate()} ${MONTHS[now.getMonth()]}`;
const timeStr = `${String(now.getHours()).padStart(2,"0")}:${String(now.getMinutes()).padStart(2,"0")}`;
const greetH  = now.getHours();
const greeting = greetH < 11 ? "Good Morning" : greetH < 15 ? "Good Afternoon" : "Good Evening";

/* ══════════════════════════════════════════
   DESIGN TOKENS
══════════════════════════════════════════ */
const CARD_SHADOW = "0 4px 24px rgba(0,0,0,0.07), 0 1px 6px rgba(0,0,0,0.04)";
const CARD_RADIUS = 20;

/* ══════════════════════════════════════════
   ANIMATION HOOKS
══════════════════════════════════════════ */
function useFadeSlide(delay = 0) {
  const [on, setOn] = useState(false);
  useEffect(() => { const t = setTimeout(() => setOn(true), delay); return () => clearTimeout(t); }, [delay]);
  return { opacity: on ? 1 : 0, transform: on ? "translateY(0)" : "translateY(14px)", transition: `opacity 0.42s ease ${delay}ms, transform 0.42s ease ${delay}ms` };
}

/* ══════════════════════════════════════════
   PRIMITIVE ATOMS
══════════════════════════════════════════ */
const STATUS: Record<string,{bg:string;text:string}> = {
  Hadir:      { bg:"rgba(34,197,94,0.12)",  text:"#16A34A" },
  Terlambat:  { bg:"rgba(239,68,68,0.12)",  text:"#DC2626" },
  Cuti:       { bg:"rgba(100,116,139,0.12)",text:"#64748B" },
  Ditugaskan: { bg:"rgba(99,102,241,0.12)", text:"#4F46E5" },
  Disetujui:  { bg:"rgba(34,197,94,0.12)",  text:"#16A34A" },
  Ditolak:    { bg:"rgba(239,68,68,0.12)",  text:"#DC2626" },
  Pending:    { bg:"rgba(245,158,11,0.12)", text:"#D97706" },
};

function Badge({ label }: { label:string }) {
  const c = STATUS[label] ?? { bg:"rgba(100,116,139,0.1)", text:"#64748B" };
  return (
    <div className="px-2.5 py-0.5 rounded-full shrink-0" style={{ background: c.bg }}>
      <span style={{ fontFamily:F, fontSize:"9px", fontWeight:700, color:c.text }}>{label}</span>
    </div>
  );
}

function Av({ name, g, size=28 }: { name:string; g:string; size?:number }) {
  const init = name.split(" ").map(w=>w[0]).slice(0,2).join("");
  return (
    <div className={`bg-gradient-to-br ${g} flex items-center justify-center shrink-0`}
      style={{ width:size, height:size, borderRadius:Math.round(size*0.35), boxShadow:`0 2px 8px rgba(0,0,0,0.15)` }}>
      <span style={{ fontFamily:F, fontSize:size*0.32, fontWeight:800, color:"#fff" }}>{init}</span>
    </div>
  );
}

/* ─── Animated Progress Bar ─── */
function AniBar({ pct, color, track="#F1F5F9" }: { pct:number; color:string; track?:string }) {
  const [w, setW] = useState(0);
  useEffect(() => { const t = setTimeout(() => setW(pct), 200); return () => clearTimeout(t); }, [pct]);
  return (
    <div style={{ height:7, borderRadius:99, background:track, overflow:"hidden" }}>
      <div style={{ width:`${w}%`, height:"100%", borderRadius:99, background:`linear-gradient(to right, ${color}, ${color}99)`, transition:"width 0.9s cubic-bezier(0.4,0,0.2,1)", boxShadow:`0 0 8px ${color}55` }}/>
    </div>
  );
}

/* ─── Premium Button ─── */
function PrimaryBtn({ label, icon: Icon, onClick, gradient, shadow }: { label:string; icon?:React.FC<{size?:number;className?:string}>; onClick?:()=>void; gradient:string; shadow:string }) {
  const [pressed, setPressed] = useState(false);
  return (
    <button
      onClick={onClick}
      onPointerDown={()=>setPressed(true)}
      onPointerUp={()=>setPressed(false)}
      onPointerLeave={()=>setPressed(false)}
      style={{ width:"100%", padding:"11px 16px", borderRadius:16, display:"flex", alignItems:"center", justifyContent:"center", gap:7, background:gradient, boxShadow:shadow, transform:pressed?"scale(0.96)":"scale(1)", transition:"transform 0.15s cubic-bezier(0.34,1.56,0.64,1)" }}>
      {Icon && <Icon size={14} className="text-white"/>}
      <span style={{ fontFamily:F, fontSize:"12px", fontWeight:700, color:"#fff" }}>{label}</span>
    </button>
  );
}

/* ─── Floating Card ─── */
function FCard({ children, style={} }: { children:React.ReactNode; style?:React.CSSProperties }) {
  return (
    <div style={{ background:"#fff", borderRadius:CARD_RADIUS, boxShadow:CARD_SHADOW, overflow:"hidden", ...style }}>
      {children}
    </div>
  );
}

function FHdr({ title, action }: { title:string; action?:string }) {
  return (
    <div className="flex items-center justify-between px-4 py-2.5" style={{ borderBottom:"1px solid rgba(0,0,0,0.04)" }}>
      <span style={{ fontFamily:F, fontSize:"11px", fontWeight:700, color:"#0F172A" }}>{title}</span>
      {action && <span style={{ fontFamily:F, fontSize:"10px", color:"#0284C7", fontWeight:600 }}>{action}</span>}
    </div>
  );
}

/* ══════════════════════════════════════════
   PREMIUM BOTTOM NAV (Capsule Style)
══════════════════════════════════════════ */
function BottomNav({ nav, tab, onTab, accent }: {
  nav: { id:string; label:string; Icon:React.FC<{size?:number;strokeWidth?:number}> }[];
  tab: string; onTab:(id:string)=>void; accent:string;
}) {
  return (
    <div className="shrink-0 flex items-center px-2 pt-1.5 pb-2.5" style={{ background:"#fff", borderTop:"1px solid rgba(0,0,0,0.05)" }}>
      {nav.map(({ id, label, Icon }) => {
        const active = id === tab;
        return (
          <button key={id} onClick={()=>onTab(id)}
            className="flex-1 flex flex-col items-center gap-0.5 transition-all duration-200"
            style={{ padding:"5px 2px", borderRadius:14, background: active ? `${accent}14` : "transparent" }}>
            <Icon
              size={active ? 20 : 18}
              strokeWidth={active ? 2.5 : 1.8}
              // @ts-ignore
              style={{ color: active ? accent : "#CBD5E1", transition:"all 0.2s" }}
            />
            <span style={{ fontFamily:F, fontSize:"8px", fontWeight:active?700:400, color:active?accent:"#CBD5E1", letterSpacing:active?"0.01em":"0" }}>
              {label}
            </span>
          </button>
        );
      })}
    </div>
  );
}

/* ══════════════════════════════════════════
   PREMIUM APP HEADER
══════════════════════════════════════════ */
function AppHeader({ navBg, accent, roleLabel, initials, name }: {
  navBg:string; accent:string; roleLabel:string; initials:string; name:string;
}) {
  return (
    <div className="shrink-0 px-4 pt-3 pb-3" style={{ background: navBg, borderBottom:`1px solid rgba(255,255,255,0.06)` }}>
      <div className="flex items-start justify-between">
        <div>
          <div style={{ fontFamily:F, fontSize:"10px", color:`${accent}cc`, fontWeight:600, marginBottom:2 }}>
            👋 {greeting}
          </div>
          <div className="flex items-center gap-1.5">
            <div className="w-5 h-5 rounded-md flex items-center justify-center" style={{ background:`linear-gradient(135deg,${accent},${accent}88)` }}>
              <Zap size={10} className="text-white fill-white"/>
            </div>
            <span style={{ fontFamily:F, fontSize:"13px", fontWeight:800, color:"#fff", letterSpacing:"0.1em" }}>
              VAL<span style={{ color:accent }}>RYZE</span>
            </span>
          </div>
          <div style={{ fontFamily:F, fontSize:"9px", color:"rgba(255,255,255,0.4)", marginTop:2 }}>{roleLabel}</div>
        </div>
        <div className="flex flex-col items-end gap-1.5">
          <div className={`bg-gradient-to-br w-9 h-9 rounded-2xl flex items-center justify-center`}
            style={{ background:`linear-gradient(135deg,${accent},${accent}88)`, boxShadow:`0 4px 12px ${accent}44` }}>
            <span style={{ fontFamily:F, fontSize:"11px", fontWeight:800, color:"#fff" }}>{initials}</span>
          </div>
          <div className="flex items-center gap-1">
            <div className="w-1.5 h-1.5 rounded-full bg-[#22C55E] animate-pulse"/>
            <span style={{ fontFamily:F, fontSize:"8px", color:"rgba(255,255,255,0.35)" }}>Online · sync 2m ago</span>
          </div>
        </div>
      </div>
    </div>
  );
}

/* ══════════════════════════════════════════
   DATA
══════════════════════════════════════════ */
const EMP = [
  { name:"Budi Santoso",   role:"Staff IT",        div:"Teknologi",  status:"Hadir",     g:"from-[#06B6D4] to-[#0284C7]" },
  { name:"Ahmad Fauzan",   role:"Manajer Ops",     div:"Operasional",status:"Terlambat", g:"from-[#F59E0B] to-[#D97706]" },
  { name:"Siti Ratnawati", role:"Analis Keuangan", div:"Keuangan",   status:"Hadir",     g:"from-[#22C55E] to-[#16A34A]" },
  { name:"Rina Aulia",     role:"HRD Spesialis",   div:"SDM",        status:"Hadir",     g:"from-[#8B5CF6] to-[#7C3AED]" },
  { name:"Dewi Anggraini", role:"Legal Counsel",   div:"Legal",      status:"Cuti",      g:"from-[#EF4444] to-[#DC2626]" },
  { name:"Laila Nuraini",  role:"Akuntan",         div:"Keuangan",   status:"Ditugaskan",g:"from-[#06B6D4] to-[#0891B2]" },
  { name:"Rizky Kurniawan",role:"UI/UX Designer",  div:"Produk",     status:"Hadir",     g:"from-[#818CF8] to-[#6366F1]" },
];
const TEAM = [
  { name:"Rizky Kurniawan",role:"UI/UX Designer",  status:"Hadir",     time:"07:48",streak:30,g:"from-[#818CF8] to-[#6366F1]",score:98 },
  { name:"Laila Nuraini",  role:"Akuntan",          status:"Ditugaskan",time:"—",    streak:0, g:"from-[#34D399] to-[#10B981]",score:85 },
  { name:"Budi Santoso",   role:"Staff IT",         status:"Hadir",     time:"07:52",streak:12,g:"from-[#06B6D4] to-[#0284C7]",score:91 },
  { name:"Ahmad Fauzan",   role:"Ops Coordinator",  status:"Terlambat", time:"08:45",streak:0, g:"from-[#F59E0B] to-[#D97706]",score:72 },
  { name:"Rina Aulia",     role:"HR Specialist",    status:"Hadir",     time:"07:58",streak:8, g:"from-[#F87171] to-[#EF4444]",score:88 },
];

/* ══════════════════════════════════════════
   ANNOUNCEMENT BOX (shared)
══════════════════════════════════════════ */
const ANNOUNCEMENTS = [
  {
    id: 1,
    type: "penting",
    title: "Libur Idul Adha 2026",
    body: "Seluruh karyawan diliburkan 6–8 Juni 2026. Selesaikan tugas sebelum tanggal tersebut.",
    from: "Manajemen",
    time: "2 hari lalu",
    read: false,
  },
  {
    id: 2,
    type: "info",
    title: "Jadwal Medical Check-Up",
    body: "MCU wajib 15–19 Juli 2026. Daftarkan diri via portal HRIS sebelum 10 Juli.",
    from: "HR Department",
    time: "1 jam lalu",
    read: false,
  },
  {
    id: 3,
    type: "pencapaian",
    title: "🏆 Karyawan Terbaik Juni",
    body: "Selamat Rizky Kurniawan atas performa sempurna dan 30 hari streak kehadiran!",
    from: "Tim HR",
    time: "Hari ini",
    read: true,
  },
];

const ANN_CFG: Record<string, { bg: string; border: string; icon: string; dot: string }> = {
  penting:     { bg: "rgba(239,68,68,0.07)",   border: "#EF4444", icon: "🚨", dot: "#EF4444"  },
  info:        { bg: "rgba(6,182,212,0.07)",    border: "#06B6D4", icon: "📢", dot: "#06B6D4"  },
  pencapaian:  { bg: "rgba(245,158,11,0.07)",   border: "#F59E0B", icon: "🏆", dot: "#F59E0B"  },
};

function AnnouncementBox({ canCreate = false }: { canCreate?: boolean }) {
  const [items, setItems] = useState(ANNOUNCEMENTS);
  const [expanded, setExpanded] = useState<number | null>(null);
  const [showForm, setShowForm] = useState(false);
  const [newTitle, setNewTitle] = useState("");
  const [newBody, setNewBody] = useState("");

  const unread = items.filter(a => !a.read).length;

  function markRead(id: number) {
    setItems(p => p.map(a => a.id === id ? { ...a, read: true } : a));
    setExpanded(expanded === id ? null : id);
  }

  function postAnnouncement() {
    if (!newTitle.trim()) return;
    setItems(p => [{
      id: Date.now(), type: "info",
      title: newTitle, body: newBody,
      from: "Anda", time: "Baru saja", read: true,
    }, ...p]);
    setNewTitle(""); setNewBody(""); setShowForm(false);
  }

  return (
    <FCard>
      {/* Header */}
      <div className="px-4 py-2.5 flex items-center gap-2" style={{ borderBottom: "1px solid rgba(0,0,0,0.04)" }}>
        <span style={{ fontSize: 13 }}>📢</span>
        <span style={{ fontFamily: F, fontSize: "11px", fontWeight: 700, color: "#0F172A" }}>Pengumuman</span>
        {unread > 0 && (
          <span className="w-4 h-4 rounded-full flex items-center justify-center" style={{ background: "#EF4444", marginLeft: 2 }}>
            <span style={{ fontFamily: F, fontSize: "8px", fontWeight: 700, color: "#fff" }}>{unread}</span>
          </span>
        )}
        {canCreate && (
          <button onClick={() => setShowForm(v => !v)} className="ml-auto flex items-center gap-1 px-2.5 py-1 rounded-full" style={{ background: "rgba(6,182,212,0.1)", border: "1px solid rgba(6,182,212,0.2)" }}>
            <Plus size={9} style={{ color: "#06B6D4" }} />
            <span style={{ fontFamily: F, fontSize: "9px", fontWeight: 700, color: "#06B6D4" }}>Buat</span>
          </button>
        )}
      </div>

      {/* Create form (HRD only) */}
      {showForm && (
        <div className="px-4 py-3 space-y-2" style={{ borderBottom: "1px solid rgba(0,0,0,0.04)", background: "rgba(6,182,212,0.03)" }}>
          <input
            value={newTitle}
            onChange={e => setNewTitle(e.target.value)}
            placeholder="Judul pengumuman..."
            className="w-full px-3 py-2 rounded-xl outline-none"
            style={{ fontFamily: F, fontSize: "11px", background: "#fff", border: "1px solid rgba(6,182,212,0.25)", color: "#0F172A" }}
          />
          <textarea
            value={newBody}
            onChange={e => setNewBody(e.target.value)}
            placeholder="Isi pengumuman..."
            rows={2}
            className="w-full px-3 py-2 rounded-xl outline-none resize-none"
            style={{ fontFamily: F, fontSize: "11px", background: "#fff", border: "1px solid rgba(6,182,212,0.25)", color: "#0F172A" }}
          />
          <button onClick={postAnnouncement} className="w-full py-2 rounded-xl flex items-center justify-center gap-1.5"
            style={{ background: "linear-gradient(135deg,#0284C7,#06B6D4)", boxShadow: "0 4px 12px rgba(6,182,212,0.3)" }}>
            <Send size={11} className="text-white" />
            <span style={{ fontFamily: F, fontSize: "10px", fontWeight: 700, color: "#fff" }}>Kirim Pengumuman</span>
          </button>
        </div>
      )}

      {/* List */}
      {items.map((a, i) => {
        const cfg = ANN_CFG[a.type] ?? ANN_CFG.info;
        const isOpen = expanded === a.id;
        return (
          <button key={a.id} onClick={() => markRead(a.id)}
            className="w-full text-left px-4 py-3 transition-colors"
            style={{ borderBottom: i < items.length - 1 ? "1px solid rgba(0,0,0,0.04)" : "none", background: isOpen ? cfg.bg : "transparent" }}>
            <div className="flex items-start gap-2.5">
              {/* Left accent bar */}
              <div className="w-0.5 rounded-full shrink-0 mt-0.5" style={{ height: isOpen ? "auto" : 28, minHeight: 28, background: cfg.border, alignSelf: "stretch" }} />
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-1.5 mb-0.5">
                  <span style={{ fontSize: 11 }}>{cfg.icon}</span>
                  <span style={{ fontFamily: F, fontSize: "11px", fontWeight: 700, color: "#0F172A", flex: 1 }} className="truncate">{a.title}</span>
                  {!a.read && <div className="w-1.5 h-1.5 rounded-full shrink-0" style={{ background: cfg.dot }} />}
                </div>
                {isOpen ? (
                  <>
                    <p style={{ fontFamily: F, fontSize: "10px", color: "#64748B", lineHeight: 1.5 }}>{a.body}</p>
                    <div className="flex items-center justify-between mt-1.5">
                      <span style={{ fontFamily: F, fontSize: "9px", color: "#94A3B8" }}>Dari: {a.from}</span>
                      <span style={{ fontFamily: F, fontSize: "9px", color: "#94A3B8" }}>{a.time}</span>
                    </div>
                  </>
                ) : (
                  <div className="flex items-center justify-between">
                    <span style={{ fontFamily: F, fontSize: "10px", color: "#94A3B8" }} className="truncate">{a.body.slice(0, 38)}…</span>
                    <span style={{ fontFamily: F, fontSize: "9px", color: "#94A3B8", shrink: 0, marginLeft: 4 }}>{a.time}</span>
                  </div>
                )}
              </div>
            </div>
          </button>
        );
      })}
    </FCard>
  );
}

/* ══════════════════════════════════════════
   HRD SCREENS
══════════════════════════════════════════ */
function HrdBeranda() {
  const s0=useFadeSlide(0), s1=useFadeSlide(80), s2=useFadeSlide(160), s3=useFadeSlide(240), s4=useFadeSlide(320);
  return (
    <div className="space-y-3 pb-3 px-3 pt-3">
      {/* Hero */}
      <div style={{ ...s0, borderRadius:22, padding:"16px", background:"linear-gradient(135deg,#071830 0%,#0369A1 100%)", boxShadow:"0 8px 32px rgba(3,105,161,0.35)" }}>
        <div style={{ fontFamily:F, fontSize:"10px", color:"#38BDF8", fontWeight:600, letterSpacing:"0.08em" }}>HR DASHBOARD</div>
        <div style={{ fontFamily:F, fontSize:"15px", fontWeight:700, color:"#fff", marginTop:3 }}>Siti Nurhaliza ✨</div>
        <div style={{ fontFamily:F, fontSize:"10px", color:"#7DD3FC", marginTop:3 }}>{dateStr} · 08:00–17:00</div>
        <div className="flex gap-2 mt-3">
          {[{v:"126",l:"Hadir",c:"#34D399"},{v:"7",l:"Pending",c:"#FCD34D"},{v:"92%",l:"Rate",c:"#38BDF8"}].map(s=>(
            <div key={s.l} className="flex-1 rounded-xl py-2.5 text-center" style={{ background:"rgba(255,255,255,0.09)", border:"1px solid rgba(255,255,255,0.12)" }}>
              <div style={{ fontFamily:M, fontSize:"14px", fontWeight:800, color:s.c }}>{s.v}</div>
              <div style={{ fontFamily:F, fontSize:"8px", color:"rgba(255,255,255,0.5)", marginTop:1 }}>{s.l}</div>
            </div>
          ))}
        </div>
      </div>

      {/* Pengumuman — HRD bisa buat */}
      <div style={s1}><AnnouncementBox canCreate={true}/></div>

      {/* Today's Focus */}
      <div style={s2}><FCard>
        <div className="px-4 py-2.5 flex items-center gap-1.5" style={{ borderBottom:"1px solid rgba(0,0,0,0.04)" }}>
          <Sparkles size={11} style={{ color:"#06B6D4" }}/><span style={{ fontFamily:F, fontSize:"11px", fontWeight:700, color:"#0F172A" }}>Today's Focus</span>
          <span className="ml-auto px-2 py-0.5 rounded-full" style={{ fontFamily:F, fontSize:"8px", fontWeight:700, color:"#06B6D4", background:"#CFFAFE" }}>AI</span>
        </div>
        <div className="px-4 py-2.5 space-y-2">
          {[{I:AlertCircle,t:"7 approval menunggu tindakan hari ini",c:"#F59E0B"},{I:TrendingUp,t:"Kehadiran naik 5% dibanding kemarin",c:"#22C55E"},{I:Users,t:"3 karyawan mendekati batas cuti tahunan",c:"#EF4444"}].map((f,i)=>(
            <div key={i} className="flex items-start gap-2"><f.I size={11} style={{ color:f.c, marginTop:1, flexShrink:0 }}/><span style={{ fontFamily:F, fontSize:"10px", color:"#64748B", lineHeight:1.45 }}>{f.t}</span></div>
          ))}
        </div>
      </FCard></div>

      {/* Kehadiran */}
      <div style={s3}><FCard>
        <FHdr title="Kehadiran Terkini" action="Lihat semua"/>
        {EMP.slice(0,4).map((r,i)=>(
          <div key={i} className="flex items-center gap-3 px-4 py-3" style={{ borderBottom:i<3?"1px solid rgba(0,0,0,0.03)":"none" }}>
            <Av name={r.name} g={r.g}/><div className="flex-1 min-w-0"><div style={{ fontFamily:F, fontSize:"11px", fontWeight:600, color:"#0F172A" }}>{r.name}</div><div style={{ fontFamily:F, fontSize:"9px", color:"#94A3B8" }}>{r.role}</div></div><Badge label={r.status}/>
          </div>
        ))}
      </FCard></div>

      {/* Quick stats */}
      <div style={s4} className="grid grid-cols-3 gap-2">
        {[{v:"148",l:"Total Karyawan",c:"#0284C7"},{v:"5",l:"Terlambat",c:"#F59E0B"},{v:"12",l:"Cuti Aktif",c:"#8B5CF6"}].map(s=>(
          <div key={s.l} style={{ background:"#fff", borderRadius:16, boxShadow:CARD_SHADOW, padding:"10px 8px", textAlign:"center" }}>
            <div style={{ fontFamily:M, fontSize:"16px", fontWeight:700, color:s.c }}>{s.v}</div>
            <div style={{ fontFamily:F, fontSize:"8px", color:"#94A3B8", marginTop:2, lineHeight:1.2 }}>{s.l}</div>
          </div>
        ))}
      </div>
    </div>
  );
}

function HrdKaryawan() {
  const [filter,setFilter]=useState("Semua");
  const shown=filter==="Semua"?EMP:EMP.filter(e=>e.status===filter);
  const s0=useFadeSlide(0), s1=useFadeSlide(100);
  return (
    <div className="pb-3 pt-3 px-3">
      <div style={s0}>
        <div className="relative mb-2.5">
          <Search size={12} className="absolute left-3 top-1/2 -translate-y-1/2" style={{ color:"#94A3B8" }}/>
          <input placeholder="Cari karyawan..." className="w-full pl-8 pr-3 py-2.5 outline-none" style={{ fontFamily:F, fontSize:"11px", background:"#fff", borderRadius:14, border:"1px solid rgba(0,0,0,0.08)", color:"#0F172A", boxShadow:"0 2px 8px rgba(0,0,0,0.04)" }}/>
        </div>
        <div className="flex gap-1.5 mb-3 overflow-x-auto pb-0.5" style={{ scrollbarWidth:"none" }}>
          {["Semua","Hadir","Cuti","Ditugaskan"].map(f=>(
            <button key={f} onClick={()=>setFilter(f)} className="shrink-0 px-3 py-1.5 rounded-full transition-all"
              style={{ fontFamily:F, fontSize:"10px", fontWeight:filter===f?700:400, background:filter===f?"#06B6D4":"#fff", color:filter===f?"#fff":"#64748B", boxShadow:filter===f?"0 4px 12px rgba(6,182,212,0.3)":"0 1px 4px rgba(0,0,0,0.06)", border:"none" }}>
              {f}
            </button>
          ))}
        </div>
      </div>
      <div style={s1}><FCard>
        {shown.map((e,i)=>(
          <div key={i} className="flex items-center gap-3 px-4 py-3" style={{ borderBottom:i<shown.length-1?"1px solid rgba(0,0,0,0.03)":"none" }}>
            <Av name={e.name} g={e.g}/>
            <div className="flex-1 min-w-0"><div style={{ fontFamily:F, fontSize:"11px", fontWeight:600, color:"#0F172A" }}>{e.name}</div><div style={{ fontFamily:F, fontSize:"9px", color:"#94A3B8" }}>{e.role} · {e.div}</div></div>
            <Badge label={e.status}/><ChevronRight size={12} style={{ color:"#E2E8F0" }}/>
          </div>
        ))}
        {shown.length===0&&<div className="py-8 text-center" style={{ fontFamily:F, fontSize:"11px", color:"#94A3B8" }}>Tidak ada karyawan</div>}
      </FCard></div>
      <div className="mt-3">
        <PrimaryBtn label="Tambah Karyawan" icon={Plus} gradient="linear-gradient(135deg,#0284C7,#06B6D4)" shadow="0 6px 20px rgba(6,182,212,0.35)"/>
      </div>
    </div>
  );
}

function HrdKehadiran() {
  const bars=[78,82,85,80,88,84,85];
  const s0=useFadeSlide(0), s1=useFadeSlide(80), s2=useFadeSlide(160);
  return (
    <div className="pb-3 pt-3 px-3 space-y-3">
      <div style={s0} className="flex items-center justify-between px-4 py-3 rounded-2xl" style2={{ boxShadow:CARD_SHADOW, background:"#fff" } as React.CSSProperties}>
        <div style={{ background:"#fff", borderRadius:18, boxShadow:CARD_SHADOW, width:"100%", padding:"10px 16px", display:"flex", alignItems:"center", justifyContent:"space-between" }}>
          <ChevronLeft size={16} style={{ color:"#94A3B8" }}/>
          <div className="text-center"><div style={{ fontFamily:F, fontSize:"12px", fontWeight:700, color:"#0F172A" }}>{dateStr}</div><div style={{ fontFamily:F, fontSize:"9px", color:"#94A3B8" }}>Hari ini</div></div>
          <ChevronRight size={16} style={{ color:"#94A3B8" }}/>
        </div>
      </div>
      <div style={s0} className="grid grid-cols-4 gap-2">
        {[{v:"126",l:"Hadir",c:"#22C55E"},{v:"5",l:"Terlambat",c:"#F59E0B"},{v:"12",l:"Cuti",c:"#8B5CF6"},{v:"5",l:"Absen",c:"#EF4444"}].map(s=>(
          <div key={s.l} style={{ background:"#fff", borderRadius:14, boxShadow:CARD_SHADOW, padding:"10px 4px", textAlign:"center" }}>
            <div style={{ fontFamily:M, fontSize:"15px", fontWeight:700, color:s.c }}>{s.v}</div>
            <div style={{ fontFamily:F, fontSize:"8px", color:"#94A3B8" }}>{s.l}</div>
          </div>
        ))}
      </div>
      <div style={s1}><FCard>
        <FHdr title="Tren 7 Hari"/>
        <div className="flex items-end gap-2 px-4 py-3" style={{ height:72 }}>
          {bars.map((v,i)=>{ const t=i===bars.length-1; return (
            <div key={i} className="flex-1 flex flex-col items-center gap-1">
              <div className="w-full rounded-lg" style={{ height:`${v}%`, background:t?"linear-gradient(to top,#0284C7,#06B6D4)":bars[i]>82?"#BFDBFE":"#DBEAFE", boxShadow:t?"0 4px 12px rgba(6,182,212,0.4)":"none", transition:"all 0.3s" }}/>
              <span style={{ fontFamily:F, fontSize:"8px", color:t?"#0284C7":"#94A3B8", fontWeight:t?700:400 }}>{"SSRK JSM"[i]}</span>
            </div>
          ); })}
        </div>
      </FCard></div>
      <div style={s2}><FCard>
        <FHdr title="Daftar Kehadiran" action="Export"/>
        {EMP.map((r,i)=>(
          <div key={i} className="flex items-center gap-3 px-4 py-2.5" style={{ borderBottom:i<EMP.length-1?"1px solid rgba(0,0,0,0.03)":"none" }}>
            <Av name={r.name} g={r.g}/><div className="flex-1 min-w-0"><div style={{ fontFamily:F, fontSize:"11px", fontWeight:600, color:"#0F172A" }}>{r.name}</div><div style={{ fontFamily:F, fontSize:"9px", color:"#94A3B8" }}>{r.div}</div></div><Badge label={r.status}/>
          </div>
        ))}
      </FCard></div>
    </div>
  );
}

function HrdApproval() {
  const initData=[{name:"Siti R.",type:"Cuti Tahunan",days:"3 hari",color:"#0284C7"},{name:"Laila N.",type:"Lembur",days:"2 sesi",color:"#F59E0B"},{name:"Rizky K.",type:"Penugasan",days:"1 hari",color:"#8B5CF6"},{name:"Ahmad F.",type:"Izin Terlambat",days:"1x",color:"#EF4444"}];
  const [items,setItems]=useState(initData.map(a=>({ ...a, done:false, approved:false })));
  const act=(i:number,ok:boolean)=>setItems(p=>p.map((it,idx)=>idx===i?{...it,done:true,approved:ok}:it));
  const pending=items.filter(it=>!it.done);
  const done=items.filter(it=>it.done);
  const s0=useFadeSlide(0), s1=useFadeSlide(80), s2=useFadeSlide(160);
  return (
    <div className="pb-3 pt-3 px-3 space-y-3">
      <div style={{ ...s0, borderRadius:20, padding:"16px", background:"linear-gradient(to right,#071830,#0369A1)", boxShadow:"0 8px 24px rgba(3,105,161,0.3)" }}>
        <div style={{ fontFamily:F, fontSize:"11px", fontWeight:700, color:"#fff" }}>Approval Queue</div>
        <div style={{ fontFamily:F, fontSize:"10px", color:"#7DD3FC", marginTop:1 }}>{pending.length} menunggu tindakan</div>
        <div className="flex gap-2 mt-2.5">
          {[{v:pending.length.toString(),l:"Pending",c:"#FCD34D"},{v:"12",l:"Bulan ini",c:"#34D399"},{v:"3",l:"Ditolak",c:"#F87171"}].map(s=>(
            <div key={s.l} className="flex-1 rounded-xl py-2 text-center" style={{ background:"rgba(255,255,255,0.09)" }}>
              <div style={{ fontFamily:M, fontSize:"14px", fontWeight:700, color:s.c }}>{s.v}</div>
              <div style={{ fontFamily:F, fontSize:"8px", color:"#7DD3FC" }}>{s.l}</div>
            </div>
          ))}
        </div>
      </div>
      {pending.length>0&&<div style={s1}><FCard>
        <FHdr title="Menunggu Review"/>
        {pending.map((a,i)=>{ const idx=items.indexOf(a); return (
          <div key={i} className="px-4 py-3" style={{ borderBottom:i<pending.length-1?"1px solid rgba(0,0,0,0.04)":"none" }}>
            <div className="flex items-center gap-2 mb-2.5">
              <div className="w-1 h-8 rounded-full shrink-0" style={{ background:a.color }}/>
              <div className="flex-1"><div style={{ fontFamily:F, fontSize:"11px", fontWeight:600, color:"#0F172A" }}>{a.name}</div><div style={{ fontFamily:F, fontSize:"9px", color:"#94A3B8" }}>{a.type} · {a.days}</div></div>
            </div>
            <div className="flex gap-2">
              <button onClick={()=>act(idx,false)} className="flex-1 py-2 rounded-xl flex items-center justify-center gap-1.5" style={{ background:"rgba(239,68,68,0.08)", border:"1px solid rgba(239,68,68,0.2)" }}><X size={11} style={{ color:"#DC2626" }}/><span style={{ fontFamily:F, fontSize:"10px", fontWeight:700, color:"#DC2626" }}>Tolak</span></button>
              <button onClick={()=>act(idx,true)} className="flex-1 py-2 rounded-xl flex items-center justify-center gap-1.5" style={{ background:"rgba(34,197,94,0.08)", border:"1px solid rgba(34,197,94,0.2)" }}><Check size={11} style={{ color:"#16A34A" }}/><span style={{ fontFamily:F, fontSize:"10px", fontWeight:700, color:"#16A34A" }}>Setujui</span></button>
            </div>
          </div>
        ); })}
      </FCard></div>}
      {done.length>0&&<div style={s2}><FCard>
        <FHdr title="Sudah Diproses"/>
        {done.map((a,i)=>(
          <div key={i} className="flex items-center gap-3 px-4 py-2.5" style={{ borderBottom:i<done.length-1?"1px solid rgba(0,0,0,0.04)":"none" }}>
            <div className="w-6 h-6 rounded-full flex items-center justify-center shrink-0" style={{ background:a.approved?"rgba(34,197,94,0.12)":"rgba(239,68,68,0.1)" }}>
              {a.approved?<Check size={11} style={{ color:"#16A34A" }}/>:<X size={11} style={{ color:"#DC2626" }}/>}
            </div>
            <div className="flex-1"><div style={{ fontFamily:F, fontSize:"11px", fontWeight:600, color:"#0F172A" }}>{a.name}</div><div style={{ fontFamily:F, fontSize:"9px", color:"#94A3B8" }}>{a.type}</div></div>
            <Badge label={a.approved?"Disetujui":"Ditolak"}/>
          </div>
        ))}
      </FCard></div>}
      {pending.length===0&&done.length===initData.length&&(
        <div style={{ textAlign:"center", padding:"40px 16px" }}>
          <div style={{ width:48, height:48, borderRadius:24, background:"rgba(34,197,94,0.1)", display:"flex", alignItems:"center", justifyContent:"center", margin:"0 auto 8px" }}><CheckCircle size={22} style={{ color:"#22C55E" }}/></div>
          <div style={{ fontFamily:F, fontSize:"13px", fontWeight:700, color:"#0F172A" }}>Semua selesai!</div>
          <div style={{ fontFamily:F, fontSize:"11px", color:"#94A3B8", marginTop:4 }}>Tidak ada approval tertunda</div>
        </div>
      )}
    </div>
  );
}

function ProfileScreen({ name, role, sub, color, init }: { name:string; role:string; sub:string; color:string; init:string }) {
  const s0=useFadeSlide(0), s1=useFadeSlide(100), s2=useFadeSlide(180);
  const menu=[{I:Bell,l:"Notifikasi",v:"Aktif"},{I:Lock,l:"Keamanan",v:"2FA on"},{I:Settings,l:"Preferensi",v:""},{I:HelpCircle,l:"Bantuan",v:""}];
  return (
    <div className="pb-3 pt-3 px-3 space-y-3">
      <div style={{ ...s0, borderRadius:24, padding:"20px 16px", textAlign:"center", background:`linear-gradient(135deg,${color}15,${color}06)`, border:`1px solid ${color}22`, boxShadow:CARD_SHADOW }}>
        <div className="mx-auto mb-3 flex items-center justify-center" style={{ width:56, height:56, borderRadius:20, background:`linear-gradient(135deg,${color},${color}88)`, boxShadow:`0 8px 24px ${color}44` }}>
          <span style={{ fontFamily:F, fontSize:"18px", fontWeight:800, color:"#fff" }}>{init}</span>
        </div>
        <div style={{ fontFamily:F, fontSize:"14px", fontWeight:700, color:"#0F172A" }}>{name}</div>
        <div style={{ fontFamily:F, fontSize:"11px", color:"#64748B", marginTop:2 }}>{role}</div>
        <div className="inline-flex items-center gap-1.5 mt-2 px-3 py-1 rounded-full" style={{ background:`${color}12`, border:`1px solid ${color}25` }}>
          <div className="w-1.5 h-1.5 rounded-full" style={{ background:color }}/>
          <span style={{ fontFamily:F, fontSize:"10px", fontWeight:600, color }}>{sub}</span>
        </div>
      </div>
      <div style={s1}><FCard>
        {menu.map((m,i)=>(
          <div key={i} className="flex items-center gap-3 px-4 py-3" style={{ borderBottom:i<menu.length-1?"1px solid rgba(0,0,0,0.04)":"none" }}>
            <div className="w-8 h-8 rounded-xl flex items-center justify-center" style={{ background:`${color}12` }}><m.I size={14} style={{ color }}/></div>
            <span style={{ fontFamily:F, fontSize:"12px", color:"#0F172A", flex:1 }}>{m.l}</span>
            {m.v&&<span style={{ fontFamily:F, fontSize:"10px", color:"#94A3B8" }}>{m.v}</span>}
            <ChevronRight size={13} style={{ color:"#E2E8F0" }}/>
          </div>
        ))}
      </FCard></div>
      <div style={s2}>
        <button className="w-full py-3 rounded-2xl flex items-center justify-center gap-2" style={{ background:"rgba(239,68,68,0.07)", border:"1px solid rgba(239,68,68,0.15)" }}>
          <Exit size={14} style={{ color:"#DC2626" }}/><span style={{ fontFamily:F, fontSize:"12px", fontWeight:700, color:"#DC2626" }}>Keluar dari Akun</span>
        </button>
      </div>
    </div>
  );
}

/* ══════════════════════════════════════════
   MANAGER SCREENS
══════════════════════════════════════════ */
function MgrBeranda() {
  const s0=useFadeSlide(0), s1=useFadeSlide(80), s2=useFadeSlide(160), s3=useFadeSlide(240);
  const PA=[{name:"Ahmad Fauzan",type:"Izin Terlambat",days:"1x",urgent:true,color:"#EF4444"},{name:"Laila Nuraini",type:"Perpanjang Tugas",days:"3 hari",urgent:false,color:"#8B5CF6"}];
  return (
    <div className="pb-3 pt-3 px-3 space-y-3">
      {/* Hero */}
      <div style={{ ...s0, borderRadius:22, padding:"16px", background:"linear-gradient(135deg,#1E1B4B 0%,#4338CA 100%)", boxShadow:"0 8px 32px rgba(67,56,202,0.35)" }}>
        <div className="flex items-center gap-1.5 mb-0.5"><Briefcase size={9} style={{ color:"#A5B4FC" }}/><span style={{ fontFamily:F, fontSize:"9px", color:"#A5B4FC", fontWeight:600, letterSpacing:"0.08em" }}>MANAJER PRODUK</span></div>
        <div style={{ fontFamily:F, fontSize:"15px", fontWeight:700, color:"#fff" }}>Hendra Wijaya</div>
        <div style={{ fontFamily:F, fontSize:"10px", color:"#A5B4FC", marginTop:2 }}>{dateStr}</div>
        <div className="flex gap-2 mt-3">
          {[{v:"12",l:"Anggota",c:"#C7D2FE"},{v:"10",l:"Hadir",c:"#6EE7B7"},{v:"2",l:"Pending",c:"#FCD34D"}].map(s=>(
            <div key={s.l} className="flex-1 rounded-xl py-2.5 text-center" style={{ background:"rgba(255,255,255,0.09)", border:"1px solid rgba(255,255,255,0.12)" }}>
              <div style={{ fontFamily:M, fontSize:"14px", fontWeight:800, color:s.c }}>{s.v}</div>
              <div style={{ fontFamily:F, fontSize:"8px", color:"rgba(255,255,255,0.45)", marginTop:1 }}>{s.l}</div>
            </div>
          ))}
        </div>
      </div>

      {/* Team Insight Banner */}
      <div style={{ ...s1, borderRadius:18, padding:"12px 14px", background:"linear-gradient(135deg,rgba(129,140,248,0.12),rgba(99,102,241,0.06))", border:"1px solid rgba(129,140,248,0.2)" }}>
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <div style={{ width:32, height:32, borderRadius:12, background:"linear-gradient(135deg,#818CF8,#6366F1)", display:"flex", alignItems:"center", justifyContent:"center" }}>
              <TrendingUp size={14} style={{ color:"#fff" }}/>
            </div>
            <div>
              <div style={{ fontFamily:F, fontSize:"11px", fontWeight:700, color:"#1E1B4B" }}>Team Insight</div>
              <div style={{ fontFamily:F, fontSize:"9px", color:"#6366F1", marginTop:1 }}>🔥 Kehadiran naik 3% minggu ini</div>
            </div>
          </div>
          <div className="text-right">
            <div style={{ fontFamily:M, fontSize:"14px", fontWeight:700, color:"#6366F1" }}>83%</div>
            <div style={{ fontFamily:F, fontSize:"8px", color:"#94A3B8" }}>on-time rate</div>
          </div>
        </div>
        <div className="mt-2.5">
          <AniBar pct={83} color="#6366F1" track="rgba(99,102,241,0.1)"/>
        </div>
      </div>

      {/* Approval */}
      <div style={s2}><FCard>
        <div className="px-4 py-2.5 flex items-center gap-1.5" style={{ background:"linear-gradient(to right,rgba(238,242,255,0.8),#fff)", borderBottom:"1px solid rgba(0,0,0,0.04)" }}>
          <AlertCircle size={11} style={{ color:"#6366F1" }}/><span style={{ fontFamily:F, fontSize:"11px", fontWeight:700, color:"#1E1B4B" }}>Perlu Approval</span>
          <span className="ml-auto w-5 h-5 rounded-full bg-[#EF4444] flex items-center justify-center"><span style={{ fontFamily:F, fontSize:"8px", fontWeight:700, color:"#fff" }}>{PA.length}</span></span>
        </div>
        {PA.map((a,i)=>(
          <div key={i} className="flex items-center gap-3 px-4 py-3" style={{ borderBottom:i<PA.length-1?"1px solid rgba(0,0,0,0.04)":"none" }}>
            {a.urgent&&<div className="w-1.5 h-1.5 rounded-full bg-[#EF4444] shrink-0 animate-pulse"/>}
            <div className="flex-1"><div style={{ fontFamily:F, fontSize:"11px", fontWeight:600, color:"#0F172A" }}>{a.name}</div><div style={{ fontFamily:F, fontSize:"9px", color:"#94A3B8" }}>{a.type} · {a.days}</div></div>
            <button className="px-3 py-1.5 rounded-xl" style={{ background:"linear-gradient(135deg,#4F46E5,#818CF8)", boxShadow:"0 4px 12px rgba(99,102,241,0.3)" }}><span style={{ fontFamily:F, fontSize:"9px", fontWeight:700, color:"#fff" }}>Review</span></button>
          </div>
        ))}
      </FCard></div>

      {/* Team list */}
      <div style={s3}><FCard>
        <FHdr title="Kehadiran Tim" action="Detail"/>
        {TEAM.slice(0,3).map((m,i)=>(
          <div key={i} className="flex items-center gap-3 px-4 py-2.5" style={{ borderBottom:i<2?"1px solid rgba(0,0,0,0.03)":"none" }}>
            <Av name={m.name} g={m.g}/>
            <div className="flex-1 min-w-0">
              <div className="flex items-center gap-1"><span style={{ fontFamily:F, fontSize:"11px", fontWeight:600, color:"#0F172A" }}>{m.name.split(" ")[0]}</span>{m.streak>0&&<span style={{ fontSize:"9px" }}>🔥{m.streak}</span>}</div>
              <div style={{ fontFamily:F, fontSize:"9px", color:"#94A3B8" }}>{m.role}</div>
            </div>
            <Badge label={m.status}/>
          </div>
        ))}
      </FCard></div>

      {/* Pengumuman — read only */}
      <div style={useFadeSlide(320)}><AnnouncementBox canCreate={false}/></div>
    </div>
  );
}

function MgrTim() {
  const s0=useFadeSlide(0), s1=useFadeSlide(80), s2=useFadeSlide(160);
  return (
    <div className="pb-3 pt-3 px-3 space-y-3">
      <div style={s0} className="grid grid-cols-3 gap-2">
        {[{v:"12",l:"Anggota",c:"#6366F1"},{v:"10",l:"Hadir",c:"#22C55E"},{v:"83%",l:"On-time",c:"#818CF8"}].map(s=>(
          <div key={s.l} style={{ background:"#fff", borderRadius:16, boxShadow:CARD_SHADOW, padding:"12px 8px", textAlign:"center" }}>
            <div style={{ fontFamily:M, fontSize:"17px", fontWeight:700, color:s.c }}>{s.v}</div>
            <div style={{ fontFamily:F, fontSize:"8px", color:"#94A3B8" }}>{s.l}</div>
          </div>
        ))}
      </div>
      <div style={{ ...s1, borderRadius:16, padding:"12px 14px", background:"linear-gradient(135deg,#FFF7ED,#FFFBEB)", border:"1px solid rgba(245,158,11,0.2)" }}>
        <div className="flex items-center gap-2"><Award size={14} style={{ color:"#F59E0B" }}/><span style={{ fontFamily:F, fontSize:"11px", fontWeight:700, color:"#92400E" }}>Top Performer Minggu Ini</span></div>
        <div className="flex items-center gap-2 mt-2"><Av name="Rizky Kurniawan" g="from-[#818CF8] to-[#6366F1]"/><div><div style={{ fontFamily:F, fontSize:"11px", fontWeight:600, color:"#0F172A" }}>Rizky Kurniawan</div><div style={{ fontFamily:F, fontSize:"9px", color:"#94A3B8" }}>30 hari streak 🔥 · Skor 98%</div></div></div>
      </div>
      <div style={s2}><FCard>
        <FHdr title="Semua Anggota Tim"/>
        {TEAM.map((m,i)=>(
          <div key={i} className="px-4 py-3" style={{ borderBottom:i<TEAM.length-1?"1px solid rgba(0,0,0,0.03)":"none" }}>
            <div className="flex items-center gap-2.5 mb-2"><Av name={m.name} g={m.g}/><div className="flex-1 min-w-0"><div className="flex items-center gap-1"><span style={{ fontFamily:F, fontSize:"11px", fontWeight:600, color:"#0F172A" }}>{m.name}</span>{m.streak>0&&<span style={{ fontSize:"9px" }}>🔥</span>}</div><div style={{ fontFamily:F, fontSize:"9px", color:"#94A3B8" }}>{m.role} · {m.time}</div></div><Badge label={m.status}/></div>
            <AniBar pct={m.score} color={m.score>90?"#818CF8":m.score>80?"#06B6D4":"#F59E0B"} track="rgba(0,0,0,0.05)"/>
          </div>
        ))}
      </FCard></div>
    </div>
  );
}

function MgrApproval() {
  const initD=[{name:"Ahmad Fauzan",type:"Izin Terlambat",days:"1x",urgent:true,color:"#EF4444"},{name:"Laila Nuraini",type:"Perpanjang Tugas",days:"3 hari",urgent:false,color:"#8B5CF6"}];
  const [items,setItems]=useState(initD.map(a=>({ ...a, done:false, approved:false })));
  const act=(i:number,ok:boolean)=>setItems(p=>p.map((it,idx)=>idx===i?{...it,done:true,approved:ok}:it));
  const s0=useFadeSlide(0), s1=useFadeSlide(100);
  return (
    <div className="pb-3 pt-3 px-3 space-y-3">
      <div style={{ ...s0, borderRadius:20, padding:"14px 16px", background:"linear-gradient(135deg,#1E1B4B,#4338CA)" }}>
        <div style={{ fontFamily:F, fontSize:"11px", fontWeight:700, color:"#fff" }}>Approval Tim Saya</div>
        <div style={{ fontFamily:F, fontSize:"10px", color:"#A5B4FC", marginTop:1 }}>{items.filter(i=>!i.done).length} menunggu persetujuan</div>
      </div>
      <div style={s1}><FCard>
        {items.map((a,i)=>(
          <div key={i} className="px-4 py-3.5" style={{ borderBottom:i<items.length-1?"1px solid rgba(0,0,0,0.04)":"none" }}>
            <div className="flex items-center gap-2 mb-3">
              {a.urgent&&!a.done&&<div className="w-1.5 h-1.5 rounded-full bg-[#EF4444] animate-pulse shrink-0"/>}
              <div className="w-1 h-8 rounded-full shrink-0" style={{ background:a.done?(a.approved?"#22C55E":"#EF4444"):a.color }}/>
              <div className="flex-1"><div style={{ fontFamily:F, fontSize:"11px", fontWeight:600, color:"#0F172A" }}>{a.name}</div><div style={{ fontFamily:F, fontSize:"9px", color:"#94A3B8" }}>{a.type} · {a.days}</div></div>
              {a.done&&<Badge label={a.approved?"Disetujui":"Ditolak"}/>}
            </div>
            {!a.done&&(
              <div className="flex gap-2">
                <button onClick={()=>act(i,false)} className="flex-1 py-2 rounded-xl flex items-center justify-center gap-1.5" style={{ background:"rgba(239,68,68,0.08)", border:"1px solid rgba(239,68,68,0.18)" }}><X size={11} style={{ color:"#DC2626" }}/><span style={{ fontFamily:F, fontSize:"10px", fontWeight:700, color:"#DC2626" }}>Tolak</span></button>
                <button onClick={()=>act(i,true)} className="flex-1 py-2 rounded-xl flex items-center justify-center gap-1.5" style={{ background:"rgba(99,102,241,0.08)", border:"1px solid rgba(99,102,241,0.18)" }}><Check size={11} style={{ color:"#4F46E5" }}/><span style={{ fontFamily:F, fontSize:"10px", fontWeight:700, color:"#4F46E5" }}>Setujui</span></button>
              </div>
            )}
          </div>
        ))}
      </FCard></div>
    </div>
  );
}

function MgrLaporan() {
  const bars=[78,82,85,80,88,84,85];
  const s0=useFadeSlide(0), s1=useFadeSlide(80), s2=useFadeSlide(160);
  return (
    <div className="pb-3 pt-3 px-3 space-y-3">
      <div style={s0} className="grid grid-cols-2 gap-2">
        {[{l:"Avg On-time",v:"83%",d:"+2.1%",up:true,c:"#818CF8"},{l:"Absen Bulan",v:"3",d:"−40%",up:false,c:"#22C55E"},{l:"Approval",v:"14",d:"bulan ini",up:true,c:"#06B6D4"},{l:"Produktivitas",v:"High",d:"rating",up:true,c:"#F59E0B"}].map(k=>(
          <div key={k.l} style={{ background:"#fff", borderRadius:18, boxShadow:CARD_SHADOW, padding:"12px" }}>
            <div style={{ fontFamily:M, fontSize:"20px", fontWeight:700, color:k.c }}>{k.v}</div>
            <div style={{ fontFamily:F, fontSize:"10px", color:"#0F172A", marginTop:2 }}>{k.l}</div>
            <div style={{ fontFamily:F, fontSize:"9px", color:k.up?"#22C55E":"#EF4444", marginTop:2 }}>{k.up?"↑":"↓"} {k.d}</div>
          </div>
        ))}
      </div>
      <div style={s1}><FCard>
        <FHdr title="Tren Kehadiran Tim — 7 Hari"/>
        <div className="flex items-end gap-1.5 px-4 py-3" style={{ height:80 }}>
          {bars.map((v,i)=>{ const t=i===bars.length-1; return (
            <div key={i} className="flex-1 flex flex-col items-center gap-1">
              <div className="w-full rounded-lg" style={{ height:`${v}%`, background:t?"linear-gradient(to top,#4F46E5,#818CF8)":"rgba(99,102,241,0.15)", boxShadow:t?"0 4px 12px rgba(99,102,241,0.4)":"none" }}/>
              <span style={{ fontFamily:F, fontSize:"8px", color:t?"#6366F1":"#94A3B8", fontWeight:t?700:400 }}>{"SSRKJSM"[i]}</span>
            </div>
          ); })}
        </div>
      </FCard></div>
      <div style={s2}><FCard>
        <FHdr title="Ranking Performa Individu"/>
        {[...TEAM].sort((a,b)=>b.score-a.score).map((m,i)=>(
          <div key={i} className="flex items-center gap-3 px-4 py-2.5" style={{ borderBottom:i<TEAM.length-1?"1px solid rgba(0,0,0,0.03)":"none" }}>
            <span style={{ fontFamily:M, fontSize:"11px", fontWeight:700, color:"#94A3B8", width:18, textAlign:"center" }}>#{i+1}</span>
            <Av name={m.name} g={m.g}/>
            <div className="flex-1 min-w-0">
              <div style={{ fontFamily:F, fontSize:"11px", fontWeight:600, color:"#0F172A" }}>{m.name.split(" ")[0]}</div>
              <AniBar pct={m.score} color="#6366F1" track="rgba(0,0,0,0.05)"/>
            </div>
            <span style={{ fontFamily:M, fontSize:"11px", fontWeight:700, color:"#6366F1" }}>{m.score}%</span>
          </div>
        ))}
      </FCard></div>
    </div>
  );
}

/* ══════════════════════════════════════════
   KARYAWAN SCREENS
══════════════════════════════════════════ */
function ClockWidget({ clockedIn, clockTime, onClock }: { clockedIn:boolean; clockTime:string|null; onClock:()=>void }) {
  return (
    <FCard>
      <div className="px-4 py-4 text-center">
        <div style={{ fontFamily:F, fontSize:"9px", fontWeight:600, color:clockedIn?"#16A34A":"#94A3B8", letterSpacing:"0.1em" }}>
          {clockedIn?"✓ SUDAH CLOCK IN":"BELUM CLOCK IN"}
        </div>
        <div style={{ fontFamily:M, fontSize:"30px", fontWeight:700, color:"#0F172A", lineHeight:1, marginTop:4 }}>{timeStr}</div>
        <div style={{ fontFamily:F, fontSize:"10px", color:"#94A3B8", marginTop:3, marginBottom:14 }}>{dateStr}</div>
        <PrimaryBtn
          label={clockedIn?"Clock Out":"Clock In Sekarang"}
          icon={clockedIn?LogOut:LogIn}
          onClick={onClock}
          gradient={clockedIn?"linear-gradient(135deg,#EF4444,#DC2626)":"linear-gradient(135deg,#34D399,#10B981)"}
          shadow={clockedIn?"0 8px 24px rgba(239,68,68,0.28)":"0 8px 24px rgba(52,211,153,0.32)"}
        />
        {clockedIn&&clockTime&&(
          <div className="mt-3 px-3 py-2 rounded-xl" style={{ background:"rgba(34,197,94,0.08)", border:"1px solid rgba(34,197,94,0.18)" }}>
            <span style={{ fontFamily:F, fontSize:"10px", color:"#16A34A" }}>✓ Tercatat pukul <strong>{clockTime}</strong> · Tepat waktu</span>
          </div>
        )}
      </div>
    </FCard>
  );
}

function KaryawanBeranda({ clockedIn, clockTime, onClock }: { clockedIn:boolean; clockTime:string|null; onClock:()=>void }) {
  const s0=useFadeSlide(0), s1=useFadeSlide(80), s2=useFadeSlide(160), s3=useFadeSlide(240);
  return (
    <div className="pb-3 pt-3 px-3 space-y-3">
      <div style={{ ...s0, borderRadius:22, padding:"16px", background:"linear-gradient(135deg,#052E16 0%,#065F46 100%)", boxShadow:"0 8px 32px rgba(6,95,70,0.35)" }}>
        <div style={{ fontFamily:F, fontSize:"10px", color:"#6EE7B7", fontWeight:600, letterSpacing:"0.08em" }}>SELAMAT PAGI</div>
        <div style={{ fontFamily:F, fontSize:"15px", fontWeight:700, color:"#fff", marginTop:2 }}>Rizky Kurniawan 👋</div>
        <div className="flex items-center gap-1.5 mt-2"><MapPin size={9} style={{ color:"#6EE7B7" }}/><span style={{ fontFamily:F, fontSize:"9px", color:"rgba(255,255,255,0.5)" }}>Kantor Padang Barat · 08:00–17:00</span></div>
        <div className="flex items-center gap-1.5 mt-1"><Star size={9} style={{ color:"#FCD34D" }}/><span style={{ fontFamily:F, fontSize:"9px", color:"rgba(255,255,255,0.5)" }}>30 hari streak kehadiran 🔥</span></div>
      </div>
      <div style={s1}><ClockWidget clockedIn={clockedIn} clockTime={clockTime} onClock={onClock}/></div>
      <div style={s2} className="grid grid-cols-3 gap-2">
        {[{v:"30",l:"Streak",c:"#F59E0B"},{v:"4",l:"Cuti terpakai",c:"#0284C7"},{v:"8",l:"Sisa cuti",c:"#34D399"}].map(s=>(
          <div key={s.l} style={{ background:"#fff", borderRadius:14, boxShadow:CARD_SHADOW, padding:"10px 4px", textAlign:"center" }}>
            <div style={{ fontFamily:M, fontSize:"15px", fontWeight:700, color:s.c }}>{s.v}</div>
            <div style={{ fontFamily:F, fontSize:"8px", color:"#94A3B8", lineHeight:1.2, marginTop:2 }}>{s.l}</div>
          </div>
        ))}
      </div>
      <div style={s3}><FCard>
        <div className="px-4 py-2.5 flex items-center gap-2">
          <Sparkles size={12} style={{ color:"#34D399" }}/>
          <span style={{ fontFamily:F, fontSize:"11px", fontWeight:700, color:"#0F172A" }}>Performa Bulan Ini</span>
        </div>
        <div className="px-4 pb-3 space-y-2">
          {[{l:"Kehadiran",pct:96,c:"#34D399"},{l:"Ketepatan Waktu",pct:100,c:"#0284C7"},{l:"Produktivitas",pct:88,c:"#818CF8"}].map(p=>(
            <div key={p.l}>
              <div className="flex justify-between mb-1"><span style={{ fontFamily:F, fontSize:"10px", color:"#64748B" }}>{p.l}</span><span style={{ fontFamily:M, fontSize:"10px", fontWeight:700, color:p.c }}>{p.pct}%</span></div>
              <AniBar pct={p.pct} color={p.c} track="rgba(0,0,0,0.05)"/>
            </div>
          ))}
        </div>
      </FCard></div>

      {/* Pengumuman — read only */}
      <div style={useFadeSlide(400)}><AnnouncementBox canCreate={false}/></div>
    </div>
  );
}

function KaryawanAbsensi({ clockedIn, clockTime, onClock }: { clockedIn:boolean; clockTime:string|null; onClock:()=>void }) {
  const hist=[{day:"Min",date:"28 Jun",status:"Hadir",time:"07:51"},{day:"Sab",date:"27 Jun",status:"Hadir",time:"07:48"},{day:"Jum",date:"26 Jun",status:"Hadir",time:"07:55"},{day:"Kam",date:"25 Jun",status:"Terlambat",time:"08:12"},{day:"Rab",date:"24 Jun",status:"Hadir",time:"07:44"},{day:"Sel",date:"23 Jun",status:"Hadir",time:"07:50"}];
  const s0=useFadeSlide(0), s1=useFadeSlide(80), s2=useFadeSlide(160);
  return (
    <div className="pb-3 pt-3 px-3 space-y-3">
      <div style={s0}><ClockWidget clockedIn={clockedIn} clockTime={clockTime} onClock={onClock}/></div>
      <div style={s1} className="flex gap-2">
        {[{v:"26",l:"Hadir",c:"#22C55E"},{v:"1",l:"Terlambat",c:"#F59E0B"},{v:"0",l:"Absen",c:"#EF4444"}].map(s=>(
          <div key={s.l} className="flex-1 text-center" style={{ background:"#fff", borderRadius:14, boxShadow:CARD_SHADOW, padding:"10px 4px" }}>
            <div style={{ fontFamily:M, fontSize:"15px", fontWeight:700, color:s.c }}>{s.v}</div>
            <div style={{ fontFamily:F, fontSize:"8px", color:"#94A3B8" }}>{s.l}</div>
          </div>
        ))}
      </div>
      <div style={s2}><FCard>
        <FHdr title="Riwayat Bulan Ini" action="Unduh"/>
        {hist.map((h,i)=>(
          <div key={i} className="flex items-center gap-3 px-4 py-2.5" style={{ borderBottom:i<hist.length-1?"1px solid rgba(0,0,0,0.03)":"none" }}>
            <div className="text-center shrink-0" style={{ width:28 }}>
              <div style={{ fontFamily:F, fontSize:"8px", color:"#94A3B8" }}>{h.day}</div>
              <div style={{ fontFamily:F, fontSize:"12px", fontWeight:700, color:"#0F172A" }}>{h.date.split(" ")[0]}</div>
            </div>
            <div className="flex-1"><div style={{ fontFamily:F, fontSize:"10px", color:"#0F172A" }}>{h.date}</div></div>
            <div style={{ fontFamily:M, fontSize:"10px", color:"#64748B", marginRight:8 }}>{h.time}</div>
            <Badge label={h.status}/>
          </div>
        ))}
      </FCard></div>
    </div>
  );
}

function KaryawanCuti() {
  const leave=[{type:"Cuti Tahunan",used:4,total:12,color:"#0284C7"},{type:"Cuti Sakit",used:1,total:10,color:"#34D399"},{type:"Izin Khusus",used:0,total:3,color:"#8B5CF6"}];
  const reqs=[{type:"Cuti Tahunan",from:"01 Jul",to:"03 Jul",days:"3 hari",status:"Pending"},{type:"Cuti Sakit",from:"15 Jun",to:"15 Jun",days:"1 hari",status:"Disetujui"}];
  const s0=useFadeSlide(0), s1=useFadeSlide(100), s2=useFadeSlide(200);
  return (
    <div className="pb-3 pt-3 px-3 space-y-3">
      <div style={s0}><FCard>
        <FHdr title="Saldo Cuti"/>
        <div className="px-4 py-3 space-y-4">
          {leave.map((lb,i)=>{ const pct=((lb.total-lb.used)/lb.total)*100; return (
            <div key={i}>
              <div className="flex items-center justify-between mb-1.5">
                <span style={{ fontFamily:F, fontSize:"11px", color:"#0F172A", fontWeight:600 }}>{lb.type}</span>
                <span style={{ fontFamily:M, fontSize:"11px", fontWeight:700, color:lb.color }}>{lb.total-lb.used}/{lb.total} hari</span>
              </div>
              <AniBar pct={pct} color={lb.color}/>
            </div>
          ); })}
        </div>
      </FCard></div>
      <div style={s1}>
        <PrimaryBtn label="Ajukan Cuti Baru" icon={Plus} gradient="linear-gradient(135deg,#0284C7,#06B6D4)" shadow="0 8px 20px rgba(6,182,212,0.32)"/>
      </div>
      <div style={s2}><FCard>
        <FHdr title="Riwayat Pengajuan"/>
        {reqs.map((r,i)=>(
          <div key={i} className="px-4 py-3" style={{ borderBottom:i<reqs.length-1?"1px solid rgba(0,0,0,0.04)":"none" }}>
            <div className="flex items-center justify-between mb-1"><span style={{ fontFamily:F, fontSize:"11px", fontWeight:600, color:"#0F172A" }}>{r.type}</span><Badge label={r.status}/></div>
            <div style={{ fontFamily:F, fontSize:"10px", color:"#94A3B8" }}>{r.from} – {r.to} · {r.days}</div>
          </div>
        ))}
      </FCard></div>
    </div>
  );
}

function KaryawanGaji() {
  const items=[{l:"Gaji Pokok",v:"8.500.000",t:"+"},{l:"Tunjangan Makan",v:"750.000",t:"+"},{l:"Tunjangan Transport",v:"450.000",t:"+"},{l:"Lembur (4 jam)",v:"320.000",t:"+"},{l:"BPJS Kesehatan",v:"170.000",t:"−"},{l:"BPJS Ketenagakerjaan",v:"255.000",t:"−"},{l:"PPh 21",v:"680.000",t:"−"}];
  const s0=useFadeSlide(0), s1=useFadeSlide(100);
  return (
    <div className="pb-3 pt-3 px-3 space-y-3">
      <div style={{ ...s0, borderRadius:22, padding:"16px", background:"linear-gradient(135deg,#052E16,#065F46)", boxShadow:"0 8px 32px rgba(6,95,70,0.35)" }}>
        <div style={{ fontFamily:F, fontSize:"10px", color:"#6EE7B7", fontWeight:600, letterSpacing:"0.08em" }}>SLIP GAJI · JUNI 2026</div>
        <div style={{ fontFamily:F, fontSize:"11px", color:"rgba(255,255,255,0.45)", marginTop:2 }}>Rizky Kurniawan</div>
        <div style={{ fontFamily:M, fontSize:"28px", fontWeight:800, color:"#fff", marginTop:8, lineHeight:1 }}>Rp 8.915.000</div>
        <div style={{ fontFamily:F, fontSize:"10px", color:"#6EE7B7", marginTop:4 }}>Gaji bersih yang diterima</div>
        <div className="flex gap-2 mt-3">
          <button className="flex-1 py-2 rounded-xl flex items-center justify-center gap-1.5" style={{ background:"rgba(255,255,255,0.12)", border:"1px solid rgba(255,255,255,0.1)" }}><Download size={12} className="text-white"/><span style={{ fontFamily:F, fontSize:"10px", fontWeight:600, color:"#fff" }}>Unduh PDF</span></button>
          <button className="flex-1 py-2 rounded-xl flex items-center justify-center gap-1.5" style={{ background:"rgba(255,255,255,0.12)", border:"1px solid rgba(255,255,255,0.1)" }}><CreditCard size={12} className="text-white"/><span style={{ fontFamily:F, fontSize:"10px", fontWeight:600, color:"#fff" }}>Riwayat</span></button>
        </div>
      </div>
      <div style={s1}><FCard>
        <FHdr title="Rincian Komponen"/>
        {items.map((it,i)=>(
          <div key={i} className="flex items-center justify-between px-4 py-2.5" style={{ borderBottom:i<items.length-1?"1px solid rgba(0,0,0,0.03)":"none" }}>
            <span style={{ fontFamily:F, fontSize:"11px", color:"#64748B" }}>{it.l}</span>
            <span style={{ fontFamily:M, fontSize:"11px", fontWeight:600, color:it.t==="+"?"#0F172A":"#EF4444" }}>{it.t}Rp {it.v}</span>
          </div>
        ))}
        <div className="flex items-center justify-between px-4 py-3" style={{ borderTop:"2px solid rgba(0,0,0,0.04)" }}>
          <span style={{ fontFamily:F, fontSize:"12px", fontWeight:700, color:"#0F172A" }}>Total Bersih</span>
          <span style={{ fontFamily:M, fontSize:"14px", fontWeight:800, color:"#16A34A" }}>Rp 8.915.000</span>
        </div>
      </FCard></div>
    </div>
  );
}

/* ══════════════════════════════════════════
   PHONE SHELL
══════════════════════════════════════════ */
function PhoneShell({ navBg, accent, personLabel, role, children }: {
  navBg:string; accent:string; personLabel:string; role:string; children:React.ReactNode;
}) {
  return (
    <div className="flex flex-col items-center gap-3 shrink-0">
      {/* Role chip */}
      <div className="flex items-center gap-2 px-4 py-1.5 rounded-full" style={{ background:`${accent}15`, border:`1px solid ${accent}35`, backdropFilter:"blur(8px)" }}>
        <div className="w-2 h-2 rounded-full" style={{ background:accent, boxShadow:`0 0 6px ${accent}` }}/>
        <span style={{ fontFamily:F, fontSize:"12px", fontWeight:700, color:accent }}>{role}</span>
        <span style={{ fontFamily:F, fontSize:"12px", color:"rgba(255,255,255,0.4)" }}>·</span>
        <span style={{ fontFamily:F, fontSize:"11px", color:"rgba(255,255,255,0.6)" }}>{personLabel}</span>
      </div>

      {/* Frame */}
      <div className="relative" style={{ width:300, height:640 }}>
        <div className="absolute inset-0 rounded-[42px]" style={{ background:"#080808", boxShadow:`0 40px 80px rgba(0,0,0,0.5), 0 0 0 1px rgba(255,255,255,0.05), inset 0 1px 0 rgba(255,255,255,0.08), 0 0 40px ${accent}18` }}/>
        {/* Side buttons */}
        {[{s:"top-20 h-8",side:"-left-[3px] rounded-l-full"},{s:"top-32 h-8",side:"-left-[3px] rounded-l-full"},{s:"top-24 h-14",side:"-right-[3px] rounded-r-full"}].map((b,i)=>(
          <div key={i} className={`absolute w-[3px] ${b.s} ${b.side}`} style={{ background:"#1a1a1a" }}/>
        ))}
        {/* Screen */}
        <div className="absolute flex flex-col overflow-hidden" style={{ top:9, left:9, right:9, bottom:9, borderRadius:34 }}>
          {/* Status bar */}
          <div className="shrink-0 flex items-center justify-between px-4 pt-2.5 pb-1.5 relative" style={{ background:navBg }}>
            <span style={{ fontFamily:M, fontSize:"11px", fontWeight:600, color:"#fff" }}>{timeStr}</span>
            <div className="absolute left-1/2 -translate-x-1/2 top-2 rounded-full bg-black" style={{ width:80, height:18 }}/>
            <div className="flex items-center gap-1">
              <Wifi size={10} style={{ color:"rgba(255,255,255,0.6)" }}/>
              <Battery size={10} style={{ color:"rgba(255,255,255,0.6)" }}/>
            </div>
          </div>
          <div className="flex-1 min-h-0 flex flex-col" style={{ background:"#F8FAFC" }}>
            {children}
          </div>
        </div>
      </div>
    </div>
  );
}

/* ══════════════════════════════════════════
   3 COMPLETE APPS
══════════════════════════════════════════ */
/* ══════════════════════════════════════════
   HRD PAYROLL SCREEN
══════════════════════════════════════════ */
const PAYROLL_EMP = [
  { name:"Budi Santoso",   role:"Staff IT",        div:"Teknologi",  gross:8500000,  net:7350000,  status:"Diproses", g:"from-[#06B6D4] to-[#0284C7]" },
  { name:"Ahmad Fauzan",   role:"Manajer Ops",     div:"Operasional",gross:14000000, net:12100000, status:"Diproses", g:"from-[#F59E0B] to-[#D97706]" },
  { name:"Siti Ratnawati", role:"Analis Keuangan", div:"Keuangan",   gross:10000000, net:8650000,  status:"Diproses", g:"from-[#22C55E] to-[#16A34A]" },
  { name:"Rina Aulia",     role:"HRD Spesialis",   div:"SDM",        gross:9000000,  net:7800000,  status:"Pending",  g:"from-[#8B5CF6] to-[#7C3AED]" },
  { name:"Dewi Anggraini", role:"Legal Counsel",   div:"Legal",      gross:15500000, net:13400000, status:"Pending",  g:"from-[#EF4444] to-[#DC2626]" },
  { name:"Laila Nuraini",  role:"Akuntan",         div:"Keuangan",   gross:9200000,  net:7950000,  status:"Pending",  g:"from-[#06B6D4] to-[#0891B2]" },
  { name:"Rizky Kurniawan",role:"UI/UX Designer",  div:"Produk",     gross:12000000, net:10380000, status:"Diproses", g:"from-[#818CF8] to-[#6366F1]" },
];

const PAYROLL_ADJUSTMENTS = [
  { name:"Rizky Kurniawan", type:"Kenaikan Gaji",       amount:"+Rp 1.000.000", reason:"Performa Q2 terbaik",    status:"Menunggu Direktur" },
  { name:"Rina Aulia",      type:"Tunjangan Tambahan",  amount:"+Rp 500.000",   reason:"Sertifikasi HR baru",    status:"Menunggu Finance"  },
];

function fmt(n: number) {
  return "Rp " + (n/1000000).toFixed(1) + "M";
}

function HrdPayroll() {
  const [filter, setFilter] = useState("Semua");
  const [processed, setProcessed] = useState(false);
  const s0=useFadeSlide(0), s1=useFadeSlide(80), s2=useFadeSlide(160), s3=useFadeSlide(240);

  const totalGross = PAYROLL_EMP.reduce((a,e)=>a+e.gross,0);
  const totalNet   = PAYROLL_EMP.reduce((a,e)=>a+e.net,0);
  const diproses   = PAYROLL_EMP.filter(e=>e.status==="Diproses").length;
  const pending    = PAYROLL_EMP.filter(e=>e.status==="Pending").length;

  const shown = filter==="Semua" ? PAYROLL_EMP
    : PAYROLL_EMP.filter(e=>e.status===filter);

  return (
    <div className="pb-3 pt-3 px-3 space-y-3">
      {/* Summary banner */}
      <div style={{ ...s0, borderRadius:22, padding:"16px", background:"linear-gradient(135deg,#071830 0%,#0F4C75 100%)", boxShadow:"0 8px 32px rgba(15,76,117,0.4)" }}>
        <div className="flex items-center gap-2 mb-3">
          <div style={{ width:28, height:28, borderRadius:10, background:"rgba(6,182,212,0.2)", border:"1px solid rgba(6,182,212,0.3)", display:"flex", alignItems:"center", justifyContent:"center" }}>
            <Wallet size={13} style={{ color:"#06B6D4" }}/>
          </div>
          <div>
            <div style={{ fontFamily:F, fontSize:"11px", fontWeight:700, color:"#fff" }}>Payroll Juni 2026</div>
            <div style={{ fontFamily:F, fontSize:"9px", color:"#7DD3FC" }}>147 karyawan · Cut-off 25 Jun</div>
          </div>
        </div>
        <div style={{ fontFamily:F, fontSize:"9px", color:"#38BDF8", letterSpacing:"0.08em", marginBottom:4 }}>TOTAL PENGGAJIAN BERSIH</div>
        <div style={{ fontFamily:M, fontSize:"26px", fontWeight:800, color:"#fff", lineHeight:1 }}>
          {fmt(totalNet)}
        </div>
        <div style={{ fontFamily:F, fontSize:"9px", color:"rgba(255,255,255,0.4)", marginTop:3 }}>
          Gross: {fmt(totalGross)} · Potongan: {fmt(totalGross-totalNet)}
        </div>
        <div className="flex gap-2 mt-3">
          {[{v:diproses,l:"Diproses",c:"#34D399"},{v:pending,l:"Pending",c:"#FCD34D"},{v:PAYROLL_EMP.length,l:"Total",c:"#38BDF8"}].map(s=>(
            <div key={s.l} className="flex-1 rounded-xl py-2 text-center" style={{ background:"rgba(255,255,255,0.08)", border:"1px solid rgba(255,255,255,0.1)" }}>
              <div style={{ fontFamily:M, fontSize:"14px", fontWeight:800, color:s.c }}>{s.v}</div>
              <div style={{ fontFamily:F, fontSize:"8px", color:"rgba(255,255,255,0.4)" }}>{s.l}</div>
            </div>
          ))}
        </div>
      </div>

      {/* Process CTA */}
      {!processed ? (
        <div style={s1}>
          <PrimaryBtn
            label={`Proses ${pending} Gaji Tertunda`}
            icon={Send}
            gradient="linear-gradient(135deg,#0284C7,#06B6D4)"
            shadow="0 8px 20px rgba(6,182,212,0.32)"
            onClick={()=>setProcessed(true)}
          />
        </div>
      ) : (
        <div style={{ ...s1, borderRadius:16, padding:"12px 14px", background:"rgba(34,197,94,0.08)", border:"1px solid rgba(34,197,94,0.2)", display:"flex", alignItems:"center", gap:8 }}>
          <CheckCircle size={16} style={{ color:"#22C55E", flexShrink:0 }}/>
          <div>
            <div style={{ fontFamily:F, fontSize:"11px", fontWeight:700, color:"#16A34A" }}>Semua gaji berhasil diproses</div>
            <div style={{ fontFamily:F, fontSize:"9px", color:"#94A3B8" }}>Transfer dijadwalkan 28 Jun 2026</div>
          </div>
        </div>
      )}

      {/* Filter + list */}
      <div style={s2}>
        <div className="flex gap-1.5 mb-2.5 overflow-x-auto pb-0.5" style={{ scrollbarWidth:"none" }}>
          {["Semua","Diproses","Pending"].map(f=>(
            <button key={f} onClick={()=>setFilter(f)} className="shrink-0 px-3 py-1.5 rounded-full"
              style={{ fontFamily:F, fontSize:"10px", fontWeight:filter===f?700:400, background:filter===f?"#0284C7":"#fff", color:filter===f?"#fff":"#64748B", boxShadow:filter===f?"0 4px 12px rgba(2,132,199,0.3)":"0 1px 4px rgba(0,0,0,0.06)", border:"none" }}>
              {f}
            </button>
          ))}
        </div>
        <FCard>
          <FHdr title="Daftar Gaji Karyawan" action="Export"/>
          {shown.map((e,i)=>(
            <div key={i} className="px-4 py-3" style={{ borderBottom:i<shown.length-1?"1px solid rgba(0,0,0,0.03)":"none" }}>
              <div className="flex items-center gap-2.5 mb-1.5">
                <Av name={e.name} g={e.g}/>
                <div className="flex-1 min-w-0">
                  <div style={{ fontFamily:F, fontSize:"11px", fontWeight:600, color:"#0F172A" }}>{e.name}</div>
                  <div style={{ fontFamily:F, fontSize:"9px", color:"#94A3B8" }}>{e.role} · {e.div}</div>
                </div>
                <Badge label={e.status}/>
              </div>
              <div className="flex items-center justify-between px-1">
                <div>
                  <div style={{ fontFamily:F, fontSize:"8px", color:"#94A3B8" }}>Gross</div>
                  <div style={{ fontFamily:M, fontSize:"10px", color:"#64748B" }}>{fmt(e.gross)}</div>
                </div>
                <ArrowDownRight size={14} style={{ color:"#EF4444", opacity:0.5 }}/>
                <div className="text-right">
                  <div style={{ fontFamily:F, fontSize:"8px", color:"#94A3B8" }}>Take-home</div>
                  <div style={{ fontFamily:M, fontSize:"11px", fontWeight:700, color:"#16A34A" }}>{fmt(e.net)}</div>
                </div>
              </div>
            </div>
          ))}
        </FCard>
      </div>

      {/* Adjustments */}
      <div style={s3}><FCard>
        <FHdr title="Pengajuan Penyesuaian"/>
        {PAYROLL_ADJUSTMENTS.map((a,i)=>(
          <div key={i} className="px-4 py-3" style={{ borderBottom:i<PAYROLL_ADJUSTMENTS.length-1?"1px solid rgba(0,0,0,0.04)":"none" }}>
            <div className="flex items-start justify-between mb-1">
              <div>
                <div style={{ fontFamily:F, fontSize:"11px", fontWeight:600, color:"#0F172A" }}>{a.name}</div>
                <div style={{ fontFamily:F, fontSize:"9px", color:"#94A3B8" }}>{a.type} · {a.reason}</div>
              </div>
              <span style={{ fontFamily:M, fontSize:"11px", fontWeight:700, color:"#22C55E" }}>{a.amount}</span>
            </div>
            <div className="flex items-center gap-1.5 mt-1.5">
              <ClipboardList size={9} style={{ color:"#94A3B8" }}/>
              <span style={{ fontFamily:F, fontSize:"9px", color:"#94A3B8" }}>{a.status}</span>
            </div>
          </div>
        ))}
        <div className="px-4 py-3">
          <PrimaryBtn label="Ajukan Penyesuaian Baru" icon={Plus} gradient="linear-gradient(135deg,#0284C7,#06B6D4)" shadow="0 4px 12px rgba(6,182,212,0.25)"/>
        </div>
      </FCard></div>
    </div>
  );
}

/* ══════════════════════════════════════════
   MANAGER PAYROLL SCREEN
══════════════════════════════════════════ */
const TEAM_PAYROLL = [
  { name:"Rizky Kurniawan",role:"UI/UX Designer",  net:10380000, grade:"Senior",  g:"from-[#818CF8] to-[#6366F1]", score:98 },
  { name:"Laila Nuraini",  role:"Akuntan",          net:7950000,  grade:"Mid",     g:"from-[#34D399] to-[#10B981]", score:85 },
  { name:"Budi Santoso",   role:"Staff IT",         net:7350000,  grade:"Junior",  g:"from-[#06B6D4] to-[#0284C7]", score:91 },
  { name:"Ahmad Fauzan",   role:"Ops Coordinator",  net:8200000,  grade:"Mid",     g:"from-[#F59E0B] to-[#D97706]", score:72 },
  { name:"Rina Aulia",     role:"HR Specialist",    net:7800000,  grade:"Mid",     g:"from-[#F87171] to-[#EF4444]", score:88 },
];

const MGR_ADJ_PROPOSALS = [
  { name:"Rizky Kurniawan", current:10380000, proposed:11380000, reason:"Performa Q2 terbaik (98%)", done:false },
  { name:"Ahmad Fauzan",    current:8200000,  proposed:8200000,  reason:"Perlu evaluasi — keterlambatan berulang", done:false },
];

function MgrPayroll() {
  const [proposals, setProposals] = useState(MGR_ADJ_PROPOSALS.map(p=>({ ...p, submitted:false })));
  const s0=useFadeSlide(0), s1=useFadeSlide(80), s2=useFadeSlide(160), s3=useFadeSlide(240);

  const totalTeam = TEAM_PAYROLL.reduce((a,e)=>a+e.net,0);
  const grades = [
    { label:"Senior", count:1, color:"#818CF8" },
    { label:"Mid",    count:3, color:"#06B6D4"  },
    { label:"Junior", count:1, color:"#22C55E"  },
  ];

  function submit(i: number) {
    setProposals(p=>p.map((it,idx)=>idx===i?{...it,submitted:true}:it));
  }

  return (
    <div className="pb-3 pt-3 px-3 space-y-3">
      {/* Team cost summary */}
      <div style={{ ...s0, borderRadius:22, padding:"16px", background:"linear-gradient(135deg,#1E1B4B 0%,#3730A3 100%)", boxShadow:"0 8px 32px rgba(55,48,163,0.4)" }}>
        <div className="flex items-center gap-2 mb-3">
          <div style={{ width:28, height:28, borderRadius:10, background:"rgba(129,140,248,0.2)", border:"1px solid rgba(129,140,248,0.3)", display:"flex", alignItems:"center", justifyContent:"center" }}>
            <PieChart size={13} style={{ color:"#818CF8" }}/>
          </div>
          <div>
            <div style={{ fontFamily:F, fontSize:"11px", fontWeight:700, color:"#fff" }}>Payroll Tim Produk</div>
            <div style={{ fontFamily:F, fontSize:"9px", color:"#A5B4FC" }}>5 anggota · Juni 2026</div>
          </div>
        </div>
        <div style={{ fontFamily:F, fontSize:"9px", color:"#818CF8", letterSpacing:"0.08em", marginBottom:4 }}>TOTAL BIAYA TIM (TAKE-HOME)</div>
        <div style={{ fontFamily:M, fontSize:"24px", fontWeight:800, color:"#fff", lineHeight:1 }}>
          {fmt(totalTeam)}
        </div>
        <div style={{ fontFamily:F, fontSize:"9px", color:"rgba(255,255,255,0.35)", marginTop:3 }}>
          ↑ Rp 1.0M dari bulan lalu · +1.8%
        </div>
        {/* Grade distribution */}
        <div className="flex items-center gap-2 mt-3">
          {grades.map(g=>(
            <div key={g.label} className="flex items-center gap-1.5">
              <div className="w-2 h-2 rounded-full" style={{ background:g.color }}/>
              <span style={{ fontFamily:F, fontSize:"9px", color:"rgba(255,255,255,0.55)" }}>{g.count} {g.label}</span>
            </div>
          ))}
        </div>
      </div>

      {/* Salary distribution bar */}
      <div style={{ ...s1, borderRadius:18, padding:"14px", background:"#fff", boxShadow:CARD_SHADOW }}>
        <div style={{ fontFamily:F, fontSize:"11px", fontWeight:700, color:"#0F172A", marginBottom:10 }}>Distribusi Gaji Tim</div>
        {TEAM_PAYROLL.map((e,i)=>{
          const pct = Math.round((e.net / Math.max(...TEAM_PAYROLL.map(x=>x.net))) * 100);
          return (
            <div key={i} className="mb-2.5">
              <div className="flex items-center justify-between mb-1">
                <span style={{ fontFamily:F, fontSize:"10px", color:"#64748B" }}>{e.name.split(" ")[0]}</span>
                <div className="flex items-center gap-2">
                  <span className="px-1.5 py-0.5 rounded-full" style={{ fontFamily:F, fontSize:"8px", fontWeight:600, color:grades.find(g=>g.label===e.grade)?.color, background:`${grades.find(g=>g.label===e.grade)?.color}15` }}>{e.grade}</span>
                  <span style={{ fontFamily:M, fontSize:"10px", fontWeight:700, color:"#0F172A" }}>{fmt(e.net)}</span>
                </div>
              </div>
              <AniBar pct={pct} color={grades.find(g=>g.label===e.grade)?.color ?? "#6366F1"} track="rgba(0,0,0,0.05)"/>
            </div>
          );
        })}
      </div>

      {/* Adjustment proposals */}
      <div style={s2}><FCard>
        <div className="px-4 py-2.5 flex items-center gap-2" style={{ borderBottom:"1px solid rgba(0,0,0,0.04)", background:"linear-gradient(to right,rgba(238,242,255,0.6),#fff)" }}>
          <BadgeDollarSign size={13} style={{ color:"#6366F1" }}/>
          <span style={{ fontFamily:F, fontSize:"11px", fontWeight:700, color:"#1E1B4B" }}>Rekomendasi Penyesuaian</span>
          <span style={{ fontFamily:F, fontSize:"9px", color:"#94A3B8", marginLeft:"auto" }}>Kirim ke HR untuk diproses</span>
        </div>
        {proposals.map((p,i)=>(
          <div key={i} className="px-4 py-3.5" style={{ borderBottom:i<proposals.length-1?"1px solid rgba(0,0,0,0.04)":"none" }}>
            <div className="flex items-center gap-2.5 mb-2.5">
              <Av name={p.name} g={TEAM_PAYROLL.find(t=>t.name===p.name)?.g ?? "from-[#6366F1] to-[#4F46E5]"}/>
              <div className="flex-1">
                <div style={{ fontFamily:F, fontSize:"11px", fontWeight:600, color:"#0F172A" }}>{p.name}</div>
                <div style={{ fontFamily:F, fontSize:"9px", color:"#94A3B8", lineHeight:1.4 }}>{p.reason}</div>
              </div>
            </div>
            {/* Before → After */}
            <div className="flex items-center gap-2 mb-2.5 px-1">
              <div className="flex-1 rounded-xl py-2 text-center" style={{ background:"rgba(0,0,0,0.04)" }}>
                <div style={{ fontFamily:F, fontSize:"8px", color:"#94A3B8" }}>Saat ini</div>
                <div style={{ fontFamily:M, fontSize:"10px", color:"#64748B" }}>{fmt(p.current)}</div>
              </div>
              <ArrowUpRight size={14} style={{ color: p.proposed > p.current ? "#22C55E" : "#EF4444", flexShrink:0 }}/>
              <div className="flex-1 rounded-xl py-2 text-center" style={{ background: p.proposed > p.current ? "rgba(34,197,94,0.08)" : "rgba(239,68,68,0.06)", border:`1px solid ${p.proposed > p.current ? "rgba(34,197,94,0.2)" : "rgba(239,68,68,0.15)"}` }}>
                <div style={{ fontFamily:F, fontSize:"8px", color:"#94A3B8" }}>Usulan</div>
                <div style={{ fontFamily:M, fontSize:"10px", fontWeight:700, color: p.proposed > p.current ? "#16A34A" : "#DC2626" }}>{fmt(p.proposed)}</div>
              </div>
            </div>
            {!p.submitted ? (
              <button onClick={()=>submit(i)} className="w-full py-2 rounded-xl flex items-center justify-center gap-1.5"
                style={{ background: p.proposed > p.current ? "rgba(99,102,241,0.08)" : "rgba(239,68,68,0.07)", border:`1px solid ${p.proposed > p.current ? "rgba(99,102,241,0.2)" : "rgba(239,68,68,0.15)"}` }}>
                <Send size={11} style={{ color: p.proposed > p.current ? "#6366F1" : "#DC2626" }}/>
                <span style={{ fontFamily:F, fontSize:"10px", fontWeight:700, color: p.proposed > p.current ? "#6366F1" : "#DC2626" }}>
                  {p.proposed > p.current ? "Kirim Rekomendasi ke HR" : "Ajukan Evaluasi ke HR"}
                </span>
              </button>
            ) : (
              <div className="w-full py-2 rounded-xl flex items-center justify-center gap-1.5" style={{ background:"rgba(34,197,94,0.08)", border:"1px solid rgba(34,197,94,0.2)" }}>
                <Check size={11} style={{ color:"#22C55E" }}/>
                <span style={{ fontFamily:F, fontSize:"10px", fontWeight:700, color:"#16A34A" }}>Terkirim ke HR · Menunggu review</span>
              </div>
            )}
          </div>
        ))}
      </FCard></div>

      {/* Team insight */}
      <div style={{ ...s3, borderRadius:16, padding:"12px 14px", background:"linear-gradient(135deg,rgba(99,102,241,0.07),rgba(129,140,248,0.04))", border:"1px solid rgba(99,102,241,0.15)" }}>
        <div className="flex items-center gap-1.5 mb-1"><Sparkles size={11} style={{ color:"#818CF8" }}/><span style={{ fontFamily:F, fontSize:"10px", fontWeight:700, color:"#4F46E5" }}>AI Payroll Insight</span></div>
        <p style={{ fontFamily:F, fontSize:"10px", color:"#64748B", lineHeight:1.5 }}>
          Biaya gaji tim naik 1.8% — sesuai proyeksi anggaran Q3. Rizky Kurniawan layak mendapat kenaikan berdasarkan skor performa 98%.
        </p>
      </div>
    </div>
  );
}

function HrdPhone() {
  const [tab, setTab] = useState("beranda");
  const acc = "#06B6D4";
  const nav = [
    {id:"beranda",  label:"Beranda",  Icon:Home},
    {id:"karyawan", label:"Karyawan", Icon:Users},
    {id:"payroll",  label:"Payroll",  Icon:Wallet},
    {id:"approval", label:"Approval", Icon:CheckCircle},
    {id:"saya",     label:"Saya",     Icon:User},
  ];
  return (
    <PhoneShell navBg="#071830" accent={acc} personLabel="Siti Nurhaliza" role="HRD">
      <AppHeader navBg="#071830" accent={acc} roleLabel="HR Dashboard" initials="SN" name="Siti Nurhaliza"/>
      <div key={tab} className="flex-1 overflow-y-auto" style={{ scrollbarWidth:"none" }}>
        {tab==="beranda"  && <HrdBeranda/>}
        {tab==="karyawan" && <HrdKaryawan/>}
        {tab==="payroll"  && <HrdPayroll/>}
        {tab==="approval" && <HrdApproval/>}
        {tab==="saya"     && <ProfileScreen name="Siti Nurhaliza" role="HR Administrator" sub="Divisi SDM" color={acc} init="SN"/>}
      </div>
      <BottomNav nav={nav} tab={tab} onTab={setTab} accent={acc}/>
    </PhoneShell>
  );
}

function ManagerPhone() {
  const [tab, setTab] = useState("beranda");
  const acc = "#818CF8";
  const nav = [
    {id:"beranda",  label:"Beranda",  Icon:Home},
    {id:"tim",      label:"Tim Saya", Icon:Users},
    {id:"payroll",  label:"Payroll",  Icon:Wallet},
    {id:"laporan",  label:"Laporan",  Icon:BarChart3},
    {id:"saya",     label:"Saya",     Icon:User},
  ];
  return (
    <PhoneShell navBg="#1E1B4B" accent={acc} personLabel="Hendra Wijaya" role="Manager">
      <AppHeader navBg="#1E1B4B" accent={acc} roleLabel="Manager Portal" initials="HW" name="Hendra Wijaya"/>
      <div key={tab} className="flex-1 overflow-y-auto" style={{ scrollbarWidth:"none" }}>
        {tab==="beranda"  && <MgrBeranda/>}
        {tab==="tim"      && <MgrTim/>}
        {tab==="payroll"  && <MgrPayroll/>}
        {tab==="laporan"  && <MgrLaporan/>}
        {tab==="saya"     && <ProfileScreen name="Hendra Wijaya" role="Manajer Produk" sub="Tim Produk · 12 anggota" color={acc} init="HW"/>}
      </div>
      <BottomNav nav={nav} tab={tab} onTab={setTab} accent={acc}/>
    </PhoneShell>
  );
}

function KaryawanPhone() {
  const [tab, setTab] = useState("beranda");
  const [clockedIn, setClockedIn] = useState(false);
  const [clockTime, setClockTime] = useState<string|null>(null);
  const acc = "#34D399";
  function handleClock() { if(!clockedIn) setClockTime(timeStr); else setClockTime(null); setClockedIn(v=>!v); }
  const nav = [{id:"beranda",label:"Beranda",Icon:Home},{id:"absensi",label:"Absensi",Icon:CalendarCheck},{id:"cuti",label:"Cuti",Icon:FileText},{id:"gaji",label:"Gaji",Icon:Wallet},{id:"saya",label:"Saya",Icon:User}];
  return (
    <PhoneShell navBg="#052E16" accent={acc} personLabel="Rizky Kurniawan" role="Karyawan">
      <AppHeader navBg="#052E16" accent={acc} roleLabel="Portal Karyawan" initials="RK" name="Rizky Kurniawan"/>
      <div key={tab} className="flex-1 overflow-y-auto" style={{ scrollbarWidth:"none" }}>
        {tab==="beranda" && <KaryawanBeranda clockedIn={clockedIn} clockTime={clockTime} onClock={handleClock}/>}
        {tab==="absensi" && <KaryawanAbsensi clockedIn={clockedIn} clockTime={clockTime} onClock={handleClock}/>}
        {tab==="cuti"    && <KaryawanCuti/>}
        {tab==="gaji"    && <KaryawanGaji/>}
        {tab==="saya"    && <ProfileScreen name="Rizky Kurniawan" role="Desainer UI/UX" sub="Tim Produk · 30 hari streak 🔥" color={acc} init="RK"/>}
      </div>
      <BottomNav nav={nav} tab={tab} onTab={setTab} accent={acc}/>
    </PhoneShell>
  );
}

/* ══════════════════════════════════════════
   MAIN EXPORT
══════════════════════════════════════════ */
export function MobileApp() {
  return (
    <div className="size-full flex flex-col overflow-hidden" style={{ background:"linear-gradient(135deg,#0A0F1E 0%,#111827 60%,#0F1A2E 100%)" }}>
      {/* Top bar */}
      <div className="shrink-0 flex items-center justify-between px-10 py-4" style={{ borderBottom:"1px solid rgba(255,255,255,0.05)", backdropFilter:"blur(20px)" }}>
        <div className="flex items-center gap-3">
          <div className="w-9 h-9 rounded-2xl flex items-center justify-center" style={{ background:"linear-gradient(135deg,#06B6D4,#0284C7)", boxShadow:"0 4px 16px rgba(6,182,212,0.4)" }}>
            <Zap size={16} className="text-white fill-white"/>
          </div>
          <div>
            <div style={{ fontFamily:F, fontSize:"17px", fontWeight:800, color:"#fff", letterSpacing:"0.12em" }}>VAL<span style={{ color:"#06B6D4" }}>RYZE</span></div>
            <div style={{ fontFamily:F, fontSize:"10px", color:"rgba(255,255,255,0.35)" }}>HRIS Mobile — 3 Role Preview</div>
          </div>
        </div>
        <div className="flex items-center gap-8">
          {[{c:"#06B6D4",r:"HRD",tabs:"Beranda · Karyawan · Kehadiran · Approval · Saya"},{c:"#818CF8",r:"Manager",tabs:"Beranda · Tim · Approval · Laporan · Saya"},{c:"#34D399",r:"Karyawan",tabs:"Beranda · Absensi · Cuti · Gaji · Saya"}].map(x=>(
            <div key={x.r}>
              <div className="flex items-center gap-1.5 mb-0.5">
                <div className="w-1.5 h-1.5 rounded-full" style={{ background:x.c, boxShadow:`0 0 6px ${x.c}` }}/>
                <span style={{ fontFamily:F, fontSize:"12px", fontWeight:700, color:"rgba(255,255,255,0.8)" }}>{x.r}</span>
              </div>
              <div style={{ fontFamily:F, fontSize:"9px", color:"rgba(255,255,255,0.28)" }}>{x.tabs}</div>
            </div>
          ))}
        </div>
      </div>

      {/* 3 phones */}
      <div className="flex-1 overflow-y-auto flex items-start justify-center gap-10 py-8 px-6">
        <HrdPhone/>
        <ManagerPhone/>
        <KaryawanPhone/>
      </div>
    </div>
  );
}

export function MobilePreview() { return <MobileApp/>; }
