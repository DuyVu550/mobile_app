import 'dart:io';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Riverpod Provider for Dependency Injection
final fileUploadServiceProvider = Provider<FileUploadService>((ref) {
  return FileUploadService();
});

class FileUploadService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );
  final String _uploadUrl = "https://agent.api.eternalai.org/api/users/upload";

  /// Tải tệp cục bộ lên server.
  ///
  /// Trả về [Right] chứa URL kết quả (HTTPS) khi thành công,
  /// hoặc [Left] chứa thông điệp lỗi khi thất bại.
  Future<Either<String, String>> uploadFile(File file) async {
    try {
      final formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          file.path,
          // Dùng uri.pathSegments để lấy đúng tên file trên mọi nền tảng
          // (split('/') sẽ hỏng với đường dẫn Windows dùng '\').
          filename: file.uri.pathSegments.last,
        ),
      });

      final response = await _dio.post(
        _uploadUrl,
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final url = _extractUrl(response.data);
        if (url != null) return Right(url);
        return const Left('Phản hồi từ server không chứa URL hợp lệ.');
      }
      return Left('Upload thất bại với mã trạng thái ${response.statusCode}.');
    } on DioException catch (e) {
      developer.log("Lỗi DioException khi upload file: ${e.message}");
      return Left('Lỗi kết nối khi upload: ${e.message ?? e.type.name}');
    } catch (e) {
      developer.log("Lỗi không xác định khi upload file: $e");
      return Left('Lỗi không xác định khi upload: $e');
    }
  }

  /// Trích xuất URL từ các dạng JSON phản hồi thông dụng.
  String? _extractUrl(dynamic data) {
    if (data is! Map) return null;

    final direct = data['url'];
    if (direct is String) return direct;

    final nested = data['data'];
    if (nested is Map && nested['url'] is String) {
      return nested['url'] as String;
    }
    return null;
  }
}
