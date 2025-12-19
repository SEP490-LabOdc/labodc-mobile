import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/models/search_request_model.dart';
import '../../../../shared/states/search_state.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/entities/paginated_project_entity.dart';
import '../../domain/use_cases/search_projects.dart';

class SearchProjectsCubit extends Cubit<SearchState> {
  final SearchProjects searchProjectsUseCase;
  Timer? _debounceTimer;
  SortDirection _currentDirection = SortDirection.desc;

  SearchProjectsCubit(this.searchProjectsUseCase) : super(SearchInitial());

  void search(String query, {int page = 1, int size = 10, SortDirection direction = SortDirection.desc}) {
    if (query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    _currentDirection = direction;

    // Debounce search
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query, page: page, size: size, direction: direction);
    });
  }

  Future<void> _performSearch(String query, {int page = 1, int size = 10, SortDirection direction = SortDirection.desc}) async {
    final isFirstLoad = page == 1;
    emit(SearchLoading(isFirstLoad: isFirstLoad));

    final request = SearchRequest(
      filters: [SearchFilter(key: 'title', operator: 'LIKE', value: query)],
      sorts: [
        SearchSort(key: 'createdAt', direction: direction),
      ],
      page: page,
      size: size,
    );

    final result = await searchProjectsUseCase(SearchProjectsParams(request: request));

    result.fold(
      (failure) => emit(SearchError(failure.message)),
      (PaginatedProjectEntity data) => emit(SearchLoaded<ProjectEntity>(
        items: data.projects,
        totalElements: data.totalElements,
        totalPages: data.totalPages,
        currentPage: data.currentPage,
        hasNext: data.hasNext,
      )),
    );
  }

  void loadMore(String query, int currentPage, int size) {
    if (state is SearchLoaded<ProjectEntity>) {
      final currentState = state as SearchLoaded<ProjectEntity>;
      if (currentState.hasNext) {
        _performSearch(query, page: currentPage + 1, size: size, direction: _currentDirection);
      }
    }
  }

  void testSorting() async {
    debugPrint("🧪 Testing ASC sort...");
    await _performSearch("r", page: 1, size: 10, direction: SortDirection.asc);
    
    await Future.delayed(const Duration(seconds: 2));
    
    debugPrint("🧪 Testing DESC sort...");
    await _performSearch("r", page: 1, size: 10, direction: SortDirection.desc);
  }

  void clearSearch() {
    emit(SearchInitial());
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}