import '../../../../core/error/exceptions.dart';

class UploadedFileModel {
  final String id;
  final String fileName;
  final String fileUrl;

  UploadedFileModel({required this.id, required this.fileName, required this.fileUrl});

  factory UploadedFileModel.fromJson(Map<String, dynamic> json) {
    try {
      final data = json['data'];
      if (data == null) throw ServerException('Dữ liệu phản hồi thiếu', statusCode: 200);
      return UploadedFileModel(
        id: data['id'] ?? '',
        fileName: data['fileName'] ?? 'Unknown',
        fileUrl: data['fileUrl'] ?? '',
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Lỗi phân tích phản hồi upload: $e');
    }
  }
}