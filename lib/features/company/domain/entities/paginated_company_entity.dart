import 'package:equatable/equatable.dart';
import 'company_entity.dart';

class PaginatedCompanyEntity extends Equatable {
  final List<CompanyEntity> companies;
  final int totalElements;
  final int totalPages;
  final int currentPage;
  final bool hasNext;

  const PaginatedCompanyEntity({
    required this.companies,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
    required this.hasNext,
  });

  @override
  List<Object?> get props => [companies, totalElements, totalPages, currentPage, hasNext];
}