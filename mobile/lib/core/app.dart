import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Generated file - will be available after running app

import 'config/theme.dart';
import 'router/app_router.dart';
import 'services/localization_service.dart';

class FinancialKingdomApp extends ConsumerWidget {
  const FinancialKingdomApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    
    return MaterialApp.router(
      title: 'Financial Kingdom Builder',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      
      // Localization configuration
      localizationsDelegates: const [
        // AppLocalizations.delegate, // Will be available after running app
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('es', ''), // Spanish
        Locale('fr', ''), // French
      ],
      
      // Initialize localization service
      builder: (context, child) {
        // Initialize localization service with current locale
        final locale = Localizations.localeOf(context);
        LocalizationService().loadLocalization(locale.languageCode);
        
        return child!;
      },
    );
  }
}