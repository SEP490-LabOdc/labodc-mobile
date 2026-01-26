import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:labodc_mobile/core/error/failures.dart';
import 'package:labodc_mobile/features/milestone/data/models/project_milestone_model.dart';
import 'package:labodc_mobile/features/milestone/domain/enums/project_milestone_status.dart';
import 'package:labodc_mobile/features/milestone/domain/repositories/milestone_repository.dart';
import 'package:labodc_mobile/features/project_application/data/models/my_project_model.dart';
import 'package:labodc_mobile/features/project_application/domain/repositories/project_application_repository.dart';

import 'project_fund_state.dart';

class ProjectFundCubit extends Cubit<ProjectFundState> {
  final ProjectApplicationRepository projectApplicationRepository;
  final MilestoneRepository milestoneRepository;

  ProjectFundCubit({
    required this.projectApplicationRepository,
    required this.milestoneRepository,
  }) : super(const ProjectFundState());

  /// Gọi khi mở màn
  Future<void> loadInitial() async {
    emit(state.copyWith(isLoadingProjects: true, clearError: true));

    try {
      // getMyProjects: Future<Either<Failure, List<MyProjectModel>>>
      final projectsResult = await projectApplicationRepository.getMyProjects(
        status: null,
      );

      await projectsResult.fold(
        (failure) async {
          emit(
            state.copyWith(
              isLoadingProjects: false,
              isLoadingMilestones: false,
              errorMessage: failure.message,
            ),
          );
        },
        (projects) async {
          MyProjectModel? selectedProject;
          List<ProjectMilestoneModel> milestones = const [];
          double holding = 0;
          double distributed = 0;
          String? errorMessage;

          if (projects.isNotEmpty) {
            selectedProject = projects.first;

            final milestonesResult = await milestoneRepository
                .getPaidMilestones(selectedProject.id);

            milestonesResult.fold(
              (failure) {
                errorMessage = failure.message;
              },
              (list) {
                milestones = list;
                final calc = _calculateFund(list);
                holding = calc.$1;
                distributed = calc.$2;
              },
            );
          }

          emit(
            state.copyWith(
              projects: projects,
              selectedProject: selectedProject,
              milestones: milestones,
              holdingAmount: holding,
              distributedAmount: distributed,
              isLoadingProjects: false,
              isLoadingMilestones: false,
              errorMessage: errorMessage,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingProjects: false,
          isLoadingMilestones: false,
          errorMessage: 'Không thể tải dữ liệu: $e',
        ),
      );
    }
  }

  /// Khi chọn 1 project khác
  Future<void> selectProject(MyProjectModel project) async {
    emit(
      state.copyWith(
        selectedProject: project,
        isLoadingMilestones: true,
        milestones: const [],
        clearError: true,
      ),
    );

    try {
      // getMilestones: Future<Either<Failure, List<ProjectMilestoneModel>>>
      final milestonesResult = await milestoneRepository.getPaidMilestones(
        project.id,
      );

      milestonesResult.fold(
        (failure) {
          emit(
            state.copyWith(
              isLoadingMilestones: false,
              errorMessage: failure.message,
            ),
          );
        },
        (milestones) {
          final calc = _calculateFund(milestones);
          emit(
            state.copyWith(
              milestones: milestones,
              holdingAmount: calc.$1,
              distributedAmount: calc.$2,
              isLoadingMilestones: false,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingMilestones: false,
          errorMessage: 'Không thể tải milestones: $e',
        ),
      );
    }
  }

  /// Tính quỹ từ danh sách milestone:
  /// - COMPLETED  => Đã chia
  /// - còn lại    => Đang giữ
  (double, double) _calculateFund(List<ProjectMilestoneModel> milestones) {
    double holding = 0;
    double distributed = 0;

    for (final m in milestones) {
      final b = m.budget; // double
      final status = ProjectMilestoneStatus.fromString(m.status);

      if (status == ProjectMilestoneStatus.COMPLETED) {
        distributed += b;
      } else {
        holding += b;
      }
    }

    return (holding, distributed);
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }
}
