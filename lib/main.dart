import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/l10n/l10n.dart';
import 'core/routes/app_routes.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/prefs.dart';
import 'core/services/sync_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'data/services/auth_service.dart';
import 'data/services/messaging_service.dart';
import 'data/store/app_store.dart';
import 'firebase_options.dart';
import 'presentation/widgets/offline_banner.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Prefs.init();
  await ConnectivityService.init();
  SyncService.init();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AuthService.ready = true;
    // Offline-first: Firestore caches reads in a local DB and queues writes
    // while offline, then syncs automatically when the connection returns.
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    appStore.bind();
    await MessagingService.init();
  } catch (e) {
    // Firebase not configured yet (no google-services.json / GoogleService-Info
    // .plist). Fall back to the bundled demo data so the whole app is still
    // usable on-device. Run `flutterfire configure` to go live. See
    // SETUP_FIREBASE.md.
    debugPrint('⚠️ Firebase unavailable, using local demo mode: $e');
    AuthService.ready = false;
    appStore.useLocalDemo();
  }
  runApp(const GasApp());
}

class GasApp extends StatelessWidget {
  const GasApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuild on either a locale OR a theme-mode change so the mode-aware
    // [AppTheme.theme] and all [AppColors] getters re-evaluate together.
    return ListenableBuilder(
      listenable: Listenable.merge([L10n.notifier, ThemeController.notifier]),
      builder: (_, __) {
        return MaterialApp(
          title: 'GasFlow',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.theme,
          themeMode: ThemeController.notifier.value,
          builder: (context, child) =>
              OfflineBanner(child: child ?? const SizedBox.shrink()),
          locale: L10n.notifier.value,
          supportedLocales: const [Locale('en'), Locale('ar')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          initialRoute: AppRoutes.splash,
          onGenerateRoute: AppRoutes.onGenerateRoute,
        );
      },
    );
  }
}
