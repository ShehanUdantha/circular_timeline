import 'dart:math';
import 'package:flutter/material.dart';
import 'models.dart';

class TimelinePainter extends CustomPainter {
  final int year;
  final int totalDays;
  final List<TimelineLayer> layers;
  final List<TimelineSeason> seasons;
  final List<TimelineMonth> months;
  final TimelineConfig config;

  TimelinePainter({
    required this.year,
    required this.totalDays,
    required this.layers,
    required this.seasons,
    required this.months,
    required this.config,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paintObj = Paint()..style = PaintingStyle.stroke;

    // Draw optional background if defined
    if (config.backgroundColor != Colors.transparent) {
      final bgPaint =
          Paint()
            ..color = config.backgroundColor
            ..style = PaintingStyle.fill;
      canvas.drawCircle(center, size.width / 2, bgPaint);
    }

    final double anglePerDay = (2 * pi) / totalDays;
    const double gapSize = 0.005;

    // Helper: Draw Arc based on center-stroke logic
    void drawArc(
      double innerR,
      double width,
      double start,
      double sweep,
      Color c,
    ) {
      paintObj.color = c;
      paintObj.strokeWidth = width;
      paintObj.style = PaintingStyle.stroke;

      // Calculate radius to the center of the stroke
      double radius = innerR + (width / 2);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start - (pi / 2),
        sweep,
        false,
        paintObj,
      );
    }

    void drawRotatedText(
      String text,
      double r,
      double start,
      double sweep,
      double fontSize,
      Color color,
    ) {
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      double midAngle = start + (sweep / 2) - (pi / 2);
      double x = center.dx + (r) * cos(midAngle);
      double y = center.dy + (r) * sin(midAngle);

      canvas.save();
      canvas.translate(x, y);
      double rotation = midAngle + (pi / 2);
      if (midAngle > 0.5 * pi && midAngle < 1.5 * pi) rotation -= pi;
      canvas.rotate(rotation);
      canvas.translate(-tp.width / 2, -tp.height / 2);
      tp.paint(canvas, Offset.zero);
      canvas.restore();
    }

    // 1. SEASONS
    double currentR = config.innerHoleRadius;
    for (var season in seasons) {
      double startAngle = season.startDay * anglePerDay;
      double sweepAngle = season.durationDays * anglePerDay - gapSize;
      drawArc(
        currentR,
        config.seasonWidth,
        startAngle,
        sweepAngle,
        season.color,
      );
      drawRotatedText(
        season.name,
        currentR + config.seasonWidth / 2,
        startAngle,
        sweepAngle,
        18,
        Colors.white,
      );
    }

    // 2. MONTHS
    currentR += config.seasonWidth;
    int currentDayIndex = 0;
    for (var month in months) {
      double start = currentDayIndex * anglePerDay;
      double sweep = (month.days * anglePerDay) - gapSize;
      drawArc(currentR, config.monthWidth, start, sweep, config.monthRingColor);
      if (sweep > 0.1) {
        drawRotatedText(
          month.name,
          currentR + config.monthWidth / 2,
          start,
          sweep,
          14,
          config.monthTextColor,
        );
      }
      currentDayIndex += month.days;
    }

    // 3. WEEKS
    currentR += config.monthWidth;
    int weeksInYear = (totalDays / 7).ceil();

    for (int i = 0; i < weeksInYear; i++) {
      double start = (i * 7) * anglePerDay;
      double weekDuration = 7;
      if ((i * 7) + 7 > totalDays) {
        weekDuration = (totalDays - (i * 7)).toDouble();
      }

      double sweep = (weekDuration * anglePerDay) - (gapSize / 2);

      drawArc(currentR, config.weekWidth, start, sweep, config.weekRingColor);

      String label = (i + 1) > 52 ? "" : "${i + 1}";

      drawRotatedText(
        label,
        currentR + config.weekWidth / 2,
        start,
        sweep,
        8,
        config.weekTextColor,
      );
    }

    // 4. DATA LAYERS
    currentR += config.weekWidth;

    // Define a small gap for the data ring specifically
    // 0.003 radians is usually a good balance for 365 segments
    const double dataSegmentGap = 0.003;

    for (var layer in layers) {
      for (int d = 0; d < totalDays; d++) {
        DateTime dDate = DateTime(year, 1, 1).add(Duration(days: d));
        String key = "${dDate.month}-${dDate.day}";

        double start = d * anglePerDay;

        double sweep = anglePerDay - dataSegmentGap;

        // Safety check: ensure sweep is not negative (unlikely but good practice)
        if (sweep < 0) sweep = 0.001;

        if (layer.data.containsKey(key)) {
          double val = layer.data[key]!;
          // Draw the colored data segment
          Color c = layer.color.withOpacity(val > 30 ? 1.0 : 0.7);
          drawArc(currentR, config.dataRingWidth - 2, start, sweep, c);
        } else {
          // Draw the empty slot
          // Ensure config.emptyDataSlotColor is distinguishable from the background
          drawArc(
            currentR,
            config.dataRingWidth - 2,
            start,
            sweep,
            config.emptyDataSlotColor,
          );
        }
      }
      currentR += config.dataRingWidth;
    }
  }

  @override
  bool shouldRepaint(covariant TimelinePainter oldDelegate) => true;
}
