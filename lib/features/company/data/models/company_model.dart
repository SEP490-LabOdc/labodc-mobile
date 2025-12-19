import 'package:equatable/equatable.dart';
import '../../domain/entities/company_entity.dart';
import 'company_document_model.dart'; // Đảm bảo bạn đã có file này và import đúng đường dẫn

class CompanyModel extends CompanyEntity {
  final List<CompanyDocumentModel> documents;

  const CompanyModel({
    required super.id,
    required super.name,
    required super.email,
    super.phone,
    super.taxCode,
    required super.address,
    required super.status,
    super.description,
    super.website,
    super.domain,
    super.userId,
    super.contactPersonName,
    super.contactPersonEmail,
    super.contactPersonPhone,
    super.createdAt,
    this.documents = const [],
    super.logoUrl,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    // 1. Xử lý documents an toàn
    List<CompanyDocumentModel> safeDocuments = [];
    if (json['getCompanyDocumentResponses'] != null) {
      safeDocuments = (json['getCompanyDocumentResponses'] as List)
          .map((e) => CompanyDocumentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return CompanyModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Chưa cập nhật tên',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      taxCode: json['taxCode'] as String?,
      address: json['address'] as String? ?? 'Địa chỉ không rõ',

      // Xử lý status mặc định nếu null
      status: json['status'] as String? ?? 'PENDING',

      description: json['description'] as String?,
      website: json['website'] as String?,
      domain: json['domain'] as String?,
      userId: json['userId'] as String?,
      contactPersonName: json['contactPersonName'] as String?,
      contactPersonEmail: json['contactPersonEmail'] as String?,
      contactPersonPhone: json['contactPersonPhone'] as String?,
      createdAt: json['createdAt'] as String?,

      documents: safeDocuments,
      logoUrl: json['logoUrl'] as String?,
    );
  }
}

class CompanyListResponse {
  final List<CompanyModel> companies;

  const CompanyListResponse({required this.companies});

  factory CompanyListResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];

    return CompanyListResponse(
      companies: dataList
          .map((item) => CompanyModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}