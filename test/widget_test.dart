import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentra/core/theme/app_colors.dart';
import 'package:sentra/core/theme/app_theme.dart';
import 'package:sentra/features/splash/splash_screen.dart';

void main() {
  testWidgets('SENTRA theme and SplashScreen render cleanly', (
    WidgetTester tester,
  ) async {
    final theme = buildSentraTheme();
    expect(theme.colorScheme.primary, AppColors.primary);

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: const SplashScreen(autoNavigate: false),
      ),
    );
    await tester.pump(const Duration(seconds: 2));

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(Image), findsWidgets);
  });
}
