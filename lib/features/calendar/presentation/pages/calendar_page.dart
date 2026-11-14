import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_neutral_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/responsive_page.dart';
import '../widgets/schedule_clip_sheet.dart';

const _weekdayLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
const _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

bool _isBeforeToday(DateTime date) {
  final today = DateTime.now();
  return DateTime(
    date.year,
    date.month,
    date.day,
  ).isBefore(DateTime(today.year, today.month, today.day));
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _visibleMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );
  DateTime _selectedDate = DateTime.now();

  bool get _isOnCurrentMonth {
    final now = DateTime.now();
    return _visibleMonth.year == now.year && _visibleMonth.month == now.month;
  }

  void _goToMonth(int monthDelta) {
    setState(() {
      _visibleMonth = DateTime(
        _visibleMonth.year,
        _visibleMonth.month + monthDelta,
      );
    });
  }

  void _goToYear(int yearDelta) {
    setState(() {
      _visibleMonth = DateTime(
        _visibleMonth.year + yearDelta,
        _visibleMonth.month,
      );
    });
  }

  void _goToToday() {
    final now = DateTime.now();
    setState(() {
      _visibleMonth = DateTime(now.year, now.month);
      _selectedDate = now;
    });
  }

  void _selectDate(DateTime date) {
    setState(() => _selectedDate = date);
  }

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return ResponsivePage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: AppColors.accentGreen,
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Calendar',
                      style: AppTextStyles.heading(
                        neutrals,
                      ).copyWith(fontSize: AppSizes.fontXl),
                    ),
                    Text(
                      "Track when your clips are scheduled to go live and "
                      "what's already published.",
                      style: AppTextStyles.subtitle(neutrals),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.xl),
          _CalendarCard(
            visibleMonth: _visibleMonth,
            selectedDate: _selectedDate,
            isOnCurrentMonth: _isOnCurrentMonth,
            onPrevYear: () => _goToYear(-1),
            onPrevMonth: () => _goToMonth(-1),
            onToday: _goToToday,
            onNextMonth: () => _goToMonth(1),
            onNextYear: () => _goToYear(1),
            onSelectDate: _selectDate,
          ),
          const SizedBox(height: AppSizes.lg),
          _SelectedDayCard(selectedDate: _selectedDate),
        ],
      ),
    );
  }
}

class _CalendarCard extends StatelessWidget {
  final DateTime visibleMonth;
  final DateTime selectedDate;
  final bool isOnCurrentMonth;
  final VoidCallback onPrevYear;
  final VoidCallback onPrevMonth;
  final VoidCallback onToday;
  final VoidCallback onNextMonth;
  final VoidCallback onNextYear;
  final ValueChanged<DateTime> onSelectDate;

  const _CalendarCard({
    required this.visibleMonth,
    required this.selectedDate,
    required this.isOnCurrentMonth,
    required this.onPrevYear,
    required this.onPrevMonth,
    required this.onToday,
    required this.onNextMonth,
    required this.onNextYear,
    required this.onSelectDate,
  });

  /// 6 full weeks (42 days) starting from the Sunday on/before the 1st, so
  /// leading/trailing days from adjacent months fill out the grid.
  List<DateTime> _gridDays() {
    final firstOfMonth = DateTime(visibleMonth.year, visibleMonth.month, 1);
    // DateTime.weekday is 1 (Mon) .. 7 (Sun); Sunday-first grid needs 0..6.
    final leadingDays = firstOfMonth.weekday % 7;
    final gridStart = firstOfMonth.subtract(Duration(days: leadingDays));
    return List.generate(42, (i) => gridStart.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    final days = _gridDays();
    final today = DateTime.now();

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: neutrals.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: neutrals.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${_monthNames[visibleMonth.month - 1]} ${visibleMonth.year}',
                  style: AppTextStyles.inputText(neutrals).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: AppSizes.fontLg,
                  ),
                ),
              ),
              _NavIconButton(
                icon: Icons.keyboard_double_arrow_left_rounded,
                onTap: onPrevYear,
              ),
              _NavIconButton(
                icon: Icons.chevron_left_rounded,
                onTap: onPrevMonth,
              ),
              _TodayButton(onTap: onToday, isActive: !isOnCurrentMonth),
              _NavIconButton(
                icon: Icons.chevron_right_rounded,
                onTap: onNextMonth,
              ),
              _NavIconButton(
                icon: Icons.keyboard_double_arrow_right_rounded,
                onTap: onNextYear,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              for (final label in _weekdayLabels)
                Expanded(
                  child: Text(
                    label.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMuted(neutrals).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.xs),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 42,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.95,
            ),
            itemBuilder: (context, index) {
              final date = days[index];
              final isPast = _isBeforeToday(date);
              return _DayCell(
                date: date,
                inCurrentMonth: date.month == visibleMonth.month,
                isToday: _isSameDay(date, today),
                isSelected: _isSameDay(date, selectedDate),
                isPast: isPast,
                onTap: isPast ? null : () => onSelectDate(date),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _NavIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 18, color: neutrals.textSecondary),
        ),
      ),
    );
  }
}

class _TodayButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isActive;
  const _TodayButton({required this.onTap, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.sm,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.accentGreen.withValues(alpha: 0.12)
              : Colors.transparent,
          border: Border.all(
            color: isActive ? AppColors.accentGreen : neutrals.cardBorder,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusPill),
        ),
        child: Text(
          'Today',
          style: AppTextStyles.bodyMuted(neutrals).copyWith(
            fontWeight: FontWeight.w700,
            color: isActive ? AppColors.accentGreen : neutrals.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final DateTime date;
  final bool inCurrentMonth;
  final bool isToday;
  final bool isSelected;
  final bool isPast;
  final VoidCallback? onTap;

  const _DayCell({
    required this.date,
    required this.inCurrentMonth,
    required this.isToday,
    required this.isSelected,
    required this.isPast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    final Color background;
    final Color textColor;
    final FontWeight fontWeight;
    final Border? border;

    if (isToday) {
      background = AppColors.accentGreen;
      textColor = Colors.black;
      fontWeight = FontWeight.w800;
      border = null;
    } else if (isSelected) {
      background = AppColors.accentGreen.withValues(alpha: 0.14);
      textColor = AppColors.accentGreen;
      fontWeight = FontWeight.w700;
      border = Border.all(color: AppColors.accentGreen.withValues(alpha: 0.5));
    } else if (isPast) {
      background = Colors.transparent;
      textColor = neutrals.textHint.withValues(alpha: 0.5);
      fontWeight = FontWeight.w600;
      border = null;
    } else {
      background = Colors.transparent;
      textColor = inCurrentMonth ? neutrals.textPrimary : neutrals.textHint;
      fontWeight = FontWeight.w600;
      border = null;
    }

    return Padding(
      padding: const EdgeInsets.all(2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: background,
              border: border,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Text(
              '${date.day}',
              style: TextStyle(
                color: textColor,
                fontWeight: fontWeight,
                fontSize: AppSizes.fontSm,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectedDayCard extends StatelessWidget {
  final DateTime selectedDate;
  const _SelectedDayCard({required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    final weekday = const [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ][selectedDate.weekday - 1];
    final label =
        '$weekday, ${_monthNames[selectedDate.month - 1]} ${selectedDate.day}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: neutrals.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: neutrals.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: const Icon(
                  Icons.event_note_rounded,
                  color: AppColors.accentGreen,
                  size: AppSizes.iconSm,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.inputText(neutrals).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: AppSizes.fontMd,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () =>
                    showScheduleClipSheet(context, dateLabel: label),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.accentGreen,
                ),
                icon: const Icon(Icons.add_rounded, size: AppSizes.iconSm),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          _EmptyScheduleState(dateLabel: label),
        ],
      ),
    );
  }
}

class _EmptyScheduleState extends StatelessWidget {
  final String dateLabel;
  const _EmptyScheduleState({required this.dateLabel});

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xl),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: neutrals.inputBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_busy_outlined,
                color: neutrals.textHint,
                size: 28,
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              'No posts scheduled',
              style: AppTextStyles.inputText(
                neutrals,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Schedule a clip to see it show up here.',
              style: AppTextStyles.bodyMuted(neutrals),
            ),
            const SizedBox(height: AppSizes.lg),
            ElevatedButton.icon(
              onPressed: () =>
                  showScheduleClipSheet(context, dateLabel: dateLabel),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGreen,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                ),
              ),
              icon: const Icon(Icons.add_rounded, size: AppSizes.iconSm),
              label: const Text('Schedule a clip'),
            ),
          ],
        ),
      ),
    );
  }
}
