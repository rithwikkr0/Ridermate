class ApiConfig {
  // Update this based on environment
  // For development: http://localhost:3000/api
  // For production: https://your-api-domain.com/api
  static const String baseUrl = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api',
  );
}
