/*
 * This file is part of Giro Jogos.
 * 
 * Giro Jogos is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * Giro Jogos is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License
 * along with Giro Jogos. If not, see <https://www.gnu.org/licenses/>.
 */

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
  static const String errorNetwork =
      'Network error. Please check your connection.';
  static const String errorAuth = 'Authentication failed. Please try again.';
}
