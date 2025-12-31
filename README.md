# Circular Timeline

A highly customizable, interactive circular visualization widget for Flutter.

`CircularTimeline` allows you to visualize a full year of data in a compact, aesthetic radial layout. It organizes time into concentric rings Seasons, Months, and Weeks and allows you to stack multiple data layers (like activity heatmaps) on the outside.

<p align="center">
<img src="https://github.com/user-attachments/assets/d471dd7d-2e98-474e-9396-b5fc42894705" width="400"/>
</p>

## Features

- **Yearly Overview:** Visualizes all 365/366 days of a specific year in a single view.
- **Hierarchical Rings:** Automatically renders rings for Seasons, Months, and Weeks.
- **Data Layers:** Add multiple custom rings (e.g., "Activity", "Sales", "Steps") to visualize daily intensity.
- **Interactive:** Hover or touch any segment to see precise details in the center dashboard.
- **Fully Customizable:** Control the width, color, and spacing of every ring via `TimelineConfig`.
- **Localization Support:** Easily translate or customize all text labels (Months, "Week", "Season", etc.) using `TimelineTextConfig`.
- **Responsive:** Automatically calculates the optimal size to fit the container.

## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  circular_timeline: ^0.0.1
```

Import the library in your Dart file:

```dart
import 'package:circular_timeline/circular_timeline.dart';

```

## Usage

### 1. Basic Usage

The simplest way to use the widget is to provide a `year` and a list of `TimelineLayer`s.

```dart
CircularTimeline(
  year: 2026,
  layers: [
    TimelineLayer(
      name: "Steps",
      color: Colors.blueAccent,
      data: {
        "1-1": 10.0,  // Jan 1st
        "1-2": 50.0,  // Jan 2nd
        "5-20": 100.0, // May 20th
      },
    ),
  ],
)

```

### 2. Custom Styling (`TimelineConfig`)

You can tweak dimensions and colors to fit your app's theme.

```dart
CircularTimeline(
  year: 2026,
  layers: myLayers,
  config: TimelineConfig(
    innerHoleRadius: 80,
    seasonWidth: 40,
    monthWidth: 30,
    weekWidth: 20,
    dataRingWidth: 15,
    backgroundColor: Colors.black, // Background of the circle
    monthTextColor: Colors.white,
    weekRingColor: Colors.grey.withOpacity(0.2),
  ),
)

```

### 3. Localization (`TimelineTextConfig`)

Customize or translate all labels displayed in the center dashboard.

```dart
CircularTimeline(
  year: 2026,
  layers: myLayers,
  textConfig: TimelineTextConfig(
    centerDefaultTitle: "Cronología",
    seasonLabel: "Temporada",
    monthLabel: "Mes",
    weekLabel: "Semana",
    weekNumberPrefix: "Semana",
    noDataText: "Sin datos",
  ),
)

```

## Data Format

Data for `TimelineLayer` is passed as a `Map<String, double>`, where the key is `"Month-Day"`.

```dart
{
  "1-1": 100.0, // January 1st
  "12-31": 50.0, // December 31st
}

```

_Note: The value (double) determines the opacity of the segment color. Values > 30 are rendered fully opaque, while lower values are slightly transparent._

## Additional information

### Contributions

Contributions are welcome! If you find a bug or want to add a feature (like animation support or custom segment builders), please feel free to file an issue or submit a pull request on the [GitHub repository](https://www.google.com/search?q=https://github.com/ShehanUdantha/circular_timeline).

### License

This package is released under the MIT License.
