class ApiConfig {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://2.25.235.160:3000/',
  );

  static const timeout = Duration(seconds: 10);
}
