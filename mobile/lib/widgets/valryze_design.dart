// ignore_for_file: deprecated_member_use, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';

class ValryzeRoleStyle {
  const ValryzeRoleStyle({
    required this.role,
    required this.accent,
    required this.navBg,
    required this.heroStart,
    required this.heroEnd,
    required this.roleLabel,
  });

  final String role;
  final Color accent;
  final Color navBg;
  final Color heroStart;
  final Color heroEnd;
  final String roleLabel;
}

class ValryzeDesign {
  static const background = Color(0xFFEFF6FF);
  static const darkBackground = Color(0xFF071524);
  static const text = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);
  static const subtle = Color(0xFF94A3B8);
  static const cyan = Color(0xFF06B6D4);
  static const green = Color(0xFF34D399);
  static const indigo = Color(0xFF818CF8);
  static const danger = Color(0xFFEF4444);
  static const amber = Color(0xFFF59E0B);
  static const textPrimary = text;
  static const textMuted = muted;
  static const border = Color(0xFFDBEAFE);
  static const lightCard = Color(0xFFFFFFFF);
  static const darkCard = Color(0xFF0D1F38);
  static const lightSurface = Color(0xFFF8FBFF);
  static const darkSurface = Color(0xFF0A192D);
  static const phoneChrome = Color(0xFF0A0F1E);

  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.07),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 6,
      offset: const Offset(0, 1),
    ),
  ];

  static ValryzeRoleStyle get hrd => roleStyle('hrd');

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color pageBackground(BuildContext context) =>
      isDark(context) ? darkBackground : background;

  static Color cardBackground(BuildContext context) =>
      isDark(context) ? darkCard : lightCard;

  static Color fieldBackground(BuildContext context) =>
      isDark(context) ? darkSurface : lightCard;

  static Color primaryText(BuildContext context) =>
      isDark(context) ? const Color(0xFFE2E8F0) : text;

  static Color secondaryText(BuildContext context) =>
      isDark(context) ? const Color(0xFF94A3B8) : muted;

  static Color divider(BuildContext context) =>
      isDark(context) ? cyan.withOpacity(0.14) : border;

  static Color quietSurface(BuildContext context) =>
      isDark(context) ? darkSurface : lightSurface;

  static Color hoverSurface(BuildContext context) =>
      isDark(context) ? cyan.withOpacity(0.07) : const Color(0xFFEFF6FF);

  static BorderSide softBorder(BuildContext context) =>
      BorderSide(color: divider(context));

  static LinearGradient appBackdrop(BuildContext context) => LinearGradient(
    colors: isDark(context)
        ? const [Color(0xFF0A0F1E), Color(0xFF111827), Color(0xFF0F1A2E)]
        : const [Color(0xFFEFF6FF), Color(0xFFF8FBFF), Color(0xFFE0F2FE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static List<BoxShadow> cardShadow(BuildContext context) {
    if (isDark(context)) {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.28),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: cyan.withOpacity(0.03),
          blurRadius: 8,
          offset: const Offset(0, 1),
        ),
      ];
    }
    return softShadow;
  }

  static ValryzeRoleStyle roleStyle(String roleName) {
    switch (roleName) {
      case 'hrd':
        return const ValryzeRoleStyle(
          role: 'hrd',
          accent: cyan,
          navBg: Color(0xFF071830),
          heroStart: Color(0xFF071830),
          heroEnd: Color(0xFF0369A1),
          roleLabel: 'HR Dashboard',
        );
      case 'manager':
        return const ValryzeRoleStyle(
          role: 'manager',
          accent: indigo,
          navBg: Color(0xFF1E1B4B),
          heroStart: Color(0xFF1E1B4B),
          heroEnd: Color(0xFF4338CA),
          roleLabel: 'Manager Portal',
        );
      case 'karyawan':
      default:
        return const ValryzeRoleStyle(
          role: 'karyawan',
          accent: green,
          navBg: Color(0xFF052E16),
          heroStart: Color(0xFF064E3B),
          heroEnd: Color(0xFF047857),
          roleLabel: 'Portal Karyawan',
        );
    }
  }
}

class ValryzeLogoMark extends StatelessWidget {
  const ValryzeLogoMark({super.key, required this.color, this.size = 24});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.72)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.36),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.38),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(Icons.bolt_rounded, color: Colors.white, size: size * 0.58),
    );
  }
}

class ValryzeAvatar extends StatelessWidget {
  const ValryzeAvatar({
    super.key,
    required this.name,
    required this.color,
    this.photoUrl,
    this.size = 42,
    this.radius,
  });

  final String name;
  final Color color;
  final String? photoUrl;
  final double size;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;
    final effectiveSize = radius == null ? size : radius! * 2;
    return Container(
      width: effectiveSize,
      height: effectiveSize,
      decoration: BoxDecoration(
        gradient: hasPhoto
            ? null
            : LinearGradient(
                colors: [color, color.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(effectiveSize * 0.38),
        image: hasPhoto
            ? DecorationImage(image: NetworkImage(photoUrl!), fit: BoxFit.cover)
            : null,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.26),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: hasPhoto
          ? null
          : Center(
              child: Text(
                initials(name),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: effectiveSize * 0.28,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
    );
  }

  static String initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'VR';
    if (parts.length == 1)
      return parts.first
          .substring(0, parts.first.length >= 2 ? 2 : 1)
          .toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

class ValryzeAppHeader extends StatelessWidget {
  const ValryzeAppHeader({
    super.key,
    required this.style,
    required this.user,
    this.onNotifications,
    this.onRefresh,
    this.onLogout,
  });

  final ValryzeRoleStyle style;
  final Map<String, dynamic>? user;
  final VoidCallback? onNotifications;
  final VoidCallback? onRefresh;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        18,
        MediaQuery.of(context).padding.top + 12,
        16,
        14,
      ),
      decoration: BoxDecoration(
        color: style.navBg,
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ValryzeLogoMark(color: style.accent, size: 22),
              const SizedBox(width: 8),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.8,
                  ),
                  children: [
                    const TextSpan(text: 'VAL'),
                    TextSpan(
                      text: 'RYZE',
                      style: TextStyle(color: style.accent),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              if (onNotifications != null)
                _HeaderIcon(
                  icon: Icons.notifications_none_rounded,
                  onTap: onNotifications,
                ),
              if (onRefresh != null)
                _HeaderIcon(
                  icon: Icons.refresh_rounded,
                  onTap: onRefresh,
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Good Morning';
    if (hour < 15) return 'Good Afternoon';
    return 'Good Evening';
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white.withOpacity(0.72), size: 19),
    );
  }
}

class ValryzeHeroCard extends StatelessWidget {
  const ValryzeHeroCard({
    super.key,
    required this.style,
    required this.title,
    this.name,
    this.eyebrow,
    required this.subtitle,
    required this.stats,
  });

  final ValryzeRoleStyle style;
  final String title;
  final String? name;
  final String? eyebrow;
  final String subtitle;
  final List<ValryzeStatData> stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [style.heroStart, style.heroEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: style.heroEnd.withOpacity(0.34),
            blurRadius: 32,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (eyebrow ?? title).toUpperCase(),
            style: TextStyle(
              color: style.accent,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            name ?? title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.58),
              fontSize: 12,
            ),
          ),
          if (stats.isNotEmpty) ...[
            const SizedBox(height: 18),
            Row(
              children: stats
                  .map(
                    (stat) => Expanded(
                      child: Container(
                        margin: EdgeInsets.only(
                          right: stat == stats.last ? 0 : 9,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.12),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              stat.value,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: stat.color ?? style.accent,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              stat.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class ValryzeStatData {
  const ValryzeStatData({required this.value, required this.label, this.color});

  final String value;
  final String label;
  final Color? color;
}

class ValryzeCard extends StatelessWidget {
  const ValryzeCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.margin,
    this.radius = 20,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: ValryzeDesign.cardBackground(context),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: ValryzeDesign.divider(context)),
        boxShadow: ValryzeDesign.cardShadow(context),
      ),
      child: child,
    );
  }
}

class ValryzeStatusBadge extends StatelessWidget {
  const ValryzeStatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 11),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class ValryzeQuickTile extends StatelessWidget {
  const ValryzeQuickTile({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ValryzeDesign.cardBackground(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: ValryzeDesign.divider(context)),
          boxShadow: ValryzeDesign.cardShadow(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: color, size: 19),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ).copyWith(color: ValryzeDesign.primaryText(context)),
            ),
          ],
        ),
      ),
    );
  }
}

class ValryzeSectionHeader extends StatelessWidget {
  const ValryzeSectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: ValryzeDesign.primaryText(context),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          if (action != null)
            InkWell(
              onTap: onAction,
              borderRadius: BorderRadius.circular(999),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  action!,
                  style: const TextStyle(
                    color: ValryzeDesign.cyan,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
