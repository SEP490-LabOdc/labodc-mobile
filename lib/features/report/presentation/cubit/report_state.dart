import 'package:equatable/equatable.dart';

import '../../data/model/report_model.dart';


enum ReportStatus {
  initial,
  loading,
  success,
  failure,
  loadingMore,
}

class ReportState extends Equatable {
  final ReportStatus status;
  final List<ReportItemModel> items;
  final String? errorMessage;

  final int currentPage;
  final bool hasNext;
  final bool hasPrevious;

  final bool isSent; // true = sent, false = received

  const ReportState({
    required this.status,
    required this.items,
    required this.isSent,
    this.errorMessage,
    this.currentPage = 1,
    this.hasNext = false,
    this.hasPrevious = false,
  });

  factory ReportState.initial(bool isSent) => ReportState(
    status: ReportStatus.initial,
    items: const [],
    isSent: isSent,
    currentPage: 1,
  );

  ReportState copyWith({
    ReportStatus? status,
    List<ReportItemModel>? items,
    String? errorMessage,
    int? currentPage,
    bool? hasNext,
    bool? hasPrevious,
    bool? isSent,
  }) {
    return ReportState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasNext: hasNext ?? this.hasNext,
      hasPrevious: hasPrevious ?? this.hasPrevious,
      isSent: isSent ?? this.isSent,
    );
  }

  @override
  List<Object?> get props => [
    status,
    items,
    errorMessage,
    currentPage,
    hasNext,
    hasPrevious,
    isSent,
  ];
}
