import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'valryze_design.dart';

class RealTimeClockCard extends StatefulWidget {
  const RealTimeClockCard({super.key});

  @override
  State<RealTimeClockCard> createState() => _RealTimeClockCardState();
}

class _RealTimeClockCardState extends State<RealTimeClockCard> {
  late Timer _timer;
  String _timeString = '';
  String _dateString = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateTime() {
    final DateTime now = DateTime.now();
    final String formattedTime = DateFormat('HH:mm:ss').format(now);
    final String formattedDate = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(now);
    if (mounted) {
      setState(() {
        _timeString = formattedTime;
        _dateString = formattedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ValryzeCard(
      padding: const EdgeInsets.symmetric(vertical: 22.0, horizontal: 18.0),
      child: Padding(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            Text(
              'WAKTU SEKARANG (WIB)',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: ValryzeDesign.secondaryText(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _timeString,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
                color: isDark ? const Color(0xFFF1F5F9) : ValryzeDesign.text,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _dateString,
              style: TextStyle(
                fontSize: 12,
                color: ValryzeDesign.secondaryText(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
