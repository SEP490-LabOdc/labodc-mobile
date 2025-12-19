import 'package:equatable/equatable.dart';

enum SortDirection {
  asc('ASC'),
  desc('DESC');

  const SortDirection(this.value);
  final String value;
}

class SearchFilter extends Equatable {
  final String key;
  final String operator;
  final String value;

  const SearchFilter({
    required this.key,
    required this.operator,
    required this.value,
  });

  Map<String, dynamic> toJson() => {
    'key': key,
    'operator': operator,
    'value': value,
  };

  @override
  List<Object?> get props => [key, operator, value];
}

class SearchSort extends Equatable {
  final String key;
  final SortDirection direction;

  const SearchSort({
    required this.key,
    required this.direction,
  });

  Map<String, dynamic> toJson() => {
    'key': key,
    'direction': direction.value,
  };

  @override
  List<Object?> get props => [key, direction];
}

class SearchRequest extends Equatable {
  final List<SearchFilter> filters;
  final List<SearchSort> sorts;
  final int page;
  final int size;

  const SearchRequest({
    required this.filters,
    required this.sorts,
    required this.page,
    required this.size,
  });

  Map<String, dynamic> toJson() => {
    'filters': filters.map((f) => f.toJson()).toList(),
    'sorts': sorts.map((s) => s.toJson()).toList(),
    'page': page,
    'size': size,
  };

  @override
  List<Object?> get props => [filters, sorts, page, size];
}