import 'package:equatable/equatable.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {
  final bool isFirstLoad;

  const SearchLoading({this.isFirstLoad = true});

  @override
  List<Object?> get props => [isFirstLoad];
}

class SearchLoaded<T> extends SearchState {
  final List<T> items;
  final int totalElements;
  final int totalPages;
  final int currentPage;
  final bool hasNext;

  const SearchLoaded({
    required this.items,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
    required this.hasNext,
  });

  @override
  List<Object?> get props => [items, totalElements, totalPages, currentPage, hasNext];
}

class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);

  @override
  List<Object?> get props => [message];
}