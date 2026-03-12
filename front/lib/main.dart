import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:front/app/app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front/presentation/utils/naver_map_init.dart';
import 'package:front/presentation/providers/app_providers.dart';
import 'package:flutter/foundation.dart';

FirebaseOptions _firebaseOptionsFromEnv() {
  const requiredKeys = <String>[
    'FIREBASE_API_KEY',
    'FIREBASE_APP_ID',
    'FIREBASE_MESSAGING_SENDER_ID',
    'FIREBASE_PROJECT_ID',
  ];

  final missing = requiredKeys
      .where((key) => (dotenv.env[key] ?? '').trim().isEmpty)
      .toList();
  if (missing.isNotEmpty) {
    throw StateError(
      'Missing Firebase env keys: ${missing.join(', ')}. '
      'Add them to front/.env',
    );
  }

  return FirebaseOptions(
    apiKey: dotenv.env['FIREBASE_API_KEY']!,
    appId: dotenv.env['FIREBASE_APP_ID']!,
    messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID']!,
    projectId: dotenv.env['FIREBASE_PROJECT_ID']!,
    authDomain: dotenv.env['FIREBASE_AUTH_DOMAIN'],
    storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET'],
  );
}

Future<void> _loadEnv() async {
  // 기본값(.env.production)을 먼저 읽고, 로컬(.env)로 덮어쓴다.
  await dotenv.load(fileName: '.env.production', isOptional: true);
  await dotenv.load(fileName: '.env', isOptional: true, mergeWith: dotenv.env);
}

// 앱 시작 지점: Riverpod 스코프와 앱 위젯을 연결한다.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    usePathUrlStrategy(); // 추가

    await _loadEnv();
    if (kIsWeb) {
      await Firebase.initializeApp(options: _firebaseOptionsFromEnv());
    } else {
      await Firebase.initializeApp();
    }

    final clientId = dotenv.env['NAVER_MAP_CLIENT_ID'];
    if (clientId == null || clientId.isEmpty) {
      throw StateError('NAVER_MAP_CLIENT_ID is missing in .env');
    }
    await initNaverMap(clientId);

    final container = ProviderContainer();
    await container.read(currentLocationProvider.notifier).initialize();

    runApp(
      UncontrolledProviderScope(
        container: container,
        child: const ChickenMapApp(),
      ),
    );
  } catch (error, stackTrace) {
    debugPrint('App bootstrap failed: $error');
    debugPrintStack(stackTrace: stackTrace);
    runApp(_BootstrapErrorApp(message: '$error'));
  }
}

class _BootstrapErrorApp extends StatelessWidget {
  final String message;

  const _BootstrapErrorApp({required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SelectableText('App startup failed:\n$message'),
          ),
        ),
      ),
    );
  }
}
