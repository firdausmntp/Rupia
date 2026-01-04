import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/router/app_router.dart';
import 'core/services/database_service.dart';
import 'core/constants/app_config.dart';
import 'core/l10n/app_localizations.dart';
import 'core/l10n/locale_provider.dart';

// Global flag untuk Firebase status
bool firebaseInitialized = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Error handling untuk release mode
  if (kReleaseMode) {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('Flutter Error: ${details.exception}');
    };
  }
  
  // Initialize Firebase (auto-enabled for mobile since google-services.json exists)
  if (!kIsWeb) {
    try {
      await Firebase.initializeApp();
      firebaseInitialized = true;
      debugPrint('✅ Firebase initialized successfully');
    } catch (e) {
      firebaseInitialized = false;
      debugPrint('⚠️ Firebase init error: $e');
      // Continue without Firebase - app will work in offline mode
    }
  } else {
    debugPrint('ℹ️ Running in WEB demo mode');
  }
  
  // Initialize database
  if (!kIsWeb) {
    try {
      await DatabaseService.initialize();
      debugPrint('✅ Database initialized');
    } catch (e) {
      debugPrint('⚠️ Database init error: $e');
    }
  } else {
    debugPrint('ℹ️ Web mode - Using mock data');
  }
  
  // Check onboarding status
  String initialRoute = '/';
  try {
    final prefs = await SharedPreferences.getInstance();
    final hasCompletedOnboarding = prefs.getBool('onboarding_completed') ?? false;
    initialRoute = hasCompletedOnboarding ? '/' : '/onboarding';
  } catch (e) {
    debugPrint('⚠️ SharedPreferences error: $e');
    initialRoute = '/onboarding';
  }
  
  debugPrint('🚀 Starting Rupia App v${AppConfig.appVersion} - Route: $initialRoute');
  
  runApp(
    ProviderScope(
      child: RupiaApp(initialRoute: initialRoute),
    ),
  );
}

class RupiaApp extends ConsumerStatefulWidget {
  final String initialRoute;
  
  const RupiaApp({super.key, this.initialRoute = '/'});

  @override
  ConsumerState<RupiaApp> createState() => _RupiaAppState();
}

class _RupiaAppState extends ConsumerState<RupiaApp> {
  late final _router = AppRouter.createRouter(widget.initialRoute);

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    
    return MaterialApp.router(
      title: 'Rupia',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id'),
        Locale('en'),
      ],
      routerConfig: _router,
    );
  }
}
