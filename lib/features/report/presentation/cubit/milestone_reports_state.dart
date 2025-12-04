import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:labodc_mobile/features/report/data/model/report_model.dart';

import '../../domain/repositories/report_repository.dart';

class MilestoneReportsState {
  final bool isLoading;
  final List<ReportItemModel> reports;
  final String? error;

  MilestoneReportsState({
    required this.isLoading,
    required this.reports,
    this.error,
  });

  factory MilestoneReportsState.initial() => MilestoneReportsState(
    isLoading: false,
    reports: [],
    error: null,
  );

  MilestoneReportsState copyWith({
    bool? isLoading,
    List<ReportItemModel>? reports,
    String? error,
  }) {
    return MilestoneReportsState(
      isLoading: isLoading ?? this.isLoading,
      reports: reports ?? this.reports,
      error: error,
    );
  }
}

class MilestoneReportsCubit extends Cubit<MilestoneReportsState> {
  final ReportRepository repo;

  MilestoneReportsCubit(this.repo)
      : super(MilestoneReportsState.initial());

  Future<void> loadReports(String milestoneId) async {
    emit(state.copyWith(isLoading: true, error: null));

    final result = await repo.getMilestoneReports(
      milestoneId,
      page: 1,
      size: 20,
    );

    result.fold(
          (fail) => emit(state.copyWith(isLoading: false, error: fail.message)),
          (data) => emit(state.copyWith(isLoading: false, reports: data.data)),
    );
  }
}
