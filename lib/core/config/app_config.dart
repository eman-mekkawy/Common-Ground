class AppConfig {
  /// Toggle this to false when connecting to a live Firebase/Gemini project.
  /// When true, all repositories and services will bypass network requests and
  /// use realistic local mock data.
  static const bool useMockData = true;

  /// Your Gemini API Key.
  /// In production, keep this secure (e.g., using Firebase Remote Config or a backend server).
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';

  /// Helper to check if the Gemini API key is configured.
  static bool get isGeminiConfigured =>
      geminiApiKey.isNotEmpty && geminiApiKey != 'YOUR_GEMINI_API_KEY_HERE';
}
