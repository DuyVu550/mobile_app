import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
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
  
  // Load UPLOAD_URL from environment define, default to catbox.moe if not provided
  final String _uploadUrl = const String.fromEnvironment(
    'UPLOAD_URL',
    defaultValue: "https://catbox.moe/user/api.php",
  );

  /// Tải tệp lên server bằng bytes dữ liệu.
  ///
  /// Trên Web, để tránh lỗi CORS và hỗ trợ chạy thử nghiệm nhanh ở môi trường local debug,
  /// chúng ta trả về trực tiếp dữ liệu dạng Base64 Data URI.
  ///
  /// Trả về [Right] chứa URL kết quả (HTTPS hoặc Base64 Data URI) khi thành công,
  /// hoặc [Left] chứa thông điệp lỗi khi thất bại.
  Future<Either<String, String>> uploadFile(
    Uint8List bytes,
    String filename, {
    String? webBlobUrl,
  }) async {
    if (kIsWeb) {
      final base64String = base64Encode(bytes);
      String mimeType = 'image/jpeg';
      if (filename.toLowerCase().endsWith('.png')) {
        mimeType = 'image/png';
      } else if (filename.toLowerCase().endsWith('.gif')) {
        mimeType = 'image/gif';
      } else if (filename.toLowerCase().endsWith('.webp')) {
        mimeType = 'image/webp';
      }
      developer.log("Web platform: generated base64 Data URI for image persistence.");
      return Right('data:$mimeType;base64,$base64String');
    }

    try {
      final formData = FormData.fromMap({
        "reqtype": "fileupload",
        "fileToUpload": MultipartFile.fromBytes(
          bytes,
          filename: filename,
        ),
      });

      final response = await _dio.post(
        _uploadUrl,
        data: formData,
      );

      if (response.statusCode == 200) {
        final rawResponse = response.data;
        if (rawResponse is String && rawResponse.startsWith("https://files.catbox.moe/")) {
          return Right(rawResponse.trim());
        }
        return Left('Phản hồi không hợp lệ từ server: $rawResponse');
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
}

