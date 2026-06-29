export const lightTheme = {
  isDark: false,

  // ── Navigation (topbar + sidebar — always deep navy) ──
  navBg:           "#071830",
  navBorder:       "rgba(6,182,212,0.12)",
  navItemText:     "rgba(255,255,255,0.45)",
  navItemActive:   "#06B6D4",
  navItemActiveBg: "rgba(6,182,212,0.13)",
  navItemHoverBg:  "rgba(255,255,255,0.05)",
  navItemHover:    "rgba(255,255,255,0.8)",
  navLabel:        "rgba(255,255,255,0.25)",
  navDivider:      "rgba(255,255,255,0.06)",
  navMono:         "rgba(255,255,255,0.25)",
  searchBg:        "rgba(255,255,255,0.06)",
  searchBorder:    "rgba(6,182,212,0.15)",
  searchFocus:     "#06B6D4",
  searchText:      "#FFFFFF",
  searchPlaceholder: "#475569",
  iconBtn:         "rgba(255,255,255,0.5)",
  iconBtnHoverBg:  "rgba(255,255,255,0.05)",

  // ── Content area ──
  contentBg:  "#EFF6FF",

  // ── Cards / surfaces ──
  cardBg:        "#FFFFFF",
  cardBorder:    "#DBEAFE",
  cardDivider:   "#EFF6FF",
  cardHoverRow:  "#EFF6FF",

  // ── Typography ──
  textPrimary: "#0F172A",
  textMuted:   "#64748B",
  textSubtle:  "#94A3B8",

  // ── Accent ──
  accentBlue:     "#0284C7",
  accentTeal:     "#06B6D4",
  accentBlueDim:  "#DBEAFE",
  accentTealDim:  "#CFFAFE",
  accentAmberDim: "#FEF3C7",

  // ── Hero gradient ──
  heroBg: "linear-gradient(135deg,#071830 0%,#0C2A4A 55%,#0369A1 100%)",
  heroSubText:  "#7DD3FC",
  heroLabel:    "#38BDF8",

  // ── Chart bars ──
  chartBarToday:     "linear-gradient(to top,#0284C7,#06B6D4)",
  chartBarRest:      "#DBEAFE",
  chartBarRestHover: "#BFDBFE",
  chartLabelToday:   "#0284C7",
  chartLabelRest:    "#94A3B8",
  chartDayToday:     "#0284C7",
  chartDayRest:      "#94A3B8",

  // ── AI Insight header ──
  insightHeaderBg: "linear-gradient(135deg,#071830 0%,#0369A1 100%)",
  insightHeaderBorder: "rgba(6,182,212,0.2)",

  // ── Insight card bgs ──
  insightWarningBg: "#FFFBEB",
  insightInfoBg:    "#ECFEFF",
  insightSuccessBg: "#F0FDF4",
  insightLabelBg:   "rgba(255,255,255,0.6)",

  // ── Status bar ──
  statusBarBg: "linear-gradient(to right,#071830,#0C2D5A,#0369A1)",
} as const;

export const darkTheme = {
  isDark: true,

  // ── Navigation — even darker to separate from content ──
  navBg:           "#030C16",
  navBorder:       "rgba(6,182,212,0.08)",
  navItemText:     "rgba(255,255,255,0.38)",
  navItemActive:   "#06B6D4",
  navItemActiveBg: "rgba(6,182,212,0.14)",
  navItemHoverBg:  "rgba(255,255,255,0.04)",
  navItemHover:    "rgba(255,255,255,0.72)",
  navLabel:        "rgba(255,255,255,0.2)",
  navDivider:      "rgba(255,255,255,0.05)",
  navMono:         "rgba(255,255,255,0.2)",
  searchBg:        "rgba(255,255,255,0.05)",
  searchBorder:    "rgba(6,182,212,0.18)",
  searchFocus:     "#06B6D4",
  searchText:      "#E2E8F0",
  searchPlaceholder: "#334155",
  iconBtn:         "rgba(255,255,255,0.4)",
  iconBtnHoverBg:  "rgba(255,255,255,0.04)",

  // ── Content area ──
  contentBg:  "#071524",

  // ── Cards / surfaces ──
  cardBg:       "#0D1F38",
  cardBorder:   "rgba(6,182,212,0.14)",
  cardDivider:  "rgba(6,182,212,0.07)",
  cardHoverRow: "rgba(6,182,212,0.07)",

  // ── Typography ──
  textPrimary: "#E2E8F0",
  textMuted:   "#94A3B8",
  textSubtle:  "#64748B",

  // ── Accent ──
  accentBlue:     "#0EA5E9",
  accentTeal:     "#06B6D4",
  accentBlueDim:  "rgba(14,165,233,0.18)",
  accentTealDim:  "rgba(6,182,212,0.18)",
  accentAmberDim: "rgba(245,158,11,0.18)",

  // ── Hero gradient ──
  heroBg: "linear-gradient(135deg,#030C16 0%,#071830 55%,#0C2A4A 100%)",
  heroSubText: "#7DD3FC",
  heroLabel:   "#38BDF8",

  // ── Chart bars ──
  chartBarToday:     "linear-gradient(to top,#0284C7,#06B6D4)",
  chartBarRest:      "rgba(6,182,212,0.14)",
  chartBarRestHover: "rgba(6,182,212,0.28)",
  chartLabelToday:   "#06B6D4",
  chartLabelRest:    "#475569",
  chartDayToday:     "#06B6D4",
  chartDayRest:      "#475569",

  // ── AI Insight header ──
  insightHeaderBg: "linear-gradient(135deg,#030C16 0%,#071830 100%)",
  insightHeaderBorder: "rgba(6,182,212,0.15)",

  // ── Insight card bgs ──
  insightWarningBg: "rgba(245,158,11,0.09)",
  insightInfoBg:    "rgba(6,182,212,0.09)",
  insightSuccessBg: "rgba(34,197,94,0.09)",
  insightLabelBg:   "rgba(255,255,255,0.08)",

  // ── Status bar ──
  statusBarBg: "linear-gradient(to right,#030C16,#071830,#0C2D5A)",
} as const;

export type AppTheme = typeof lightTheme;
