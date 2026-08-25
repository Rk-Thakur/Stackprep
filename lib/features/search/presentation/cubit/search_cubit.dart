import 'package:flutter_bloc/flutter_bloc.dart';

import 'search_state.dart';

/// Holds the search field text and active filter chip selection.
/// Results are not wired yet — discovery is still a static MVP surface.
class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(const SearchState());

  void queryChanged(String query) => emit(state.copyWith(query: query));

  void filterSelected(String filter) =>
      emit(state.copyWith(selectedFilter: filter));
}
