interface AttendanceRowProps {
  name: string;
  role: string;
  division: string;
  clockIn: string;
  status: "Hadir" | "Pending" | "Cuti" | "Terlambat" | "Ditugaskan";
  hoverBg?: string;
  textPrimary?: string;
  textMuted?: string;
  textSubtle?: string;
}

const statusConfig = {
  Hadir:      { bg: "rgba(34,197,94,0.12)",   text: "#16A34A", dot: "#22C55E" },
  Pending:    { bg: "rgba(245,158,11,0.12)",  text: "#D97706", dot: "#F59E0B" },
  Cuti:       { bg: "rgba(100,116,139,0.12)", text: "#64748B", dot: "#94A3B8" },
  Terlambat:  { bg: "rgba(239,68,68,0.12)",   text: "#DC2626", dot: "#EF4444" },
  Ditugaskan: { bg: "rgba(59,130,246,0.12)",  text: "#2563EB", dot: "#3B82F6" },
};

function getInitials(name: string) {
  return name.split(" ").map(n => n[0]).slice(0, 2).join("").toUpperCase();
}

const avatarColors = [
  "from-[#22C55E] to-[#16A34A]",
  "from-[#0284C7] to-[#06B6D4]",
  "from-[#8B5CF6] to-[#7C3AED]",
  "from-[#F59E0B] to-[#D97706]",
  "from-[#EF4444] to-[#DC2626]",
  "from-[#06B6D4] to-[#0891B2]",
];

export function AttendanceRow({
  name, role, division, clockIn, status,
  hoverBg      = "#EFF6FF",
  textPrimary  = "#0F172A",
  textMuted    = "#64748B",
  textSubtle   = "#94A3B8",
}: AttendanceRowProps) {
  const cfg          = statusConfig[status];
  const colorIndex   = name.charCodeAt(0) % avatarColors.length;

  return (
    <div
      className="flex items-center gap-4 py-3 px-4 rounded-xl transition-colors duration-150"
      onMouseEnter={e => (e.currentTarget.style.background = hoverBg)}
      onMouseLeave={e => (e.currentTarget.style.background = "transparent")}
    >
      {/* Avatar */}
      <div className={`w-9 h-9 rounded-xl bg-gradient-to-br ${avatarColors[colorIndex]} flex items-center justify-center shrink-0`}>
        <span className="text-white" style={{ fontFamily: "'Plus Jakarta Sans',sans-serif", fontSize: "11px", fontWeight: 700 }}>
          {getInitials(name)}
        </span>
      </div>

      {/* Name & role */}
      <div className="flex-1 min-w-0">
        <div className="truncate" style={{ fontFamily: "'Plus Jakarta Sans',sans-serif", fontSize: "13px", fontWeight: 600, color: textPrimary }}>
          {name}
        </div>
        <div className="truncate" style={{ fontFamily: "'Plus Jakarta Sans',sans-serif", fontSize: "11px", color: textMuted }}>
          {role} · <span style={{ color: textSubtle }}>{division}</span>
        </div>
      </div>

      {/* Clock in — fixed width so column aligns */}
      <div className="w-16 shrink-0 text-right">
        <div style={{ fontFamily: "'JetBrains Mono',monospace", fontSize: "12px", fontWeight: 500, color: textPrimary }}>
          {clockIn}
        </div>
        <div style={{ fontFamily: "'Plus Jakarta Sans',sans-serif", fontSize: "10px", color: textSubtle }}>
          Clock in
        </div>
      </div>

      {/* Status badge — fixed width, right-aligned */}
      <div className="w-24 shrink-0 flex justify-center">
        <div className="flex items-center gap-1.5 px-2.5 py-1 rounded-full" style={{ background: cfg.bg }}>
          <div className="w-1.5 h-1.5 rounded-full shrink-0" style={{ background: cfg.dot }} />
          <span style={{ fontFamily: "'Plus Jakarta Sans',sans-serif", fontSize: "11px", fontWeight: 600, color: cfg.text }}>
            {status}
          </span>
        </div>
      </div>
    </div>
  );
}
