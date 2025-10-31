import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/hotel_model.dart';
import '../../../services/api_service.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final ApiService apiService;

  SearchBloc(this.apiService) : super(SearchInitial()) {
    on<FetchHotelsEvent>(_onFetchHotels);
    on<LoadMoreHotelsEvent>(_onLoadMoreHotels);
  }

  /// API for fetching hotels
  Future<void> _onFetchHotels(
      FetchHotelsEvent event, Emitter<SearchState> emit) async {
    emit(SearchLoading());
    try {
      final hotels = await apiService.getSearchResult(
        page: event.page,
        selectedSearchType: event.selectedSearchType,
          searchQuery: event.searchQuery
      );
      emit(SearchLoaded(hotels: hotels, hasMore: hotels.isNotEmpty));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  ///just writtern logic for pgination
  Future<void> _onLoadMoreHotels(
      LoadMoreHotelsEvent event, Emitter<SearchState> emit) async {
    if (state is! SearchLoaded) return;

    final currentState = state as SearchLoaded;
    try {
      final newHotels = await apiService.getSearchResult(
        page: event.page,
      );

      final updatedList = List<HotelModel>.from(currentState.hotels)
        ..addAll(newHotels);

      emit(currentState.copyWith(
        hotels: updatedList,
        hasMore: newHotels.isNotEmpty,
      ));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }
}
