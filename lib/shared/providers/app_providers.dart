import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_client.dart';
import '../../core/storage/hive_database.dart';

final hiveDatabaseProvider = Provider<HiveDatabase>((ref) {
  throw UnimplementedError('HiveDatabase must be initialized in main.dart');
});

final dioClientProvider = Provider<DioClient>((ref) {
  final hiveDb = ref.watch(hiveDatabaseProvider);
  return DioClient(hiveDb);
});
