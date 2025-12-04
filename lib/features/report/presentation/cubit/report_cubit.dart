import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/report_repository.dart';
import 'report_state.dart';

class ReportCubit extends Cubit<ReportState> {
  final ReportRepository repository;

  ReportCubit({
    required this.repository,
    required bool isSent,
  }) : super(ReportState.initial(isSent));

  static const int pageSize = 10;

  /// Load lần đầu
  Future<void> loadReports() async {
    emit(state.copyWith(status: ReportStatus.loading));

    final result = state.isSent
        ? await repository.getSentReports(page: 1, size: pageSize)
        : await repository.getReceivedReports(page: 1, size: pageSize);

    result.fold(
          (failure) {
        emit(state.copyWith(
          status: ReportStatus.failure,
          errorMessage: failure.message,
        ));
      },
          (pagination) {
        emit(state.copyWith(
          status: ReportStatus.success,
          items: pagination.items,
          currentPage: pagination.currentPage,
          hasNext: pagination.hasNext,
          hasPrevious: pagination.hasPrevious,
        ));
      },
    );
  }

  /// Refresh
  Future<void> refreshReports() async {
    await loadReports();
  }

  /// Load thêm trang (pagination)
  Future<void> loadMore() async {
    if (state.status == ReportStatus.loadingMore) return;
    if (!state.hasNext) return;

    emit(state.copyWith(status: ReportStatus.loadingMore));

    final nextPage = state.currentPage + 1;

    final result = state.isSent
        ? await repository.getSentReports(page: nextPage, size: pageSize)
        : await repository.getReceivedReports(page: nextPage, size: pageSize);

    result.fold(
          (failure) {
        emit(state.copyWith(
          status: ReportStatus.failure,
          errorMessage: failure.message,
        ));
      },
          (pagination) {
        emit(state.copyWith(
          status: ReportStatus.success,
          items: [...state.items, ...pagination.items],
          currentPage: pagination.currentPage,
          hasNext: pagination.hasNext,
          hasPrevious: pagination.hasPrevious,
        ));
      },
    );
  }
}
