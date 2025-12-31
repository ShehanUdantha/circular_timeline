import 'package:flutter/material.dart';

/// Configuration class to customize dimensions AND colors.
class TimelineConfig {
  final double innerHoleRadius;
  final double seasonWidth;
  final double monthWidth;
  final double weekWidth;
  final double dataRingWidth;
  final double padding;

  final Color backgroundColor;
  final Color monthRingColor;
  final Color monthTextColor;
  final Color weekRingColor;
  final Color weekTextColor;
  final Color emptyDataSlotColor;

  const TimelineConfig({
    this.innerHoleRadius = 100,
    this.seasonWidth = 50,
    this.monthWidth = 40,
    this.weekWidth = 30,
    this.dataRingWidth = 25,
    this.padding = 20,
    this.backgroundColor = Colors.transparent,
    this.monthRingColor = const Color(0xFF686868),
    this.monthTextColor = Colors.white70,
    this.weekRingColor = const Color(0xFF7E7E7E),
    this.weekTextColor = Colors.white54,
    this.emptyDataSlotColor = const Color(0xFFA7A5A5),
  });
}

/// Configuration for all static text strings to support localization.
class TimelineTextConfig {
  final String centerDefaultTitle;
  final String centerDefaultSubtitle;
  final String seasonLabel;
  final String monthLabel;
  final String weekLabel;
  final String weekNumberPrefix;
  final String noDataText;

  const TimelineTextConfig({
    this.centerDefaultTitle = "Timeline",
    this.centerDefaultSubtitle = "Overview",
    this.seasonLabel = "Season",
    this.monthLabel = "Month",
    this.weekLabel = "Range",
    this.weekNumberPrefix = "Week",
    this.noDataText = "No Data",
  });
}

/// Represents a single layer of data.
class TimelineLayer {
  final String name;
  final Color color;
  final Map<String, double> data;

  TimelineLayer({required this.name, required this.color, required this.data});
}

/// Custom definition for a Season.
class TimelineSeason {
  final String name;
  final int startDay;
  final int durationDays;
  final Color color;

  TimelineSeason({
    required this.name,
    required this.startDay,
    required this.durationDays,
    required this.color,
  });
}

/// Custom definition for a Month.
class TimelineMonth {
  final String name;
  final int days;

  TimelineMonth({required this.name, required this.days});
}
