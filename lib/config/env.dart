class EnvConfig {
  // Development backend (use localhost with adb reverse tcp:5005 tcp:5005)
  static const String devBaseUrl = 'http://localhost:5005/api';
  
  // Production backend
  static const String prodBaseUrl = 'https://api.getzio.in/api';
  
  // Active base URL (points to production by default for OTP and live SMS verification)
  static final String baseUrl = prodBaseUrl;
}
