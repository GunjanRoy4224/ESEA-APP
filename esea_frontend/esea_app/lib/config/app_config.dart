/// Application configuration and constants
class AppConfig {
  // API Configuration
  static const String baseUrl = 'https://esea-app.onrender.com/api';
  // static const String baseUrl = 'http://localhost:8000/api'; // For iOS simulator
  // static const String baseUrl = 'https://api.esea.org/api'; // For production
  
  static const String uploadsUrl = 'https://esea-app.onrender.com/uploads';
  
  // App Info
  static const String appName = 'ESEA App';
  static const String version = '1.0.0';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // Upload Limits
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  
  // Supported file types
  static const List<String> supportedDocTypes = ['pdf', 'doc', 'docx', 'ppt', 'pptx'];
  static const List<String> supportedImageTypes = ['jpg', 'jpeg', 'png', 'gif'];
}