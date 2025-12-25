enum Environment { development, staging, production }

class EnvironmentConfig {
  static const Environment _currentEnvironment = Environment.production;
  
  static Environment get currentEnvironment => _currentEnvironment;
  
  static bool get isDevelopment => _currentEnvironment == Environment.development;
  static bool get isStaging => _currentEnvironment == Environment.staging;
  static bool get isProduction => _currentEnvironment == Environment.production;
  
  static String get apiBaseUrl {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'http://localhost:3000/api/v1';
      case Environment.staging:
        return 'https://staging-api.sociallive.com/api/v1';
      case Environment.production:
        return 'https://api.sociallive.com/api/v1';
    }
  }
  
  static String get websocketUrl {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'ws://localhost:3000';
      case Environment.staging:
        return 'wss://staging-api.sociallive.com';
      case Environment.production:
        return 'wss://api.sociallive.com';
    }
  }
  
  static bool get enableLogging => !isProduction;
  static bool get enableCrashReporting => isProduction;
}