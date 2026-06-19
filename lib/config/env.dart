import 'dart:io';

class EnvConfig {
  // Development backend
  static final String devBaseUrl = Platform.isAndroid
      ? 'http://10.0.2.2:5005/api'
      : 'http://localhost:5005/api';
  
  // Production backend
  static const String prodBaseUrl = 'https://api.getzio.in/api';
  
  // Active base URL (points to production by default for OTP and live SMS verification)
  static final String baseUrl = prodBaseUrl;
}
