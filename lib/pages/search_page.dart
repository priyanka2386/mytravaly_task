import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/hotel_model.dart';
import '../../services/api_service.dart';
import '../bloc/search/search_bloc.dart';
import '../bloc/search/search_event.dart';
import '../bloc/search/search_state.dart';
import 'package:shimmer/shimmer.dart';

import '../widgets/hotel_widgets.dart';

class SearchResultsPage extends StatefulWidget {
  final String selectedSearchType;
  final List<String> searchQuery;

  const SearchResultsPage({
    super.key,
    required this.selectedSearchType,
    required this.searchQuery,
  });

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  final ScrollController _scrollController = ScrollController();
  late SearchBloc _bloc;
  int _currentPage = 1;
  bool _isLoadingMore = false;


  @override
  void initState() {
    super.initState();
    _bloc = SearchBloc(ApiService());
    _bloc.add(FetchHotelsEvent(
      searchQuery: widget.searchQuery,
      page: _currentPage,
      selectedSearchType: widget.selectedSearchType

    ));
    _scrollController.addListener(_onScroll);
  }

  ///code of pagination
  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent &&
        !_isLoadingMore) {
      _loadMore();
    }
  }

  ///code of pagination
  void _loadMore() {
    _isLoadingMore = true;
    _currentPage++;
    _bloc.add(LoadMoreHotelsEvent(
      page: _currentPage,
      selectedSearchType: widget.selectedSearchType
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Search Results",style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.teal,
          centerTitle: true,
          elevation: 1,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) {
            if (state is SearchLoading) {
              return ShimmerCard();
            } else if (state is SearchLoaded) {
              final hotels = state.hotels;
              if (hotels.isEmpty) {
                return const Center(child: Text("No Hotels Found 😕"));
              }
              return RefreshIndicator(
                onRefresh: () async {
                  _currentPage = 1;
                  _bloc.add(FetchHotelsEvent(
                    page: _currentPage,
                      searchQuery: widget.searchQuery,
                    selectedSearchType: widget.selectedSearchType
                  ));
                },
                child:GridView.builder(
                          padding: const EdgeInsets.all(10),
                          itemCount: hotels.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.75,
                          ),
                          itemBuilder: (context, index) {
                          final hotel = hotels[index];
                          return HotelCard(
                            hotel: hotel,
                          );
                          },
                          )
              );
            } else if (state is SearchError) {
              return Center(
                child: Text(
                  "Error: ${state.message}",
                  style: const TextStyle(color: Colors.red),
                ),
              );
            } else {
              return const Center(child: Text("No data available"));
            }
          },
        ),
      ),
    );
  }
}
