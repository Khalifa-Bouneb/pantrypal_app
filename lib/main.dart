import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/theme_service.dart';
import 'services/localization_service.dart';
import 'services/notification_settings_service.dart';
import 'services/notification_service.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await ThemeService.instance.loadTheme();
  await LocalizationService.instance.load();
  await NotificationSettingsService.instance.load();
  await NotificationService.instance.init();

  runApp(const PantryPalApp());
}

class PantryPalApp extends StatelessWidget {
  const PantryPalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.instance.themeModeNotifier,
      builder: (context, themeMode, _) {
        return ValueListenableBuilder<Locale>(
          valueListenable: LocalizationService.instance.localeNotifier,
          builder: (context, locale, __) {
            return MaterialApp(
              title: 'PantryPal',
              debugShowCheckedModeBanner: false,
              locale: locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              theme: ThemeData(
                primarySwatch: Colors.green,
                useMaterial3: true,
                brightness: Brightness.light,
              ),
              darkTheme: ThemeData(
                primarySwatch: Colors.green,
                useMaterial3: true,
                brightness: Brightness.dark,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.green,
                  brightness: Brightness.dark,
                  surface: const Color(0xFF1F2937), // Dark Gray
                  background: const Color(0xFF111827), // Very Dark Gray
                ),
                scaffoldBackgroundColor: const Color(0xFF111827),
              ),
              themeMode: themeMode,
              home: const SplashScreen(),
            );
          },
        );
      },
    );
  }
}
