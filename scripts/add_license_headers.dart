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

const String licenseHeader = '''/*
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

''';

bool hasLicenseHeader(String content) {
  return content.startsWith('/*') &&
      content.contains('GNU Affero General Public License') &&
      content.contains('Giro Jogos');
}

Future<void> addLicenseHeaderToFile(String filePath) async {
  final file = File(filePath);
  final content = await file.readAsString();

  if (hasLicenseHeader(content)) {
    stdout.writeln('License header already present in: $filePath');
    return;
  }

  final newContent = licenseHeader + content;
  await file.writeAsString(newContent);
  stdout.writeln('Added license header to: $filePath');
}

Future<void> processDirectory(String dirPath) async {
  final dir = Directory(dirPath);

  await for (final entity in dir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      // Skip generated files and test files for now
      if (entity.path.contains('.g.dart') ||
          entity.path.contains('.freezed.dart') ||
          entity.path.contains('.mocks.dart')) {
        continue;
      }

      await addLicenseHeaderToFile(entity.path);
    }
  }
}

Future<void> main(List<String> args) async {
  stdout.writeln('Adding AGPL-3.0 license headers to Dart files...');

  // Process lib directory
  await processDirectory('lib');

  // Process test directory
  await processDirectory('test');

  stdout.writeln('License header addition completed!');
}
