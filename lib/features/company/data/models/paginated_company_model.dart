import '../../domain/entities/paginated_company_entity.dart';
import 'company_model.dart';

class PaginatedCompanyModel extends PaginatedCompanyEntity {
  const PaginatedCompanyModel({
    required super.companies,
    required super.totalElements,
    required super.totalPages,
    required super.currentPage,
    required super.hasNext,
  });

  factory PaginatedCompanyModel.fromJson(Map<String, dynamic> json) {
    final dataNode = json['data'] ?? json;
    List<dynamic> listRaw = [];
    int totalElements = 0;
    int totalPages = 1;
    int currentPage = 1;
    bool hasNext = false;

    try {
      if (dataNode is Map<String, dynamic>) {
        if (dataNode['data'] is List) {
          listRaw = dataNode['data'] as List<dynamic>;
        } else if (dataNode['companies'] is List) {
          listRaw = dataNode['companies'] as List<dynamic>;
        } else if (dataNode['items'] is List) {
          listRaw = dataNode['items'] as List<dynamic>;
        } else if (dataNode is List) {
          listRaw = dataNode as List<dynamic>;
        }

        totalElements = (dataNode['totalElements'] ?? dataNode['total'] ?? 0) is int
            ? (dataNode['totalElements'] ?? dataNode['total'] ?? 0) as int
            : int.tryParse((dataNode['totalElements'] ?? dataNode['total'] ?? '0').toString()) ?? 0;

        totalPages = (dataNode['totalPages'] ?? dataNode['pages'] ?? 1) is int
            ? (dataNode['totalPages'] ?? dataNode['pages'] ?? 1) as int
            : int.tryParse((dataNode['totalPages'] ?? dataNode['pages'] ?? '1').toString()) ?? 1;

        currentPage = (dataNode['currentPage'] ?? dataNode['page'] ?? 1) is int
            ? (dataNode['currentPage'] ?? dataNode['page'] ?? 1) as int
            : int.tryParse((dataNode['currentPage'] ?? dataNode['page'] ?? '1').toString()) ?? 1;

        hasNext = (dataNode['hasNext'] ?? dataNode['has_more'] ?? false) == true;
      } else if (dataNode is List) {
        listRaw = dataNode;
      }
    } catch (_) {
      listRaw = [];
      totalElements = 0;
      totalPages = 1;
      currentPage = 1;
      hasNext = false;
    }

    final companies = listRaw
        .whereType<Map<String, dynamic>>()
        .map((c) => CompanyModel.fromJson(c))
        .toList();

    return PaginatedCompanyModel(
      companies: companies,
      totalElements: totalElements,
      totalPages: totalPages,
      currentPage: currentPage,
      hasNext: hasNext,
    );
  }
}