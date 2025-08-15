import 'package:flutter/material.dart';
import 'package:manx_mate/core/extensions/context_extensions.dart';
import 'package:manx_mate/core/extensions/date_time_extensions.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_sizes.dart';

class OneRowCalendar extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const OneRowCalendar({super.key, required this.selectedDate, required this.onDateSelected});

  @override
  State<OneRowCalendar> createState() => _OneRowCalendarState();
}

class _OneRowCalendarState extends State<OneRowCalendar> {
  late DateTime visibleDate;

  @override
  void initState() {
    super.initState();
    visibleDate = widget.selectedDate;
  }

  List<DateTime> getCurrentWeekDates(DateTime date) {
    final int weekday = date.weekday;
    final DateTime sunday = date.subtract(Duration(days: weekday % 7));
    return List<DateTime>.generate(7, (int i) => sunday.add(Duration(days: i)));
  }

  void goToPreviousWeek() {
    setState(() {
      visibleDate = visibleDate.subtract(const Duration(days: 7));
    });
  }

  void goToNextWeek() {
    setState(() {
      visibleDate = visibleDate.add(const Duration(days: 7));
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<DateTime> weekDates = getCurrentWeekDates(visibleDate);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        border: Border.all(color: AppColors.primaryColor),
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
      ),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.chevron_left),
                onPressed: goToPreviousWeek,
              ),
              Expanded(
                child: Center(
                  child: Text(visibleDate.formattedMonthYear, style: context.txtTheme.titleMedium),
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.chevron_right),
                onPressed: goToNextWeek,
              ),
            ],
          ),
          Container(
            color: AppColors.primaryColor,
            padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <String>['S', 'M', 'T', 'W', 'T', 'F', 'S']
                  .map(
                    (String d) => Text(
                  d,
                  style: context.txtTheme.bodyMedium?.copyWith(color: AppColors.whiteColor),
                ),
              )
                  .toList(),
            ),
          ),
          const SizedBox(height: AppSizes.sm),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDates.map((DateTime date) {
              final bool isSelected = DateUtils.isSameDay(date, widget.selectedDate);

              return GestureDetector(
                onTap: () => widget.onDateSelected(date),
                child: Container(
                  width: 40,
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryColor : null,
                    borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: context.txtTheme.bodySmall?.copyWith(
                        color: isSelected ? AppColors.whiteColor : AppColors.blackColor,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: AppSizes.sm),
        ],
      ),
    );
  }
}