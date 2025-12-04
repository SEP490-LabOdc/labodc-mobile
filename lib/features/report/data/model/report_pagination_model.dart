import 'package:labodc_mobile/features/report/data/model/report_model.dart';

class ReportPaginationModel {
  final List<ReportItemModel> data;
  final int totalElements;
  final int totalPages;
  final int currentPage;
  final bool hasNext;
  final bool hasPrevious;

  ReportPaginationModel({
    required this.data,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory ReportPaginationModel.fromJson(Map<String, dynamic> json) {
    return ReportPaginationModel(
      data: (json["data"] as List<dynamic>)
          .map((e) => ReportItemModel.fromJson(e))
          .toList(),
      totalElements: json["totalElements"] ?? 0,
      totalPages: json["totalPages"] ?? 0,
      currentPage: json["currentPage"] ?? 0,
      hasNext: json["hasNext"] ?? false,
      hasPrevious: json["hasPrevious"] ?? false,
    );
  }
}
