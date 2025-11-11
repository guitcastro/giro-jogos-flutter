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

import 'dart:io';

bool hasValidLicenseHeader(String content) {
  // Check if file starts with license comment
  if (!content.startsWith('/*')) {
    return false;
  }

  // Check for required AGPL text
  return content.contains('GNU Affero General Public License') &&
      content.contains('Giro Jogos') &&
      content.contains('https://www.gnu.org/licenses/');
}

Future<List<String>> findFilesWithoutLicense(String dirPath) async {
  final filesWithoutLicense = <String>[];
  final dir = Directory(dirPath);

  if (!await dir.exists()) {
    return filesWithoutLicense;
  }

  await for (final entity in dir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      // Skip generated files
      if (entity.path.contains('.g.dart') ||
          entity.path.contains('.freezed.dart') ||
          entity.path.contains('.mocks.dart')) {
        continue;
      }

      try {
        final content = await entity.readAsString();
        if (!hasValidLicenseHeader(content)) {
          filesWithoutLicense.add(entity.path);
        }
      } catch (e) {
        stdout.writeln('Error reading file ${entity.path}: $e');
        filesWithoutLicense.add(entity.path);
      }
    }
  }

  return filesWithoutLicense;
}

Future<void> main(List<String> args) async {
  stdout.writeln('Validating AGPL-3.0 license headers in Dart files...');

  var allFilesWithoutLicense = <String>[];

  // Check lib directory
  final libFiles = await findFilesWithoutLicense('lib');
  allFilesWithoutLicense.addAll(libFiles);

  // Check test directory
  final testFiles = await findFilesWithoutLicense('test');
  allFilesWithoutLicense.addAll(testFiles);

  if (allFilesWithoutLicense.isEmpty) {
    stdout.writeln('✅ All Dart files have valid AGPL-3.0 license headers!');
    exit(0);
  } else {
    stdout.writeln(
        '❌ Found ${allFilesWithoutLicense.length} files without valid license headers:');
    for (final file in allFilesWithoutLicense) {
      stdout.writeln('  - $file');
    }
    stdout.writeln('');
    stdout.writeln(
        'Run "dart run scripts/add_license_headers.dart" to fix missing headers.');
    exit(1);
  }
}
