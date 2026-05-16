class AppConfig {
  AppConfig({
    required this.appName,
    required this.baseUrl,
    required this.isDebug,
  });

  final String appName;
  final String baseUrl;
  final bool isDebug;
}
