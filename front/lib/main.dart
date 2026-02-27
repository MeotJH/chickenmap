import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/app/app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front/presentation/utils/naver_map_init.dart';

// 앱 시작 지점: Riverpod 스코프와 앱 위젯을 연결한다.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final clientId = dotenv.env['NAVER_MAP_CLIENT_ID'];
  if (clientId == null || clientId.isEmpty) {
    throw StateError('NAVER_MAP_CLIENT_ID is missing in .env');
  }
  await initNaverMap(clientId);

  runApp(const ProviderScope(child: ChickenMapApp()));
}
