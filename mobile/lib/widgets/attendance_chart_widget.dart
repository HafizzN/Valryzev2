import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'valryze_design.dart';

class AttendanceChartWidget extends StatefulWidget {
  final List<double> dataPoints; // e.g., percentages or counts [80, 95, 90, 100, 85]
  final List<String> labels; // e.g., ['Sen', 'Sel', 'Rab', 'Kam', 'Jum']
  final String title;
  final String suffix; // e.g. '%' or ' Orang'

  const AttendanceChartWidget({
    super.key,
    required this.dataPoints,
    required this.labels,
    this.title = 'STATISTIK KEHADIRAN PEKAN INI',
    this.suffix = '%',
  });

  @override
  State<AttendanceChartWidget> createState() => _AttendanceChartWidgetState();
}

class _AttendanceChartWidgetState extends State<AttendanceChartWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = ValryzeDesign.secondaryText(context);

    return ValryzeCard(
      padding: const EdgeInsets.all(16.0),
      child: Padding(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTapDown: (details) {
                final double width = context.size?.width ?? 300;
                final double x = details.localPosition.dx;
                final double stepX = (width - 40) / (widget.dataPoints.length - 1);
                
                int index = ((x - 20) / stepX).round();
                if (index >= 0 && index < widget.dataPoints.length) {
                  setState(() {
                    _selectedIndex = index;
                  });
                }
              },
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(double.infinity, 140),
                    painter: _ChartPainter(
                      dataPoints: widget.dataPoints,
                      labels: widget.labels,
                      progress: _animation.value,
                      selectedIndex: _selectedIndex,
                      suffix: widget.suffix,
                      isDark: isDark,
                    ),
                  );
                },
              ),
            ),
            if (_selectedIndex != null) ...[
              const SizedBox(height: 12),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
                  ),
                  child: Text(
                    '${widget.labels[_selectedIndex!]}: ${widget.dataPoints[_selectedIndex!].toStringAsFixed(0)}${widget.suffix}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<double> dataPoints;
  final List<String> labels;
  final double progress;
  final int? selectedIndex;
  final String suffix;
  final bool isDark;

  _ChartPainter({
    required this.dataPoints,
    required this.labels,
    required this.progress,
    required this.selectedIndex,
    required this.suffix,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final double width = size.width;
    final double height = size.height;
    final double paddingX = 20.0;
    final double paddingY = 20.0;

    final double chartWidth = width - (paddingX * 2);
    final double chartHeight = height - (paddingY * 2);

    final double stepX = chartWidth / (dataPoints.length - 1);

    // Find min and max for scaling (or default to 0-100)
    double maxVal = 100.0;
    for (var pt in dataPoints) {
      if (pt > maxVal) maxVal = pt;
    }
    double minVal = 0.0;

    final range = maxVal - minVal;

    List<Offset> points = [];
    for (int i = 0; i < dataPoints.length; i++) {
      final double x = paddingX + (i * stepX);
      // Interpolate based on max range, scaling from top of canvas
      final double normalizedVal = (dataPoints[i] - minVal) / range;
      final double y = paddingY + chartHeight - (normalizedVal * chartHeight * progress);
      points.add(Offset(x, y));
    }

    // 1. Draw Grid lines (Background)
    final gridPaint = Paint()
      ..color = isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03)
      ..strokeWidth = 1.0;

    for (int i = 0; i < 4; i++) {
      final double y = paddingY + (i * chartHeight / 3);
      canvas.drawLine(Offset(paddingX, y), Offset(width - paddingX, y), gridPaint);
    }

    // 2. Draw Fill Area (Gradient under the line)
    if (points.isNotEmpty) {
      final fillPath = Path()
        ..moveTo(points.first.dx, paddingY + chartHeight);
      for (var pt in points) {
        fillPath.lineTo(pt.dx, pt.dy);
      }
      fillPath.lineTo(points.last.dx, paddingY + chartHeight);
      fillPath.close();

      final fillPaint = Paint()
        ..shader = ui.Gradient.linear(
          Offset(width / 2, paddingY),
          Offset(width / 2, paddingY + chartHeight),
          [
            const Color(0xFF10B981).withOpacity(0.18),
            const Color(0xFF10B981).withOpacity(0.0),
          ],
        );
      canvas.drawPath(fillPath, fillPaint);
    }

    // 3. Draw Path Line (Emerald Glow)
    if (points.isNotEmpty) {
      final linePath = Path()..moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        // Draw standard straight line or smooth bezier
        linePath.lineTo(points[i].dx, points[i].dy);
      }

      final linePaint = Paint()
        ..color = const Color(0xFF10B981)
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      // Draw path
      canvas.drawPath(linePath, linePaint);
    }

    // 4. Draw data points (Circles)
    for (int i = 0; i < points.length; i++) {
      final isSelected = selectedIndex == i;
      final pt = points[i];

      // Draw dot shadow/glow
      final glowPaint = Paint()
        ..color = const Color(0xFF10B981).withOpacity(isSelected ? 0.4 : 0.15)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pt, isSelected ? 12 : 7, glowPaint);

      // Draw dot center
      final dotPaint = Paint()
        ..color = isSelected ? Colors.white : const Color(0xFF10B981)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pt, isSelected ? 5 : 3.5, dotPaint);

      // Draw value text above points (only for selected, or small text if space permits)
      if (isSelected) {
        final textSpan = TextSpan(
          text: '${dataPoints[i].toStringAsFixed(0)}$suffix',
          style: const TextStyle(
            color: Color(0xFF10B981),
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(canvas, Offset(pt.dx - (textPainter.width / 2), pt.dy - 18));
      }
    }

    // 5. Draw Labels (X Axis)
    final labelColor = isDark ? const Color(0xFF64748B) : const Color(0xFF475569);
    for (int i = 0; i < labels.length; i++) {
      final textSpan = TextSpan(
        text: labels[i],
        style: TextStyle(
          color: labelColor,
          fontSize: 9,
          fontWeight: FontWeight.w500,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      
      final x = paddingX + (i * stepX) - (textPainter.width / 2);
      final y = paddingY + chartHeight + 8.0;
      textPainter.paint(canvas, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.isDark != isDark;
  }
}
