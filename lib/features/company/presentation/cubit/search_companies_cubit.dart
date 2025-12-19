import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/models/search_request_model.dart';
import '../../../../shared/states/search_state.dart';
import '../../domain/entities/company_entity.dart';
import '../../domain/entities/paginated_company_entity.dart';
import '../../domain/use_cases/search_companies.dart';

class SearchCompaniesCubit extends Cubit<SearchState> {
  final SearchCompanies searchCompaniesUseCase;
  Timer? _debounceTimer;
  SortDirection _currentDirection = SortDirection.desc;

  SearchCompaniesCubit(this.searchCompaniesUseCase) : super(SearchInitial());

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
      filters: [SearchFilter(key: 'name', operator: 'LIKE', value: query)],
      sorts: [
        SearchSort(key: 'createdAt', direction: direction),
      ],
      page: page,
      size: size,
    );

    final result = await searchCompaniesUseCase(SearchCompaniesParams(request: request));

    result.fold(
      (failure) => emit(SearchError(failure.message)),
      (PaginatedCompanyEntity data) => emit(SearchLoaded<CompanyEntity>(
        items: data.companies,
        totalElements: data.totalElements,
        totalPages: data.totalPages,
        currentPage: data.currentPage,
        hasNext: data.hasNext,
      )),
    );
  }

  void loadMore(String query, int currentPage, int size) {
    if (state is SearchLoaded<CompanyEntity>) {
      final currentState = state as SearchLoaded<CompanyEntity>;
      if (currentState.hasNext) {
        _performSearch(query, page: currentPage + 1, size: size, direction: _currentDirection);
      }
    }
  }

  void clearSearch() {
    _debounceTimer?.cancel();
    emit(SearchInitial());
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}