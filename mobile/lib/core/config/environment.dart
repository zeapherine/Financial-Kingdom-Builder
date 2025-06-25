import 'package:flutter_dotenv/flutter_dotenv.dart';

enum AppEnvironment {
  development,
  staging,
  production,
}

class Environment {
  static AppEnvironment get current {
    const env = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
    switch (env) {
      case 'staging':
        return AppEnvironment.staging;
      case 'production':
        return AppEnvironment.production;
      default:
        return AppEnvironment.development;
    }
  }

  static String get fileName {
    switch (current) {
      case AppEnvironment.development:
        return '.env.dev';
      case AppEnvironment.staging:
        return '.env.staging';
      case AppEnvironment.production:
        return '.env.prod';
    }
  }

  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';
  static String get coingeckoApiKey => dotenv.env['COINGECKO_API_KEY'] ?? '';
  static String get extendedApiKey => dotenv.env['EXTENDED_API_KEY'] ?? '';
  static bool get isProduction => current == AppEnvironment.production;
  static bool get isDevelopment => current == AppEnvironment.development;
}