import 'package:equatable/equatable.dart';

class CompanyDocumentModel extends Equatable {
  final String id;
  final String? fileName;
  final String fileUrl;
  final String type;

  const CompanyDocumentModel({
    required this.id,
    this.fileName,
    required this.fileUrl,
    required this.type,
  });

  factory CompanyDocumentModel.fromJson(Map<String, dynamic> json) {
    return CompanyDocumentModel(
      id: json['id'] as String? ?? '',
      // JSON trả về null, nên ta dùng as String?
      fileName: json['fileName'] as String?,
      // Nếu fileUrl null thì gán chuỗi rỗng để tránh crash
      fileUrl: json['fileUrl'] as String? ?? '',
      type: json['type'] as String? ?? 'OTHER',
    );
  }

  @override
  List<Object?> get props => [id, fileName, fileUrl, type];
}