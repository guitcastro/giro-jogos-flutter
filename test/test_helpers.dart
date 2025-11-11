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

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Inicializa o Firebase para testes usando fake Firebase
Future<void> initializeFirebaseForTesting() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Setup Firebase Core
  setupFirebaseCoreMocks();

  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'fake-api-key',
        appId: 'fake-app-id',
        messagingSenderId: 'fake-sender-id',
        projectId: 'fake-project-id',
        authDomain: 'fake-auth-domain',
        storageBucket: 'fake-storage-bucket',
      ),
    );
  } catch (e) {
    // Já inicializado
  }
}

/// Configura mocks para o Firebase Core
void setupFirebaseCoreMocks() {
  // Mock Firebase Core
  const channelCore = MethodChannel('plugins.flutter.io/firebase_core');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    channelCore,
    (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'Firebase#initializeCore':
          return [
            {
              'name': '[DEFAULT]',
              'options': {
                'apiKey': 'fake-api-key',
                'appId': 'fake-app-id',
                'messagingSenderId': 'fake-sender-id',
                'projectId': 'fake-project-id',
                'authDomain': 'fake-auth-domain',
                'storageBucket': 'fake-storage-bucket',
              },
              'pluginConstants': {},
            }
          ];
        case 'Firebase#initializeApp':
          return {
            'name': methodCall.arguments?['appName'] ?? '[DEFAULT]',
            'options': methodCall.arguments?['options'] ?? {},
            'pluginConstants': {},
          };
        default:
          return null;
      }
    },
  );

  // Mock Firebase Auth
  const channelAuth = MethodChannel('plugins.flutter.io/firebase_auth');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    channelAuth,
    (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'Auth#registerIdTokenListener':
          return {'user': null};
        case 'Auth#signOut':
          return null;
        default:
          return null;
      }
    },
  );

  // Mock Cloud Firestore
  const channelFirestore = MethodChannel('plugins.flutter.io/cloud_firestore');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    channelFirestore,
    (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'Firestore#enableNetwork':
        case 'Firestore#disableNetwork':
        case 'Firestore#terminate':
        case 'Firestore#waitForPendingWrites':
          return null;
        case 'Query#snapshots':
          return null;
        case 'DocumentReference#set':
        case 'DocumentReference#update':
        case 'DocumentReference#delete':
          return null;
        case 'Transaction#get':
        case 'Transaction#set':
        case 'Transaction#update':
        case 'Transaction#delete':
          return null;
        default:
          return null;
      }
    },
  );
}
