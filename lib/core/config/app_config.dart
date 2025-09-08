import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// AppConfig handles environment variables and app-wide configuration.
/// You can switch between `.env.dev` and `.env.prod` here.
class AppConfig {
  static String appName = "RITCHAT";
  static String allowedDomain = "@rit.edu";

  static Future<void> init() async {
    // Load environment variables (.env file)
    try {
      await dotenv.load(fileName: kReleaseMode ? ".env.prod" : ".env.dev");
      appName = dotenv.env['APP_NAME'] ?? appName;
      allowedDomain = dotenv.env['ALLOWED_EMAIL_DOMAIN'] ?? allowedDomain;
    } catch (e) {
      debugPrint("⚠️ Failed to load env file: $e");
    }
  }
}
