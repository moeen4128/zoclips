import 'package:flutter/material.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/onboarding/data/onboarding_storage.dart';
import 'injection_container.dart' as di;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.initDependencies();
  await Future.wait([
    di.sl<ThemeController>().load(),
    di.sl<OnboardingStorage>().load(),
  ]);
  runApp(const ZoclipsApp());
}

class ZoclipsApp extends StatelessWidget {
  const ZoclipsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: di.sl<ThemeController>(),
      builder: (context, themeMode, _) {
        return MaterialApp.router(
          title: 'Zoclips',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
