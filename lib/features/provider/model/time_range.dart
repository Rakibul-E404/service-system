// Time Range Model
class TimeRange {
  final String start;
  final String end;

  TimeRange({required this.start, required this.end});

  @override
  String toString() => '$start - $end';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is TimeRange && start == other.start && end == other.end;

  @override
  int get hashCode => start.hashCode ^ end.hashCode;
}