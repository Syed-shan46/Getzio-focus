import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/storage/hive_database.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../domain/models/affirmation_model.dart';

class AffirmationsRepository {
  final HiveDatabase _hiveDb;
  final Ref _ref;

  AffirmationsRepository(this._hiveDb, this._ref);

  // Read local affirmations from Hive
  List<DailyAffirmation> getLocalAffirmations() {
    final List<Map<String, dynamic>> maps = _hiveDb.getSelectedAffirmations();
    return maps.map((m) => DailyAffirmation.fromMap(m)).toList();
  }

  // Save affirmations locally to Hive
  Future<void> saveLocalAffirmations(List<DailyAffirmation> list) async {
    final mapped = list.map((a) => a.toMap()).toList();
    await _hiveDb.saveSelectedAffirmations(mapped);
  }

  // Fetch affirmations from server
  Future<List<DailyAffirmation>?> fetchAffirmationsFromServer() async {
    final hasToken = _hiveDb.getAuthToken() != null;
    if (!hasToken) return null;

    try {
      final dio = _ref.read(dioClientProvider);
      final response = await dio.get('/focus/affirmations');
      if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
        final List<DailyAffirmation> fetched = [];
        final data = response.data['data'] as List?;
        if (data != null) {
          for (var groupJson in data) {
            final dynamic rawGroupCat = groupJson['category'] ?? groupJson['name'] ?? groupJson['_id'];
            String groupCategory = 'General';
            if (rawGroupCat is Map) {
              groupCategory = rawGroupCat['name'] as String? ?? rawGroupCat['title'] as String? ?? 'General';
            } else if (rawGroupCat != null) {
              groupCategory = rawGroupCat.toString();
            }

            final affs = groupJson['affirmations'] as List?;
            if (affs != null) {
              for (var affJson in affs) {
                final Map<String, dynamic> mutable = Map<String, dynamic>.from(affJson);
                
                final dynamic rawAffCat = mutable['category'];
                String? affCategory;
                if (rawAffCat is Map) {
                  affCategory = rawAffCat['name'] as String? ?? rawAffCat['title'] as String? ?? 'General';
                } else if (rawAffCat != null) {
                  affCategory = rawAffCat.toString();
                }

                if (affCategory == null || affCategory.trim().isEmpty) {
                  mutable['category'] = groupCategory;
                } else {
                  mutable['category'] = affCategory;
                }
                fetched.add(DailyAffirmation.fromMap(mutable));
              }
            }
          }
        }

        // Filter out pending deletions so they do not reappear
        final pendingDeletions = _hiveDb.getPendingDeletions();
        fetched.removeWhere((item) => pendingDeletions.contains(item.id));

        return fetched;
      }
      return null;
    } catch (e) {
      dev.log('[AffirmationsRepo] Error fetching affirmations: $e');
      return null;
    }
  }

  // Sync affirmations to backend
  Future<bool> syncWithBackend(List<DailyAffirmation> list) async {
    final hasToken = _hiveDb.getAuthToken() != null;
    if (!hasToken) {
      dev.log('[AffirmationsRepo] No auth token, skipping backend sync.');
      return false;
    }

    try {
      final dio = _ref.read(dioClientProvider);

      // Build grouped categories format for sync
      final payload = {
        'affirmations': list
            .map(
              (a) {
                return {
                  'id': a.id,
                  'localId': a.id,
                  'title': a.title,
                  'text': a.text,
                  'author': a.author ?? 'Anonymous',
                  'category': a.category,
                  'emoji': a.emoji ?? '',
                  'isFavorite': a.isFavorite,
                  'isPinned': a.isPinned,
                  'colorTheme': a.colorTheme,
                  'createdAt': a.createdAt?.toIso8601String(),
                };
              },
            )
            .toList(),
      };

      final response = await dio.post('/focus/sync', data: payload);
      if (response.statusCode == 200) {
        dev.log('[AffirmationsRepo] Online sync completed successfully.');
        // Clear pending deletions queue since server matches local state now
        await _hiveDb.savePendingDeletions([]);
        return true;
      }
      return false;
    } catch (e) {
      dev.log('[AffirmationsRepo] Error syncing affirmations: $e');
      return false;
    }
  }

  Future<void> trackPendingDeletion(String id) async {
    final deletions = _hiveDb.getPendingDeletions();
    if (!deletions.contains(id)) {
      deletions.add(id);
      await _hiveDb.savePendingDeletions(deletions);
    }
  }

  // Single-affirmation create on backend (optional fallback/direct CRUD)
  Future<DailyAffirmation?> createAffirmationOnServer(
    DailyAffirmation affirmation,
  ) async {
    final hasToken = _hiveDb.getAuthToken() != null;
    if (!hasToken) return null;

    try {
      final dio = _ref.read(dioClientProvider);
      final response = await dio.post(
        '/focus/affirmations',
        data: affirmation.toMap(),
      );
      if (response.statusCode == 201 && response.data != null) {
        final data = response.data['data'];
        if (data != null) {
          return DailyAffirmation.fromMap(data);
        }
      }
      return null;
    } catch (e) {
      dev.log('[AffirmationsRepo] Error creating affirmation: $e');
      return null;
    }
  }
}

// Providers
final affirmationsRepositoryProvider = Provider<AffirmationsRepository>((ref) {
  final hiveDb = ref.watch(hiveDatabaseProvider);
  return AffirmationsRepository(hiveDb, ref);
});
