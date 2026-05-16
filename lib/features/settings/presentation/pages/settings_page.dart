import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/constants/app_colors.dart';
import '../../../../config/constants/app_spacing.dart';
import '../../../../config/constants/app_strings.dart';
import '../../../../config/constants/app_textstyle.dart';
import '../../../../core/services/seed_service.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal, 12.h, AppSpacing.screenHorizontal, AppSpacing.bottomNavSafePadding),
          children: [
            Text(AppStrings.settingsTitle,
                style: AppTextStyle.screenTitle()),
            SizedBox(height: 18.h),
            if (user != null) _ProfileCard(name: user.displayName, email: user.email, initials: user.initials, photoUrl: user.photoUrl),
            SizedBox(height: 24.h),
            _SectionLabel(AppStrings.preferences),
            _SettingItem(
              icon: Icons.palette_outlined,
              title: 'Appearance',
              trailing: Text('Light', style: AppTextStyle.helper()),
            ),
            _SettingItem(
              icon: Icons.translate_rounded,
              title: 'Language',
              trailing: Text('English', style: AppTextStyle.helper()),
            ),
            _ToggleItem(
              icon: Icons.download_for_offline_outlined,
              title: 'Offline downloads',
              initial: true,
              onChanged: (_) {},
            ),
            SizedBox(height: 18.h),
            _SectionLabel(AppStrings.notifications),
            _ToggleItem(
              icon: Icons.notifications_none_rounded,
              title: 'Push notifications',
              initial: true,
              onChanged: (_) {},
            ),
            _ToggleItem(
              icon: Icons.mail_outline_rounded,
              title: 'Weekly digest',
              initial: false,
              onChanged: (_) {},
            ),
            SizedBox(height: 18.h),
            _SectionLabel(AppStrings.support),
            _SettingItem(
              icon: Icons.add_box_outlined,
              title: 'Request a game',
              onTap: () {},
            ),
            _SettingItem(
              icon: Icons.help_outline_rounded,
              title: 'Help & FAQ',
              onTap: () {},
            ),
            _SettingItem(
              icon: Icons.star_outline_rounded,
              title: 'Rate BoardMate',
              onTap: () {},
            ),
            if (kDebugMode) ...[
              SizedBox(height: 18.h),
              _SectionLabel('Developer'),
              _SettingItem(
                icon: Icons.cloud_upload_outlined,
                title: 'Seed games to Firestore',
                onTap: () async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Seeding games…')),
                  );
                  try {
                    final n = await SeedService.instance.seedGames();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Seeded $n games.')),
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Seed failed: $e')),
                    );
                  }
                },
              ),
            ],
            SizedBox(height: 28.h),
            InkWell(
              onTap: () async {
                await ref.read(authNotifierProvider).signOut();
                if (!context.mounted) return;
                context.go('/sign-in');
              },
              borderRadius: BorderRadius.circular(AppSpacing.smallCardRadius),
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius:
                      BorderRadius.circular(AppSpacing.smallCardRadius),
                ),
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded,
                        color: AppColors.error, size: 20.sp),
                    SizedBox(width: 10.w),
                    Text(AppStrings.signOut,
                        style: AppTextStyle.bodyStrong(
                            color: AppColors.error)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Center(
              child: Text('${AppStrings.version} 1.0.0',
                  style: AppTextStyle.helper()),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.name,
    required this.email,
    required this.initials,
    required this.photoUrl,
  });
  final String name;
  final String email;
  final String initials;
  final String photoUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surfaceDefault,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withValues(alpha: 0.14),
              shape: BoxShape.circle,
              image: photoUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(photoUrl), fit: BoxFit.cover)
                  : null,
            ),
            alignment: Alignment.center,
            child: photoUrl.isEmpty
                ? Text(initials,
                    style: AppTextStyle.cardTitle(
                        color: AppColors.primaryGold))
                : null,
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name.isEmpty ? 'BoardMate user' : name,
                    style: AppTextStyle.cardTitle()),
                SizedBox(height: 2.h),
                Text(email, style: AppTextStyle.helper()),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: AppColors.textSecondary, size: 22.sp),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(4.w, 4.h, 4.w, 8.h),
        child: Text(label.toUpperCase(), style: AppTextStyle.label()),
      );
}

class _SettingItem extends StatelessWidget {
  const _SettingItem({
    required this.icon,
    required this.title,
    this.onTap,
    this.trailing,
  });
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceDefault,
        borderRadius: BorderRadius.circular(AppSpacing.smallCardRadius),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.smallCardRadius)),
        leading: Icon(icon, color: AppColors.secondaryNavy, size: 20.sp),
        title: Text(title, style: AppTextStyle.cardTitle()),
        trailing: trailing ??
            Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary, size: 22.sp),
      ),
    );
  }
}

class _ToggleItem extends StatefulWidget {
  const _ToggleItem({
    required this.icon,
    required this.title,
    required this.initial,
    required this.onChanged,
  });
  final IconData icon;
  final String title;
  final bool initial;
  final ValueChanged<bool> onChanged;

  @override
  State<_ToggleItem> createState() => _ToggleItemState();
}

class _ToggleItemState extends State<_ToggleItem> {
  late bool _value = widget.initial;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceDefault,
        borderRadius: BorderRadius.circular(AppSpacing.smallCardRadius),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: SwitchListTile.adaptive(
        value: _value,
        onChanged: (v) {
          setState(() => _value = v);
          widget.onChanged(v);
        },
        activeThumbColor: AppColors.primaryGold,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.smallCardRadius)),
        secondary: Icon(widget.icon,
            color: AppColors.secondaryNavy, size: 20.sp),
        title: Text(widget.title, style: AppTextStyle.cardTitle()),
      ),
    );
  }
}
