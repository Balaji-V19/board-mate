import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/constants/app_colors.dart';
import '../../../../config/constants/app_spacing.dart';
import '../../../../config/constants/app_textstyle.dart';
import '../../../../core/widgets/bm_button.dart';
import '../../domain/entities/game_request_entity.dart';
import '../providers/request_game_notifier.dart';

const _categories = [
  'Strategy',
  'Family',
  'Party',
  'Cards',
  'Co-op',
  'Word',
];

class RequestGamePage extends ConsumerStatefulWidget {
  const RequestGamePage({super.key});
  @override
  ConsumerState<RequestGamePage> createState() => _RequestGamePageState();
}

class _RequestGamePageState extends ConsumerState<RequestGamePage> {
  final _nameCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _category = 'Strategy';
  String? _nameError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = 'Please enter a game name.');
      return;
    }
    setState(() => _nameError = null);

    final ok = await ref.read(requestGameNotifierProvider).submit(
          GameRequestEntity(
            gameName: name,
            category: _category,
            notes: _notesCtrl.text.trim(),
          ),
        );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request sent. Thanks!')),
      );
      _nameCtrl.clear();
      _notesCtrl.clear();
      setState(() => _category = 'Strategy');
      ref.read(requestGameNotifierProvider).resetIfNotSubmitting();
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(requestGameNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: ListView(
            padding: EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal, 8.h, AppSpacing.screenHorizontal, 24.h),
            children: [
              _Header(onBack: () => context.canPop()
                  ? context.pop()
                  : context.go('/settings')),
              SizedBox(height: 18.h),
              Text(
                "Can't find a game?",
                style: AppTextStyle.largeTitle().copyWith(
                    fontSize: 26.sp, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 8.h),
              Text(
                'Tell us which game you\'d like to learn next. We add new guides every week.',
                style: AppTextStyle.body(color: AppColors.textSecondary),
              ),
              SizedBox(height: 22.h),
              _FieldLabel('GAME NAME'),
              SizedBox(height: 8.h),
              _TextField(
                controller: _nameCtrl,
                hint: 'e.g. Dune: Imperium',
                errorText: _nameError,
                onChanged: (_) {
                  if (_nameError != null) {
                    setState(() => _nameError = null);
                  }
                },
              ),
              SizedBox(height: 18.h),
              _FieldLabel('CATEGORY'),
              SizedBox(height: 8.h),
              _CategoryDropdown(
                value: _category,
                onChanged: (v) => setState(() => _category = v),
              ),
              SizedBox(height: 18.h),
              _FieldLabel('NOTES (OPTIONAL)'),
              SizedBox(height: 8.h),
              _TextField(
                controller: _notesCtrl,
                hint: 'Anything specific you want explained?',
                maxLines: 4,
              ),
              if (notifier.errorMessage != null) ...[
                SizedBox(height: 14.h),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 14.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    notifier.errorMessage!,
                    style: AppTextStyle.helper(color: AppColors.error),
                  ),
                ),
              ],
              SizedBox(height: 22.h),
              BmButton(
                label: 'Send Request',
                loading: notifier.isSubmitting,
                onPressed: notifier.isSubmitting ? null : _onSubmit,
              ),
              SizedBox(height: 12.h),
              Center(
                child: Text(
                  'We review every request within 48 hours.',
                  style: AppTextStyle.helper(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _RoundIconButton(
            icon: Icons.chevron_left_rounded, onTap: onBack),
        Expanded(
          child: Center(
            child: Text('Request Game',
                style: AppTextStyle.cardTitle().copyWith(
                    fontSize: 17.sp, fontWeight: FontWeight.w700)),
          ),
        ),
        SizedBox(width: 42.w), // spacer to keep title centered
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceDefault,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: 42.w,
          height: 42.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: AppColors.secondaryNavy, size: 22.sp),
        ),
      ),
    );
  }
}

// ─── Form elements ──────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);
  final String label;
  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyle.label(color: AppColors.textSecondary)
          .copyWith(letterSpacing: 1.2, fontSize: 11.sp),
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.errorText,
    this.onChanged,
  });
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding:
              EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.surfaceDefault,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: errorText != null
                  ? AppColors.error
                  : AppColors.border,
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            onChanged: onChanged,
            style: AppTextStyle.body(),
            decoration: InputDecoration(
              isCollapsed: true,
              border: InputBorder.none,
              hintText: hint,
              hintStyle:
                  AppTextStyle.body(color: AppColors.textSecondary),
            ),
          ),
        ),
        if (errorText != null) ...[
          SizedBox(height: 6.h),
          Text(errorText!,
              style: AppTextStyle.helper(color: AppColors.error)),
        ],
      ],
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  const _CategoryDropdown({required this.value, required this.onChanged});
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceDefault,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary, size: 22.sp),
          style: AppTextStyle.body(),
          dropdownColor: AppColors.surfaceDefault,
          items: [
            for (final c in _categories)
              DropdownMenuItem(
                value: c,
                child: Text(c, style: AppTextStyle.body()),
              ),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}
