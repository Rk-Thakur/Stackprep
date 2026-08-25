import 'package:equatable/equatable.dart';

class SearchState extends Equatable {
  const SearchState({this.query = '', this.selectedFilter = 'All Types'});

  final String query;
  final String selectedFilter;

  SearchState copyWith({String? query, String? selectedFilter}) {
    return SearchState(
      query: query ?? this.query,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }

  @override
  List<Object?> get props => [query, selectedFilter];
}
