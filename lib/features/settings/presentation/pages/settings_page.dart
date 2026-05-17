import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../config/constants/app_colors.dart';
import '../../../../config/constants/app_spacing.dart';
import '../../../../config/constants/app_strings.dart';
import '../../../../config/constants/app_textstyle.dart';
import '../../../../config/legal_links.dart';
import '../../../../core/services/seed_service.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';

Future<void> _openExternalUrl(BuildContext context, String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return;
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not open $url')),
    );
  }
}

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
              AppSpacing.screenHorizontal,
              12.h,
              AppSpacing.screenHorizontal,
              AppSpacing.bottomNavSafePadding),
          children: [
            Text(
              AppStrings.settingsTitle,
              style: AppTextStyle.largeTitle()
                  .copyWith(fontSize: 32.sp, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 20.h),
            if (user != null)
              _ProfileCard(
                name: user.displayName,
                email: user.email,
                initials: user.initials,
                photoUrl: user.photoUrl,
              ),
            SizedBox(height: 22.h),
            _SectionLabel('PREFERENCES'),
            _SectionCard(children: [
              _SettingRow(
                icon: Icons.dark_mode_outlined,
                iconTint: const Color(0xFFF1E4CC),
                iconColor: AppColors.secondaryNavy,
                title: 'Appearance',
                trailing: Text('Light',
                    style: AppTextStyle.helper(
                            color: AppColors.textSecondary)
                        .copyWith(fontSize: 14.sp)),
              ),
              _Divider(),
              _SettingRow(
                icon: Icons.flag_outlined,
                iconTint: const Color(0xFFF1E4CC),
                iconColor: AppColors.info,
                title: 'Language',
                trailing: Text('English',
                    style: AppTextStyle.helper(
                            color: AppColors.textSecondary)
                        .copyWith(fontSize: 14.sp)),
              ),
              _Divider(),
              _ToggleRow(
                icon: Icons.bolt_rounded,
                iconTint: const Color(0xFFD7E6D7),
                iconColor: AppColors.primaryGold,
                title: 'Offline downloads',
                initial: true,
                onChanged: (_) {},
              ),
            ]),
            SizedBox(height: 22.h),
            _SectionLabel('NOTIFICATIONS'),
            _SectionCard(children: [
              _ToggleRow(
                icon: Icons.music_note_rounded,
                iconTint: const Color(0xFFF1E4CC),
                iconColor: AppColors.primaryGold,
                title: 'Push notifications',
                initial: true,
                onChanged: (_) {},
              ),
              _Divider(),
              _ToggleRow(
                icon: Icons.mail_outline_rounded,
                iconTint: const Color(0xFFE6DFF1),
                iconColor: const Color(0xFF7C3AED),
                title: 'Weekly digest',
                initial: false,
                onChanged: (_) {},
              ),
            ]),
            SizedBox(height: 22.h),
            _SectionLabel('SUPPORT'),
            _SectionCard(children: [
              _SettingRow(
                icon: Icons.add_rounded,
                iconTint: const Color(0xFFF1E4CC),
                iconColor: AppColors.primaryGold,
                title: 'Request a game',
                subtitle: 'Suggest a new title',
                onTap: () => context.push('/request-game'),
              ),
              _Divider(),
              _SettingRow(
                icon: Icons.help_outline_rounded,
                iconTint: const Color(0xFFD9E2EA),
                iconColor: AppColors.info,
                title: 'Help & FAQ',
                onTap: () => _openExternalUrl(context, LegalLinks.supportUrl),
              ),
              _Divider(),
              _SettingRow(
                icon: Icons.star_outline_rounded,
                iconTint: const Color(0xFFF1E4CC),
                iconColor: AppColors.primaryGold,
                title: 'Rate BoardMate',
                onTap: () {},
              ),
              _Divider(),
              _SettingRow(
                icon: Icons.photo_library_outlined,
                iconTint: const Color(0xFFD9E2EA),
                iconColor: AppColors.info,
                title: 'Image credits',
                subtitle: 'Photographers & licences',
                onTap: () => context.push('/credits'),
              ),
            ]),
            SizedBox(height: 22.h),
            _SectionLabel('LEGAL'),
            _SectionCard(children: [
              _SettingRow(
                icon: Icons.shield_outlined,
                iconTint: const Color(0xFFD7E6D7),
                iconColor: AppColors.success,
                title: 'Privacy Policy',
                subtitle: 'How we handle your data',
                onTap: () =>
                    _openExternalUrl(context, LegalLinks.privacyPolicyUrl),
              ),
              _Divider(),
              _SettingRow(
                icon: Icons.description_outlined,
                iconTint: const Color(0xFFF1E4CC),
                iconColor: AppColors.primaryGold,
                title: 'Terms of Service',
                onTap: () =>
                    _openExternalUrl(context, LegalLinks.termsOfServiceUrl),
              ),
              _Divider(),
              _SettingRow(
                icon: Icons.code_rounded,
                iconTint: const Color(0xFFD9E2EA),
                iconColor: AppColors.info,
                title: 'Open Source Licenses',
                subtitle: 'Third-party packages used',
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: 'BoardMate',
                  applicationVersion: '1.0.0',
                  applicationLegalese: LegalLinks.copyrightLine,
                ),
              ),
            ]),
            if (kDebugMode) ...[
              SizedBox(height: 22.h),
              _SectionLabel('DEVELOPER'),
              _SectionCard(children: [
                _SettingRow(
                  icon: Icons.cloud_upload_outlined,
                  iconTint: const Color(0xFFF1E4CC),
                  iconColor: AppColors.primaryGold,
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
              ]),
            ],
            SizedBox(height: 28.h),
            _SignOutButton(
              onTap: () async {
                await ref.read(authNotifierProvider).signOut();
                if (!context.mounted) return;
                context.go('/sign-in');
              },
            ),
            SizedBox(height: 18.h),
            Center(
              child: Column(
                children: [
                  Text('${AppStrings.version} 1.0.0',
                      style: AppTextStyle.helper()),
                  SizedBox(height: 4.h),
                  Text(
                    LegalLinks.copyrightLine,
                    style: AppTextStyle.helper()
                        .copyWith(fontSize: 11.sp),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Profile card ────────────────────────────────────────────────────────

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
        borderRadius: BorderRadius.circular(AppSpacing.smallCardRadius),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: AppColors.primaryGold,
              shape: BoxShape.circle,
              image: photoUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(photoUrl), fit: BoxFit.cover)
                  : null,
            ),
            alignment: Alignment.center,
            child: photoUrl.isEmpty
                ? Text(initials,
                    style: AppTextStyle.bodyStrong(color: Colors.white)
                        .copyWith(fontSize: 18.sp))
                : null,
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name.isEmpty ? 'BoardMate user' : name,
                    style: AppTextStyle.cardTitle().copyWith(
                        fontSize: 16.sp, fontWeight: FontWeight.w700)),
                SizedBox(height: 2.h),
                Text(email,
                    style: AppTextStyle.helper(
                        color: AppColors.textSecondary)),
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

// ─── Section building blocks ─────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 10.h),
      child: Text(
        label,
        style: AppTextStyle.label(color: AppColors.textSecondary)
            .copyWith(letterSpacing: 1.2, fontSize: 11.sp),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDefault,
        borderRadius: BorderRadius.circular(AppSpacing.smallCardRadius),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 64.w),
      child: Container(
        height: 1,
        color: AppColors.secondaryNavy.withValues(alpha: 0.06),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.iconTint,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });
  final IconData icon;
  final Color iconTint;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          child: Row(
            children: [
              _IconTile(icon: icon, tint: iconTint, color: iconColor),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title,
                        style: AppTextStyle.cardTitle().copyWith(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600)),
                    if (subtitle != null) ...[
                      SizedBox(height: 2.h),
                      Text(subtitle!, style: AppTextStyle.helper()),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              trailing ??
                  Icon(Icons.chevron_right_rounded,
                      color: AppColors.textSecondary, size: 22.sp),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToggleRow extends StatefulWidget {
  const _ToggleRow({
    required this.icon,
    required this.iconTint,
    required this.iconColor,
    required this.title,
    required this.initial,
    required this.onChanged,
  });
  final IconData icon;
  final Color iconTint;
  final Color iconColor;
  final String title;
  final bool initial;
  final ValueChanged<bool> onChanged;

  @override
  State<_ToggleRow> createState() => _ToggleRowState();
}

class _ToggleRowState extends State<_ToggleRow> {
  late bool _value = widget.initial;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Row(
        children: [
          _IconTile(
              icon: widget.icon,
              tint: widget.iconTint,
              color: widget.iconColor),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(widget.title,
                style: AppTextStyle.cardTitle().copyWith(
                    fontSize: 16.sp, fontWeight: FontWeight.w600)),
          ),
          Switch.adaptive(
            value: _value,
            onChanged: (v) {
              setState(() => _value = v);
              widget.onChanged(v);
            },
            activeThumbColor: AppColors.primaryGold,
          ),
        ],
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile(
      {required this.icon, required this.tint, required this.color});
  final IconData icon;
  final Color tint;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36.w,
      height: 36.w,
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(10.r),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: color, size: 18.sp),
    );
  }
}

class _SignOutButton extends StatelessWidget {
  const _SignOutButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.error.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(AppSpacing.smallCardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.smallCardRadius),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Row(
            children: [
              Icon(Icons.logout_rounded,
                  color: AppColors.error, size: 20.sp),
              SizedBox(width: 10.w),
              Text(AppStrings.signOut,
                  style: AppTextStyle.bodyStrong(color: AppColors.error)),
            ],
          ),
        ),
      ),
    );
  }
}
