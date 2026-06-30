import 'package:dio/dio.dart';
import '../../../../config/env.dart';

class VisionUploadService {
  final Dio _dio;

  VisionUploadService({required Dio dio}) : _dio = dio;

  Future<String?> uploadImage(String filePath) async {
    try {
      final fileName = filePath.split('/').last;
      
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final url = EnvConfig.baseUrl.endsWith('/')
          ? '${EnvConfig.baseUrl}focus/upload'
          : '${EnvConfig.baseUrl}/focus/upload';

      final response = await _dio.post(url, data: formData);

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['url'] as String;
      }
      return null;
    } catch (e) {
      print('Upload Error: $e');
      return null;
    }
  }
}
