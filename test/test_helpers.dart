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
  const MethodChannel('plugins.flutter.io/firebase_core')
      .setMockMethodCallHandler((MethodCall methodCall) async {
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
  });

  // Mock Firebase Auth
  const MethodChannel('plugins.flutter.io/firebase_auth')
      .setMockMethodCallHandler((MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'Auth#registerIdTokenListener':
        return {'user': null};
      case 'Auth#signOut':
        return null;
      default:
        return null;
    }
  });

  // Mock Cloud Firestore
  const MethodChannel('plugins.flutter.io/cloud_firestore')
      .setMockMethodCallHandler((MethodCall methodCall) async {
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
  });
}
