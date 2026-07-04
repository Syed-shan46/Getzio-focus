import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/hive_database.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../domain/models/vision_item.dart';

class VisionRoomRepository {
  final HiveDatabase _hiveDb;
  final Ref _ref;

  VisionRoomRepository(this._hiveDb, this._ref);

  List<VisionItem> getLocalVisionItems() {
    try {
      final list = _hiveDb.getVisionItems();
      final items = <VisionItem>[];
      for (var json in list) {
        try {
          items.add(VisionItem.fromJson(json));
        } catch (e) {
          dev.log('[VisionRoomRepository] Error parsing individual item: $e');
        }
      }
      return items;
    } catch (e) {
      dev.log('[VisionRoomRepository] Error getting local vision items: $e');
      return [];
    }
  }

  Future<void> saveLocalVisionItems(List<VisionItem> items) async {
    final serialized = items.map((i) => i.toJson()).toList();
    await _hiveDb.saveVisionItems(serialized);
  }

  Future<List<VisionItem>?> fetchVisionRoomFromServer() async {
    final hasToken = _hiveDb.getAuthToken() != null;
    if (!hasToken) return null;

    try {
      final dio = _ref.read(dioClientProvider);
      final response = await dio.get('/focus/vision-room');
      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'];
        final itemsList = data['items'] as List?;
        if (itemsList != null) {
          final items = itemsList.map((itemJson) {
            Map<String, dynamic> parsedMeta = {};
            final fontStr = itemJson['font'] as String?;
            if (fontStr != null && fontStr.trim().startsWith('{') && fontStr.trim().endsWith('}')) {
              try {
                parsedMeta = Map<String, dynamic>.from(jsonDecode(fontStr));
              } catch (_) {}
            }

            final scaleVal = parseDoubleHelper(itemJson['scale'] ?? parsedMeta['scale'], 1.0);
            final opacityVal = parseDoubleHelper(itemJson['opacity'] ?? parsedMeta['opacity'], 1.0);

            final rawId = itemJson['itemId'] ?? itemJson['id'] ?? '';
            final rawType = itemJson['type'] ?? '';
            final rawContent = itemJson['type'] == 'image'
                ? (itemJson['imageUrl'] ?? itemJson['content'] ?? '')
                : (itemJson['text'] ?? itemJson['content'] ?? '');
            final rawX = parseDoubleHelper(itemJson['xPosition'] ?? itemJson['x'], 0.0);
            final rawY = parseDoubleHelper(itemJson['yPosition'] ?? itemJson['y'], 0.0);
            final rawWidth = parseDoubleHelper(itemJson['width'] ?? itemJson['w'], 180.0);
            final rawHeight = parseDoubleHelper(itemJson['height'] ?? itemJson['h'], 120.0);
            final rawRotation = parseDoubleHelper(itemJson['rotation'] ?? itemJson['r'], 0.0);

            final rawColorVal = itemJson['color'] != null && itemJson['color'].toString().isNotEmpty
                ? (int.tryParse(itemJson['color'], radix: 16) ?? (itemJson['colorValue'] as int?) ?? 0xFF1E1B4B)
                : ((itemJson['colorValue'] as int?) ?? 0xFF1E1B4B);

            final rawIsPinned = itemJson['locked'] ?? itemJson['isPinned'] ?? false;

            return VisionItem(
              id: rawId,
              type: rawType,
              content: rawContent,
              x: rawX,
              y: rawY,
              width: rawWidth,
              height: rawHeight,
              rotation: rawRotation,
              colorValue: rawColorVal,
              isPinned: rawIsPinned,
              zIndex: parseIntHelper(itemJson['zIndex'], 0),
              attachmentType: 'tape',
              attachmentStyle: 'beige',
              materialStyle: 'default',
              countdownDate: itemJson['countdownDate'] != null ? DateTime.parse(itemJson['countdownDate']) : null,
              metadata: {
                ...parsedMeta,
                'scale': scaleVal,
                'opacity': opacityVal,
                'font': fontStr ?? '',
                'isOnShelf': parsedMeta['isOnShelf'] == true || itemJson['isOnShelf'] == true || itemJson['isShelfItem'] == true,
                'monthlyAmount': itemJson['monthlyAmount'] as String? ?? parsedMeta['monthlyAmount'] ?? '',
                'description': itemJson['description'] as String? ?? parsedMeta['description'] ?? '',
                'motivation': itemJson['motivation'] as String? ?? parsedMeta['motivation'] ?? '',
                'syncStatus': 'synced',
                'lastSyncedAt': DateTime.now().toIso8601String(),
              }
            );
          }).toList();

          items.sort((a, b) => a.zIndex.compareTo(b.zIndex));
          return items;
        }
      }
    } catch (e) {
      dev.log('[VisionRoomRepository] Error fetching room: $e');
    }
    return null;
  }

  Future<void> queueItemUpsert(VisionItem item, String operation) async {
    final payload = mapItemToDbKeys(item);
    final action = {
      'id': 'vision_${item.id}_${DateTime.now().millisecondsSinceEpoch}',
      'operation': operation,
      'collection': 'vision_room',
      'documentId': item.id,
      'payload': payload,
      'createdAt': DateTime.now().toIso8601String(),
    };
    await _hiveDb.addToPendingSync(action);
  }

  Future<void> queueItemDeletion(String id) async {
    final action = {
      'id': 'vision_delete_${id}_${DateTime.now().millisecondsSinceEpoch}',
      'operation': 'delete',
      'collection': 'vision_room',
      'documentId': id,
      'createdAt': DateTime.now().toIso8601String(),
    };
    await _hiveDb.addToPendingSync(action);
  }

  Map<String, dynamic> mapItemToDbKeys(VisionItem item) {
    final metaMap = {
      'isOnShelf': item.metadata?['isOnShelf'] == true,
      'createdAt': item.metadata?['createdAt'] ?? DateTime.now().toIso8601String(),
      'scale': item.metadata?['scale'] ?? 1.0,
      'opacity': item.metadata?['opacity'] ?? 1.0,
      ...?item.metadata,
    };
    return {
      'itemId': item.id,
      'type': item.type,
      'imageUrl': item.type == 'image' ? item.content : '',
      'text': item.type != 'image' ? item.content : '',
      'color': item.colorValue.toRadixString(16),
      'font': jsonEncode(metaMap),
      'xPosition': item.x,
      'yPosition': item.y,
      'width': item.width,
      'height': item.height,
      'rotation': item.rotation,
      'scale': item.metadata?['scale'] ?? 1.0,
      'zIndex': item.zIndex,
      'opacity': item.metadata?['opacity'] ?? 1.0,
      'locked': item.isPinned,
      'countdownDate': item.countdownDate?.toIso8601String(),
      'isOnShelf': item.metadata?['isOnShelf'] == true,
      'isShelfItem': item.metadata?['isOnShelf'] == true,
      'monthlyAmount': item.metadata?['monthlyAmount'] ?? '',
      'description': item.metadata?['description'] ?? '',
      'motivation': item.metadata?['motivation'] ?? '',
      'metadata': metaMap,
    };
  }
}

final visionRoomRepositoryProvider = Provider<VisionRoomRepository>((ref) {
  final hiveDb = ref.watch(hiveDatabaseProvider);
  return VisionRoomRepository(hiveDb, ref);
});
