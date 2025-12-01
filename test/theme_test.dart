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

// ignore_for_file: avoid_print

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

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Print all theme properties', () {
    // Recria o mesmo tema definido em app.dart
    final ThemeData theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    );
    final ColorScheme colorScheme = theme.colorScheme;

    // Helper function to convert Color to hex
    String colorToHex(Color color) {
      return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
    }

    print('\n=== GIRO JOGOS THEME PROPERTIES ===\n');

    print('--- ColorScheme Properties ---');
    print('primary: ${colorToHex(colorScheme.primary)}');
    print('onPrimary: ${colorToHex(colorScheme.onPrimary)}');
    print('primaryContainer: ${colorToHex(colorScheme.primaryContainer)}');
    print('onPrimaryContainer: ${colorToHex(colorScheme.onPrimaryContainer)}');
    print('');
    print('secondary: ${colorToHex(colorScheme.secondary)}');
    print('onSecondary: ${colorToHex(colorScheme.onSecondary)}');
    print('secondaryContainer: ${colorToHex(colorScheme.secondaryContainer)}');
    print(
        'onSecondaryContainer: ${colorToHex(colorScheme.onSecondaryContainer)}');
    print('');
    print('tertiary: ${colorToHex(colorScheme.tertiary)}');
    print('onTertiary: ${colorToHex(colorScheme.onTertiary)}');
    print('tertiaryContainer: ${colorToHex(colorScheme.tertiaryContainer)}');
    print(
        'onTertiaryContainer: ${colorToHex(colorScheme.onTertiaryContainer)}');
    print('');
    print('error: ${colorToHex(colorScheme.error)}');
    print('onError: ${colorToHex(colorScheme.onError)}');
    print('errorContainer: ${colorToHex(colorScheme.errorContainer)}');
    print('onErrorContainer: ${colorToHex(colorScheme.onErrorContainer)}');
    print('');
    print('surface: ${colorToHex(colorScheme.surface)}');
    print('onSurface: ${colorToHex(colorScheme.onSurface)}');
    print('surfaceDim: ${colorToHex(colorScheme.surfaceDim)}');
    print('surfaceBright: ${colorToHex(colorScheme.surfaceBright)}');
    print(
        'surfaceContainerLowest: ${colorToHex(colorScheme.surfaceContainerLowest)}');
    print(
        'surfaceContainerLow: ${colorToHex(colorScheme.surfaceContainerLow)}');
    print('surfaceContainer: ${colorToHex(colorScheme.surfaceContainer)}');
    print(
        'surfaceContainerHigh: ${colorToHex(colorScheme.surfaceContainerHigh)}');
    print(
        'surfaceContainerHighest: ${colorToHex(colorScheme.surfaceContainerHighest)}');
    print('');
    print('outline: ${colorToHex(colorScheme.outline)}');
    print('outlineVariant: ${colorToHex(colorScheme.outlineVariant)}');
    print('shadow: ${colorToHex(colorScheme.shadow)}');
    print('scrim: ${colorToHex(colorScheme.scrim)}');
    print('inverseSurface: ${colorToHex(colorScheme.inverseSurface)}');
    print('onInverseSurface: ${colorToHex(colorScheme.onInverseSurface)}');
    print('inversePrimary: ${colorToHex(colorScheme.inversePrimary)}');
    print('');

    print('--- Theme Properties ---');
    print('primaryColor: ${colorToHex(theme.primaryColor)}');
    print(
        'scaffoldBackgroundColor: ${colorToHex(theme.scaffoldBackgroundColor)}');
    print('canvasColor: ${colorToHex(theme.canvasColor)}');
    print('cardColor: ${colorToHex(theme.cardColor)}');
    print('dividerColor: ${colorToHex(theme.dividerColor)}');
    print('focusColor: ${colorToHex(theme.focusColor)}');
    print('hoverColor: ${colorToHex(theme.hoverColor)}');
    print('highlightColor: ${colorToHex(theme.highlightColor)}');
    print('splashColor: ${colorToHex(theme.splashColor)}');
    print('disabledColor: ${colorToHex(theme.disabledColor)}');
    print('');

    print('--- Text Theme (non-null values only) ---');
    if (theme.textTheme.displayLarge?.fontSize != null) {
      print(
          'displayLarge: ${theme.textTheme.displayLarge?.fontSize} - ${theme.textTheme.displayLarge?.fontWeight}');
    }
    if (theme.textTheme.displayMedium?.fontSize != null) {
      print(
          'displayMedium: ${theme.textTheme.displayMedium?.fontSize} - ${theme.textTheme.displayMedium?.fontWeight}');
    }
    if (theme.textTheme.displaySmall?.fontSize != null) {
      print(
          'displaySmall: ${theme.textTheme.displaySmall?.fontSize} - ${theme.textTheme.displaySmall?.fontWeight}');
    }
    if (theme.textTheme.headlineLarge?.fontSize != null) {
      print(
          'headlineLarge: ${theme.textTheme.headlineLarge?.fontSize} - ${theme.textTheme.headlineLarge?.fontWeight}');
    }
    if (theme.textTheme.headlineMedium?.fontSize != null) {
      print(
          'headlineMedium: ${theme.textTheme.headlineMedium?.fontSize} - ${theme.textTheme.headlineMedium?.fontWeight}');
    }
    if (theme.textTheme.headlineSmall?.fontSize != null) {
      print(
          'headlineSmall: ${theme.textTheme.headlineSmall?.fontSize} - ${theme.textTheme.headlineSmall?.fontWeight}');
    }
    if (theme.textTheme.titleLarge?.fontSize != null) {
      print(
          'titleLarge: ${theme.textTheme.titleLarge?.fontSize} - ${theme.textTheme.titleLarge?.fontWeight}');
    }
    if (theme.textTheme.titleMedium?.fontSize != null) {
      print(
          'titleMedium: ${theme.textTheme.titleMedium?.fontSize} - ${theme.textTheme.titleMedium?.fontWeight}');
    }
    if (theme.textTheme.titleSmall?.fontSize != null) {
      print(
          'titleSmall: ${theme.textTheme.titleSmall?.fontSize} - ${theme.textTheme.titleSmall?.fontWeight}');
    }
    if (theme.textTheme.bodyLarge?.fontSize != null) {
      print(
          'bodyLarge: ${theme.textTheme.bodyLarge?.fontSize} - ${theme.textTheme.bodyLarge?.fontWeight}');
    }
    if (theme.textTheme.bodyMedium?.fontSize != null) {
      print(
          'bodyMedium: ${theme.textTheme.bodyMedium?.fontSize} - ${theme.textTheme.bodyMedium?.fontWeight}');
    }
    if (theme.textTheme.bodySmall?.fontSize != null) {
      print(
          'bodySmall: ${theme.textTheme.bodySmall?.fontSize} - ${theme.textTheme.bodySmall?.fontWeight}');
    }
    if (theme.textTheme.labelLarge?.fontSize != null) {
      print(
          'labelLarge: ${theme.textTheme.labelLarge?.fontSize} - ${theme.textTheme.labelLarge?.fontWeight}');
    }
    if (theme.textTheme.labelMedium?.fontSize != null) {
      print(
          'labelMedium: ${theme.textTheme.labelMedium?.fontSize} - ${theme.textTheme.labelMedium?.fontWeight}');
    }
    if (theme.textTheme.labelSmall?.fontSize != null) {
      print(
          'labelSmall: ${theme.textTheme.labelSmall?.fontSize} - ${theme.textTheme.labelSmall?.fontWeight}');
    }
    print('');

    print('--- AppBar Theme (non-null values only) ---');
    if (theme.appBarTheme.backgroundColor != null) {
      print(
          'backgroundColor: ${colorToHex(theme.appBarTheme.backgroundColor!)}');
    }
    if (theme.appBarTheme.foregroundColor != null) {
      print(
          'foregroundColor: ${colorToHex(theme.appBarTheme.foregroundColor!)}');
    }
    if (theme.appBarTheme.elevation != null) {
      print('elevation: ${theme.appBarTheme.elevation}');
    }
    print('');

    print('--- Button Themes (non-null values only) ---');
    final elevatedFg =
        theme.elevatedButtonTheme.style?.foregroundColor?.resolve({});
    if (elevatedFg != null) {
      print('elevatedButtonTheme foregroundColor: ${colorToHex(elevatedFg)}');
    }
    final elevatedBg =
        theme.elevatedButtonTheme.style?.backgroundColor?.resolve({});
    if (elevatedBg != null) {
      print('elevatedButtonTheme backgroundColor: ${colorToHex(elevatedBg)}');
    }
    final filledFg =
        theme.filledButtonTheme.style?.foregroundColor?.resolve({});
    if (filledFg != null) {
      print('filledButtonTheme foregroundColor: ${colorToHex(filledFg)}');
    }
    final filledBg =
        theme.filledButtonTheme.style?.backgroundColor?.resolve({});
    if (filledBg != null) {
      print('filledButtonTheme backgroundColor: ${colorToHex(filledBg)}');
    }
    print('');

    print('=== END OF THEME PROPERTIES ===\n');
  });
}
