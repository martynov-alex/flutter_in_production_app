//import 'package:accessibility_tools/accessibility_tools.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_ship_app/env/flavor.dart';
import 'package:flutter_ship_app/firebase_options_dev.dart' as dev;
import 'package:flutter_ship_app/firebase_options_prod.dart' as prod;
import 'package:flutter_ship_app/firebase_options_stg.dart' as stg;
import 'package:flutter_ship_app/src/app_startup.dart';
import 'package:flutter_ship_app/src/presentation/apps_list_screen.dart';
import 'package:flutter_ship_app/src/utils/app_theme_data.dart';
import 'package:flutter_ship_app/src/utils/app_theme_mode.dart';
import 'package:flutter_ship_app/src/utils/shared_preferences_provider.dart';

Future<void> _initializeFirebaseApp() async {
  final firebaseOptions = switch (getFlavor()) {
    Flavor.prod => prod.DefaultFirebaseOptions.currentPlatform,
    Flavor.stg => stg.DefaultFirebaseOptions.currentPlatform,
    Flavor.dev => dev.DefaultFirebaseOptions.currentPlatform,
  };
  await Firebase.initializeApp(options: firebaseOptions);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeFirebaseApp();

  final container = ProviderContainer();
  // * Preload SharedPreferences before calling runApp, as the AppStartupWidget
  // * depends on it in order to load the themeMode
  await container.read(sharedPreferencesProvider.future);
  // run the app
  runApp(UncontrolledProviderScope(
    container: container,
    child: AppStartupWidget(
      onLoaded: (context) => const MainApp(),
    ),
  ));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(appThemeModeNotifierProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppThemeData.light(),
      darkTheme: AppThemeData.dark(),
      themeMode: themeMode,
      home: const AppsListScreen(),
      // * Uncomment this line to perform accessibility checks
      // builder: (context, child) => AccessibilityTools(child: child),
    );
  }
}
