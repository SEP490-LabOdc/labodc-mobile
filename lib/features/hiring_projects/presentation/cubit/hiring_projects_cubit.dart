import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/use_cases/get_hiring_projects.dart';
import 'hiring_projects_state.dart';

const int _initialPage = 1;
const int _initialPageSize = 10;
const int _subsequentPageSize = 5;

class HiringProjectsCubit extends Cubit<HiringProjectsState> {
  final GetHiringProjects getHiringProjects;

  HiringProjectsCubit(this.getHiringProjects) : super(HiringProjectsInitial());

  List<ProjectEntity> _allProjects = [];
  int _currentPage = _initialPage;
  bool _isLoadingMore = false;
  int _currentDisplayLimit = 3;

  // --- Helper Getters cho UI (đã thêm) ---
  int getInitialPageSize() => _initialPageSize;
  int getSubsequentPageSize() => _subsequentPageSize;
  int getCurrentDisplayLimit() => _currentDisplayLimit;
  // ---------------------------------------

  Future<void> loadInitialProjects() async {
    if (_allProjects.isNotEmpty) {
      emit((state as HiringProjectsLoaded).copyWith(displayLimit: 3));
      return;
    }

    emit(HiringProjectsLoading([], isFirstFetch: true));

    final result = await getHiringProjects(
      GetHiringProjectsParams(page: _initialPage, pageSize: _initialPageSize),
    );

    result.fold(
      // Sử dụng trực tiếp failure.message
          (failure) => emit(HiringProjectsError(failure.message)),
          (data) {
        _allProjects = data.projects;
        _currentPage = data.currentPage;
        _currentDisplayLimit = 3;

        emit(HiringProjectsLoaded(
          projects: _allProjects,
          totalElements: data.totalElements,
          currentPage: data.currentPage,
          pageSize: _initialPageSize,
          hasNext: data.hasNext,
          displayLimit: _currentDisplayLimit,
        ));
      },
    );
  }

  void viewAllProjects() {
    if (state is HiringProjectsLoaded) {
      final currentState = state as HiringProjectsLoaded;

      if (_currentDisplayLimit == 3) {
        // Chuyển từ 3 lên 10
        _currentDisplayLimit = _initialPageSize;
      }

      emit(currentState.copyWith(displayLimit: _currentDisplayLimit));

      // Nếu có data để tải thêm, gọi loadMore để chuẩn bị data cho lần scroll tiếp theo
      if (currentState.hasNext && _allProjects.length >= _initialPageSize) {
        loadMoreProjects();
      }
    }
  }

  Future<void> loadMoreProjects() async {
    if (_isLoadingMore || !(state is HiringProjectsLoaded)) return;

    final currentState = state as HiringProjectsLoaded;
    if (!currentState.hasNext) return;

    _isLoadingMore = true;
    _currentDisplayLimit += _subsequentPageSize; // Tăng limit lên 5

    emit(HiringProjectsLoading(_allProjects));

    final result = await getHiringProjects(
      GetHiringProjectsParams(
        page: _currentPage + 1,
        pageSize: _subsequentPageSize,
      ),
    );

    result.fold(
          (failure) {
        _isLoadingMore = false;
        emit(currentState.copyWith(
          displayLimit: _currentDisplayLimit - _subsequentPageSize,
        ));
        print('Lỗi tải thêm dự án: ${failure.message}');
      },
          (data) {
        _allProjects.addAll(data.projects);
        _currentPage = data.currentPage;
        _isLoadingMore = false;

        emit(currentState.copyWith(
          projects: _allProjects,
          currentPage: data.currentPage,
          hasNext: data.hasNext,
          displayLimit: _currentDisplayLimit,
          totalElements: data.totalElements,
        ));
      },
    );
  }
}