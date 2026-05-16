import 'package:boardmate/config/constants/app_colors.dart';
import 'package:boardmate/core/widgets/bm_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BmButton renders its label and fires onPressed',
      (WidgetTester tester) async {
    var taps = 0;
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(393, 852),
        builder: (_, __) => MaterialApp(
          theme: ThemeData(colorScheme: const ColorScheme.light(primary: AppColors.primaryGold, onPrimary: Colors.white, secondary: AppColors.secondaryNavy, onSecondary: Colors.white, surface: AppColors.surfaceDefault, onSurface: AppColors.secondaryNavy, error: AppColors.error, onError: Colors.white)),
          home: Scaffold(
            body: BmButton(label: 'Tap me', onPressed: () => taps++),
          ),
        ),
      ),
    );

    expect(find.text('Tap me'), findsOneWidget);
    await tester.tap(find.text('Tap me'));
    await tester.pump();
    expect(taps, 1);
  });
}
