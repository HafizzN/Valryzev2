import { LucideIcon } from "lucide-react";

interface StatCardProps {
  label: string;
  value: string | number;
  sub?: string;
  subColor?: string;
  icon: LucideIcon;
  iconColor: string;
  iconBg: string;
  trend?: string;
}

export function StatCard({ label, value, sub, subColor, icon: Icon, iconColor, iconBg, trend }: StatCardProps) {
  return (
    <div className="bg-white rounded-2xl p-5 flex flex-col gap-4 border border-[#E8EDF3] shadow-sm hover:shadow-md transition-shadow duration-200">
      <div className="flex items-start justify-between">
        <div className={`w-10 h-10 rounded-xl ${iconBg} flex items-center justify-center`}>
          <Icon size={18} className={iconColor} strokeWidth={2} />
        </div>
        {trend && (
          <span className="text-[#22C55E] bg-[#22C55E]/10 px-2 py-0.5 rounded-full" style={{ fontFamily: "'Plus Jakarta Sans', sans-serif", fontSize: "11px", fontWeight: 600 }}>
            {trend}
          </span>
        )}
      </div>
      <div>
        <div style={{ fontFamily: "'Plus Jakarta Sans', sans-serif", fontSize: "28px", fontWeight: 700, lineHeight: 1.1 }} className="text-[#0D1B2A]">
          {value}
        </div>
        <div style={{ fontFamily: "'Plus Jakarta Sans', sans-serif", fontSize: "13px", fontWeight: 400 }} className="text-[#6B7A8D] mt-1">
          {label}
        </div>
        {sub && (
          <div style={{ fontFamily: "'Plus Jakarta Sans', sans-serif", fontSize: "11px", fontWeight: 500 }} className={`mt-1.5 ${subColor || "text-[#6B7A8D]"}`}>
            {sub}
          </div>
        )}
      </div>
    </div>
  );
}
