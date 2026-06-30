import 'package:dio/dio.dart';
import '../../domain/models/sticky_note.dart';

class StickyNoteRemoteDataSource {
  final Dio dio;

  StickyNoteRemoteDataSource({required this.dio});

  Future<StickyNote> createStickyNote(StickyNote stickyNote) async {
    final response = await dio.post('/sticky-notes', data: stickyNote.toJson());
    return StickyNote.fromJson(response.data);
  }

  Future<List<StickyNote>> getStickyNotes(String userId) async {
    final response = await dio.get('/sticky-notes', queryParameters: {'userId': userId});
    return (response.data as List).map((e) => StickyNote.fromJson(e)).toList();
  }

  Future<StickyNote> updateStickyNote(StickyNote stickyNote) async {
    final response = await dio.patch('/sticky-notes/${stickyNote.id}', data: stickyNote.toJson());
    return StickyNote.fromJson(response.data);
  }

  Future<StickyNote> deleteStickyNote(String id) async {
    final response = await dio.delete('/sticky-notes/$id');
    return StickyNote.fromJson(response.data);
  }
}
