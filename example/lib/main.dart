import 'dart:math';

import 'package:flutter/material.dart';
import 'package:circular_timeline/circular_timeline.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Circular Timeline Example',
      home: Scaffold(
        appBar: AppBar(title: const Text("Yearly Sales Overview")),
        body: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // 1. Determine the smallest dimension of the screen
              double shortestSide = min(
                constraints.maxWidth,
                constraints.maxHeight,
              );

              // 2. Cap the size at 600 logical pixels so it doesn't get too big on Desktop
              double size = min(shortestSide, 600);
              return SizedBox(
                width: size,
                height: size,
                child: CircularTimeline(
                  year: 2026,
                  layers: [
                    TimelineLayer(
                      name: "Sales",
                      color: Colors.blue,
                      // MAP KEY:   "Month-Day"
                      // MAP VALUE: The specific data value for that date (e.g., total sales)
                      data: {
                        "1-1": 50.0, // On Jan 1st, value is 50
                        "1-2": 20.0, // On Jan 2nd, value is 20
                        "2-14":
                            150.0, // On Feb 14th, value is 150 (High intensity)
                        "5-20": 100.0, // On May 20th, value is 100
                        "12-25":
                            200.0, // On Dec 25th, value is 200 (Highest intensity)
                      },
                    ),
                    TimelineLayer(
                      name: "Visitors",
                      color: Colors.red,
                      data: {
                        "1-1": 10.0, // 10 visitors
                        "7-20": 80.0, // 80 visitors
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
