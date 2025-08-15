// Day Availability Model
import 'package:manx_mate/features/provider/model/time_range.dart';

class DayAvailability {
  final String day;
  final bool isSelected;
  final TimeRange? timeRange;

  DayAvailability({
    required this.day,
    this.isSelected = false,
    this.timeRange,
  });

  DayAvailability copyWith({
    String? day,
    bool? isSelected,
    TimeRange? timeRange,
  }) {
    return DayAvailability(
      day: day ?? this.day,
      isSelected: isSelected ?? this.isSelected,
      timeRange: timeRange ?? this.timeRange,
    );
  }
}