import 'dart:math';
import 'package:flutter/material.dart';
import 'models.dart';
import 'timeline_painter.dart';

class CircularTimeline extends StatefulWidget {
  final int year;
  final List<TimelineLayer> layers;
  final TimelineConfig config;
  final TimelineTextConfig textConfig;
  final List<TimelineSeason>? seasons;
  final List<TimelineMonth>? months;

  const CircularTimeline({
    super.key,
    required this.year,
    required this.layers,
    this.config = const TimelineConfig(),
    this.textConfig = const TimelineTextConfig(),
    this.seasons,
    this.months,
  });

  @override
  State<CircularTimeline> createState() => _CircularTimelineState();
}

class _CircularTimelineState extends State<CircularTimeline> {
  late double virtualSize;
  late int totalDaysInYear;
  late List<TimelineSeason> activeSeasons;
  late List<TimelineMonth> activeMonths;

  // Interaction State
  late String centerLabel;
  late String centerSubLabel;
  late Color centerColor;

  @override
  void initState() {
    super.initState();
    centerLabel = widget.textConfig.centerDefaultTitle;
    centerSubLabel = widget.textConfig.centerDefaultSubtitle;
    centerColor = Colors.grey;
    _initYearLogic();
    _initConfig();
    _calculateOptimalSize();
  }

  @override
  void didUpdateWidget(covariant CircularTimeline oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.year != widget.year) _initYearLogic();
    _initConfig();
    _calculateOptimalSize();

    // Whenever the widget rebuilds (e.g., Language Change), we force the center text back to the default Title/Subtitle.
    // Since 'widget.textConfig' now contains the new language strings,this effectively translates the center text instantly.
    setState(() {
      centerLabel = widget.textConfig.centerDefaultTitle;
      centerSubLabel = widget.textConfig.centerDefaultSubtitle;
      centerColor = Colors.grey;
    });
  }

  void _initYearLogic() {
    totalDaysInYear =
        DateTime(
          widget.year + 1,
          1,
          1,
        ).difference(DateTime(widget.year, 1, 1)).inDays;
  }

  void _initConfig() {
    activeSeasons =
        widget.seasons ??
        [
          TimelineSeason(
            name: 'Winter',
            startDay: 334,
            durationDays: 90,
            color: const Color(0xFFF5DDB5),
          ),
          TimelineSeason(
            name: 'Spring',
            startDay: 59,
            durationDays: 92,
            color: const Color(0xFFF2C263),
          ),
          TimelineSeason(
            name: 'Summer',
            startDay: 151,
            durationDays: 92,
            color: const Color(0xFFE88A4F),
          ),
          TimelineSeason(
            name: 'Fall',
            startDay: 243,
            durationDays: 91,
            color: const Color(0xFFD65D39),
          ),
        ];

    if (widget.months != null) {
      activeMonths = widget.months!;
    } else {
      List<String> names = [
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec",
      ];
      activeMonths = List.generate(12, (i) {
        int days = DateUtils.getDaysInMonth(widget.year, i + 1);
        return TimelineMonth(name: names[i], days: days);
      });
    }
  }

  void _calculateOptimalSize() {
    double totalRadius =
        widget.config.innerHoleRadius +
        widget.config.seasonWidth +
        widget.config.monthWidth +
        widget.config.weekWidth;
    totalRadius += (widget.layers.length * widget.config.dataRingWidth);
    virtualSize = (totalRadius * 2) + widget.config.padding;
  }

  void _handleInput(Offset localPosition) {
    final center = Offset(virtualSize / 2, virtualSize / 2);
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;
    final distance = sqrt(dx * dx + dy * dy);

    double angle = atan2(dy, dx) + pi / 2;
    if (angle < 0) angle += 2 * pi;

    int dayIndex = ((angle / (2 * pi)) * totalDaysInYear).floor().clamp(
      0,
      totalDaysInYear - 1,
    );
    DateTime date = DateTime(widget.year, 1, 1).add(Duration(days: dayIndex));
    String key = "${date.month}-${date.day}";

    // Use radius + half width to determine hit zones
    double seasonR = widget.config.innerHoleRadius + widget.config.seasonWidth;
    double monthR = seasonR + widget.config.monthWidth;
    double weekR = monthR + widget.config.weekWidth;

    String label = "";
    String sub = "";
    Color color = Colors.grey;

    if (distance < widget.config.innerHoleRadius) {
      label = widget.textConfig.centerDefaultTitle;
      sub = "${widget.year}";
    } else if (distance < seasonR) {
      var season = _findSeasonForDay(dayIndex);
      label = season?.name ?? "";
      sub = widget.textConfig.seasonLabel;
      color = season?.color ?? Colors.grey;
    } else if (distance < monthR) {
      var month = _findMonthForDay(dayIndex);
      label = month?.name ?? "";
      sub = widget.textConfig.monthLabel;
    } else if (distance < weekR) {
      label = "${widget.textConfig.weekNumberPrefix} ${_getWeekNumber(date)}";
      sub = widget.textConfig.weekLabel;
    } else {
      double currentRingStart = weekR;
      bool foundLayer = false;
      for (var layer in widget.layers) {
        double currentRingEnd = currentRingStart + widget.config.dataRingWidth;
        if (distance >= currentRingStart && distance < currentRingEnd) {
          foundLayer = true;
          double? val = layer.data[key];
          label = layer.name;
          color = layer.color;
          if (val != null) {
            sub = "${date.year}/${date.month}/${date.day}: ${val.toInt()}";
          } else {
            sub =
                "${date.year}/${date.month}/${date.day}: ${widget.textConfig.noDataText}";
            color = layer.color.withOpacity(0.5);
          }
          break;
        }
        currentRingStart += widget.config.dataRingWidth;
      }
      if (!foundLayer) {
        label = widget.textConfig.centerDefaultTitle;
        sub = widget.textConfig.centerDefaultSubtitle;
      }
    }

    if (label != centerLabel || sub != centerSubLabel) {
      setState(() {
        centerLabel = label;
        centerSubLabel = sub;
        centerColor = color;
      });
    }
  }

  TimelineSeason? _findSeasonForDay(int dayIndex) {
    for (var s in activeSeasons) {
      int end = s.startDay + s.durationDays;
      if (end > totalDaysInYear) {
        if (dayIndex >= s.startDay || dayIndex < (end - totalDaysInYear)) {
          return s;
        }
      } else {
        if (dayIndex >= s.startDay && dayIndex < end) return s;
      }
    }
    return null;
  }

  TimelineMonth? _findMonthForDay(int dayIndex) {
    int currentCount = 0;
    for (var m in activeMonths) {
      if (dayIndex >= currentCount && dayIndex < currentCount + m.days) {
        return m;
      }
      currentCount += m.days;
    }
    return null;
  }

  int _getWeekNumber(DateTime d) =>
      ((int.parse("${d.difference(DateTime(d.year, 1, 1)).inDays}") + 1) / 7)
          .ceil();

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: virtualSize,
        height: virtualSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            MouseRegion(
              onHover: (e) => _handleInput(e.localPosition),
              child: GestureDetector(
                onPanUpdate: (d) => _handleInput(d.localPosition),
                onTapDown: (d) => _handleInput(d.localPosition),
                child: CustomPaint(
                  size: Size(virtualSize, virtualSize),
                  painter: TimelinePainter(
                    year: widget.year,
                    totalDays: totalDaysInYear,
                    layers: widget.layers,
                    seasons: activeSeasons,
                    months: activeMonths,
                    config: widget.config,
                  ),
                ),
              ),
            ),
            IgnorePointer(
              child: Container(
                width: widget.config.innerHoleRadius * 1.8,
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      centerLabel,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: centerColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    Text(
                      centerSubLabel,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
