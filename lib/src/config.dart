/// App configuration.
///
/// Point [apiBaseUrl] at your Account Keeping backend:
///   • Android emulator → dev machine:  http://10.0.2.2:8000/api
///   • iOS simulator    → dev machine:   http://127.0.0.1:8000/api
///   • Production                        https://books.yourdomain.com/api
///
/// Override at build time:
///   flutter run --dart-define=API_BASE_URL=https://books.example.com/api
class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://accountkeeping.co/api',
  );

  static const String appName = 'Account Keeping';
}
