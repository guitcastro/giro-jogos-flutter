/// App-wide constants
class AppConstants {
  // App Information
  static const String appName = 'Giro Jogos';
  static const String appVersion = '1.0.0';
  
  // Routes
  static const String homeRoute = '/';
  static const String adminRoute = '/admin';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String gamesCollection = 'games';
  
  // Storage Paths
  static const String gameImagesPath = 'game_images';
  static const String userUploadsPath = 'uploads';
  
  // Limits
  static const int maxGamesPerPage = 20;
  static const int maxImageSizeMB = 5;
  
  // Error Messages
  static const String errorGeneric = 'An error occurred. Please try again.';
  static const String errorNetwork = 'Network error. Please check your connection.';
  static const String errorAuth = 'Authentication failed. Please try again.';
}
