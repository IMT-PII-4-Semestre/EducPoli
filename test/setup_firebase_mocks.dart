import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

typedef Callback = void Function(MethodCall call);

void setupFirebaseAuthMocks([Callback? customHandlers]) {
  TestWidgetsFlutterBinding.ensureInitialized();
}

Future<void> setupFirebaseCoreMocks() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Setup Firebase Core Mock
  setupFirebaseMocks();

  // Mock Firebase Auth
  const MethodChannel('plugins.flutter.io/firebase_auth')
      .setMockMethodCallHandler((call) async {
    switch (call.method) {
      case 'Auth#registerIdTokenListener':
        return {
          'user': null,
        };
      case 'Auth#registerAuthStateListener':
        return null;
      case 'Auth#signInWithEmailAndPassword':
        return {
          'user': {
            'uid': 'test-uid',
            'email': call.arguments['email'],
            'displayName': 'Test User',
          }
        };
      case 'Auth#signOut':
        return null;
      case 'Auth#currentUser':
        return null;
      default:
        return null;
    }
  });

  // Mock Cloud Firestore
  const MethodChannel('plugins.flutter.io/cloud_firestore')
      .setMockMethodCallHandler((call) async {
    switch (call.method) {
      case 'Query#get':
        return {
          'documents': [],
          'metadata': {'isFromCache': false},
        };
      case 'DocumentReference#get':
        return {
          'data': {},
          'metadata': {'isFromCache': false},
        };
      default:
        return null;
    }
  });

  await Firebase.initializeApp();
}

void setupFirebaseMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Configurar plataforma mock do Firebase
  FirebasePlatform.instance = _MockFirebasePlatform();
}

class _MockFirebasePlatform extends FirebasePlatform {
  _MockFirebasePlatform() : super();

  @override
  FirebaseAppPlatform app([String name = defaultFirebaseAppName]) {
    return _MockFirebaseApp(name);
  }

  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    return _MockFirebaseApp(name ?? defaultFirebaseAppName);
  }

  @override
  List<FirebaseAppPlatform> get apps {
    return [_MockFirebaseApp(defaultFirebaseAppName)];
  }
}

class _MockFirebaseApp extends FirebaseAppPlatform {
  _MockFirebaseApp(String name)
      : super(
          name,
          const FirebaseOptions(
            apiKey: 'fake-api-key',
            appId: 'fake-app-id',
            messagingSenderId: 'fake-sender-id',
            projectId: 'fake-project-id',
          ),
        );

  @override
  Future<void> delete() async {}

  @override
  bool get isAutomaticDataCollectionEnabled => false;

  @override
  Future<void> setAutomaticDataCollectionEnabled(bool enabled) async {}

  @override
  Future<void> setAutomaticResourceManagementEnabled(bool enabled) async {}
}
