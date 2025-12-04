import 'package:labodc_mobile/features/report/data/model/report_model.dart';


class ReportPaginationModel {
  final List<ReportItemModel> items;
  final int totalElements;
  final int totalPages;
  final int currentPage;
  final bool hasNext;
  final bool hasPrevious;

  ReportPaginationModel({
    required this.items,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory ReportPaginationModel.fromJson(Map<String, dynamic> json) {
    final list = json["data"] as List<dynamic>;

    return ReportPaginationModel(
      items: list.map((e) => ReportItemModel.fromJson(e)).toList(),
      totalElements: json["totalElements"],
      totalPages: json["totalPages"],
      currentPage: json["currentPage"],
      hasNext: json["hasNext"],
      hasPrevious: json["hasPrevious"],
    );
  }
}
