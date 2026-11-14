import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_neutral_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../cubit/create_clips_cubit.dart';
import '../cubit/create_clips_state.dart';

class _PlatformOption {
  final String id;
  final String label;
  final IconData icon;
  const _PlatformOption(this.id, this.label, this.icon);
}

const _platforms = [
  _PlatformOption('youtube', 'YouTube', Icons.smart_display_rounded),
  _PlatformOption('tiktok', 'TikTok', Icons.music_video_rounded),
  _PlatformOption('instagram', 'Instagram', Icons.camera_alt_rounded),
  _PlatformOption('facebook', 'Facebook', Icons.thumb_up_rounded),
  _PlatformOption('linkedin', 'LinkedIn', Icons.business_center_rounded),
];

const _timePresets = [
  (label: '7:00 AM', hour: 7, minute: 0, period: 'AM'),
  (label: '9:00 AM', hour: 9, minute: 0, period: 'AM'),
  (label: '12:00 PM', hour: 12, minute: 0, period: 'PM'),
  (label: '5:00 PM', hour: 5, minute: 0, period: 'PM'),
  (label: '8:00 PM', hour: 8, minute: 0, period: 'PM'),
  (label: '10:00 PM', hour: 10, minute: 0, period: 'PM'),
];

String _formatTime(int hour, int minute, String period) =>
    '${hour.toString().padLeft(2, '0')}:'
    '${minute.toString().padLeft(2, '0')} $period';

class AutoPublishCard extends StatelessWidget {
  const AutoPublishCard({super.key});

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    final cubit = context.read<CreateClipsCubit>();
    final state = context.watch<CreateClipsCubit>().state;
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: neutrals.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: neutrals.cardBorder),
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
                  Icons.send_rounded,
                  color: AppColors.accentGreen,
                  size: AppSizes.iconMd,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Auto-publish & schedule',
                      style: AppTextStyles.inputText(
                        neutrals,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Publish clips to your connected platforms '
                      'automatically after rendering.',
                      style: AppTextStyles.bodyMuted(neutrals),
                    ),
                  ],
                ),
              ),
              Switch(
                value: state.autoPublishSchedule,
                activeTrackColor: AppColors.accentGreen,
                onChanged: cubit.setAutoPublishSchedule,
              ),
            ],
          ),
          if (state.autoPublishSchedule) ...[
            const SizedBox(height: AppSizes.md),
            Text('Publish to', style: AppTextStyles.label(neutrals)),
            const SizedBox(height: AppSizes.sm),
            const _PlatformChips(),
            const SizedBox(height: AppSizes.md),
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: AppSizes.iconSm,
                  color: neutrals.textSecondary,
                ),
                const SizedBox(width: 6),
                Text('When to publish', style: AppTextStyles.label(neutrals)),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            const _WhenToPublishOptions(),
            if (state.whenToPublish == WhenToPublish.dailySchedule) ...[
              const SizedBox(height: AppSizes.md),
              const _DailyPublishTimeBox(),
            ],
            const SizedBox(height: AppSizes.sm),
            Text(
              state.whenToPublish == WhenToPublish.now
                  ? 'Each clip will be uploaded to your connected account '
                        'as soon as its render completes.'
                  : 'Clips will be queued and released one per day at '
                        '${_formatTime(state.dailyHour, state.dailyMinute, state.dailyPeriod)} '
                        '— great for keeping a consistent posting schedule.',
              style: AppTextStyles.bodyMuted(neutrals),
            ),
          ],
        ],
      ),
    );
  }
}

class _PlatformChips extends StatelessWidget {
  const _PlatformChips();

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    final cubit = context.read<CreateClipsCubit>();
    final state = context.watch<CreateClipsCubit>().state;
    return Wrap(
      spacing: AppSizes.sm,
      runSpacing: AppSizes.sm,
      children: _platforms.map((platform) {
        final connected = platform.id == 'youtube' && state.isYoutubeConnected;
        final selected = state.selectedPlatform == platform.id;
        return GestureDetector(
          onTap: connected
              ? () => cubit.setSelectedPlatform(platform.id)
              : () =>
                    AppSnackbar.info(context, '${platform.label} coming soon'),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.sm,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(
                color: selected ? AppColors.accentGreen : neutrals.cardBorder,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  platform.icon,
                  size: AppSizes.iconSm,
                  color: connected ? AppColors.accentGreen : neutrals.textHint,
                ),
                const SizedBox(width: 6),
                Text(
                  platform.label,
                  style: AppTextStyles.bodyMuted(neutrals).copyWith(
                    color: connected ? neutrals.textPrimary : neutrals.textHint,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                if (connected)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.accentGreen,
                      shape: BoxShape.circle,
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: neutrals.inputBackground,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Soon',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: neutrals.textHint,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _WhenToPublishOptions extends StatelessWidget {
  const _WhenToPublishOptions();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CreateClipsCubit>();
    final state = context.watch<CreateClipsCubit>().state;
    return Column(
      children: [
        _WhenOptionTile(
          title: 'Publish now',
          subtitle: 'Upload to your channel immediately after rendering',
          selected: state.whenToPublish == WhenToPublish.now,
          onTap: () => cubit.setWhenToPublish(WhenToPublish.now),
        ),
        const SizedBox(height: AppSizes.sm),
        _WhenOptionTile(
          title: 'Schedule one daily',
          subtitle: 'Automatically release one clip per day, one at a time',
          selected: state.whenToPublish == WhenToPublish.dailySchedule,
          trailing: state.whenToPublish == WhenToPublish.dailySchedule
              ? _TimeBadge(
                  label: _formatTime(
                    state.dailyHour,
                    state.dailyMinute,
                    state.dailyPeriod,
                  ),
                )
              : null,
          onTap: () => cubit.setWhenToPublish(WhenToPublish.dailySchedule),
        ),
      ],
    );
  }
}

class _WhenOptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final Widget? trailing;
  final VoidCallback onTap;
  const _WhenOptionTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.sm),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accentGreen.withValues(alpha: 0.08)
              : neutrals.inputBackground,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: selected ? AppColors.accentGreen : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? AppColors.accentGreen : neutrals.textHint,
              size: AppSizes.iconMd,
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.inputText(
                      neutrals,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(subtitle, style: AppTextStyles.bodyMuted(neutrals)),
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

class _TimeBadge extends StatelessWidget {
  final String label;
  const _TimeBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accentGreen.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.accentGreen,
          fontWeight: FontWeight.w700,
          fontSize: AppSizes.fontXs,
        ),
      ),
    );
  }
}

class _DailyPublishTimeBox extends StatelessWidget {
  const _DailyPublishTimeBox();

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    final cubit = context.read<CreateClipsCubit>();
    final state = context.watch<CreateClipsCubit>().state;
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: neutrals.inputBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: AppSizes.iconSm,
                color: neutrals.textSecondary,
              ),
              const SizedBox(width: 6),
              Text('Daily publish time', style: AppTextStyles.label(neutrals)),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Text('Quick presets', style: AppTextStyles.bodyMuted(neutrals)),
          const SizedBox(height: AppSizes.sm),
          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.sm,
            children: _timePresets.map((preset) {
              final selected =
                  state.dailyHour == preset.hour &&
                  state.dailyMinute == preset.minute &&
                  state.dailyPeriod == preset.period;
              return GestureDetector(
                onTap: () => cubit.setDailyTime(
                  hour: preset.hour,
                  minute: preset.minute,
                  period: preset.period,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.sm,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.accentGreen.withValues(alpha: 0.15)
                        : neutrals.cardBackground,
                    borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                    border: Border.all(
                      color: selected
                          ? AppColors.accentGreen
                          : neutrals.cardBorder,
                    ),
                  ),
                  child: Text(
                    preset.label,
                    style: AppTextStyles.bodyMuted(neutrals).copyWith(
                      color: selected ? AppColors.accentGreen : null,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            'Or set a custom time',
            style: AppTextStyles.bodyMuted(neutrals),
          ),
          const SizedBox(height: AppSizes.sm),
          Row(
            children: [
              _NumberDropdown(
                value: state.dailyHour,
                values: List.generate(12, (i) => i + 1),
                onChanged: (v) => cubit.setDailyTime(
                  hour: v,
                  minute: state.dailyMinute,
                  period: state.dailyPeriod,
                ),
              ),
              const SizedBox(width: 6),
              Text(':', style: AppTextStyles.inputText(neutrals)),
              const SizedBox(width: 6),
              _NumberDropdown(
                value: state.dailyMinute,
                values: const [0, 15, 30, 45],
                onChanged: (v) => cubit.setDailyTime(
                  hour: state.dailyHour,
                  minute: v,
                  period: state.dailyPeriod,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              _PeriodToggle(
                period: state.dailyPeriod,
                onChanged: (p) => cubit.setDailyTime(
                  hour: state.dailyHour,
                  minute: state.dailyMinute,
                  period: p,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NumberDropdown extends StatelessWidget {
  final int value;
  final List<int> values;
  final ValueChanged<int> onChanged;
  const _NumberDropdown({
    required this.value,
    required this.values,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
      decoration: BoxDecoration(
        color: neutrals.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(color: neutrals.inputBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          dropdownColor: neutrals.cardBackground,
          items: values
              .map(
                (v) => DropdownMenuItem(
                  value: v,
                  child: Text(
                    v.toString().padLeft(2, '0'),
                    style: AppTextStyles.inputText(neutrals),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

class _PeriodToggle extends StatelessWidget {
  final String period;
  final ValueChanged<String> onChanged;
  const _PeriodToggle({required this.period, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final neutrals = context.neutrals;
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: neutrals.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(color: neutrals.inputBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ['AM', 'PM'].map((p) {
          final selected = p == period;
          return GestureDetector(
            onTap: () => onChanged(p),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.sm,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: selected ? AppColors.accentGreen : Colors.transparent,
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: Text(
                p,
                style: AppTextStyles.bodyMuted(neutrals).copyWith(
                  color: selected ? Colors.black : neutrals.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
