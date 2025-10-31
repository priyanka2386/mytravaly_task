import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mytravaly_task/pages/search_page.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/hotel_model.dart';
import '../../services/api_service.dart';
import '../bloc/search/search_bloc.dart';
import '../bloc/search/search_event.dart';
import '../bloc/search/search_state.dart';
import '../helper/location_helper.dart';
import '../widgets/hotel_widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = TextEditingController();
  String selectedSearchType = 'hotelIdSearch';

  /// used for creating search query
  List<String> buildSearchQuery(String query, String searchType) {
    final lower = query.toLowerCase();

    if (searchType == 'citySearch' && locationMap.containsKey(lower)) {
      final state = locationMap[lower]!['state'] ?? '';
      final country = locationMap[lower]!['country'] ?? 'India';
      return [query, state, country];
    }

    if (searchType == 'stateSearch' && locationMap.containsKey(lower)) {
      final country = locationMap[lower]!['country'] ?? 'India';
      return [query, country];
    }

    if (searchType == 'countrySearch') {
      return [query];
    }

    // fallback
    return [query];
  }


  ///method trigger when user clicks on right arrow of search bar button
  void _onSearch() {
    final query = _controller.text.trim();
    if (query.isNotEmpty) {
      final searchQuery = buildSearchQuery(query, selectedSearchType);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SearchResultsPage(
            selectedSearchType: selectedSearchType,
            searchQuery: searchQuery,
          ),
        ),
      );
    }else{

    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SearchBloc(ApiService())
        ..add(FetchHotelsEvent(
          searchQuery: ["qyhZqzVt"], //default search by hotelbyID
          selectedSearchType: selectedSearchType // default set id to hotelbyID
        )),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Text("Home Page",style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.teal,
          centerTitle: true,
          elevation: 1,
        ),
        body: Column(
          children: [
            // 🔍 Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _onSearch(),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Search hotels",
                          hintStyle: const TextStyle(color: Colors.grey),
                          prefixIcon: const Icon(Icons.search, color: Colors.teal),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 0),
                        ),
                      ),
                    ),
                    // Divider line
                    Container(
                      height: 30,
                      width: 1,
                      color: Colors.grey.shade400,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    /// 🌍 Dropdown (aligned vertically)
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedSearchType,
                        icon: const Icon(Icons.arrow_drop_down_rounded, color: Colors.teal),
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: "hotelIdSearch",
                            child: Text("Hotel"),
                          ),
                          DropdownMenuItem(
                            value: "citySearch",
                            child: Text("City"),
                          ),
                          DropdownMenuItem(
                            value: "stateSearch",
                            child: Text("State"),
                          ),
                          DropdownMenuItem(
                            value: "countrySearch",
                            child: Text("Country"),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => selectedSearchType = value!);
                        },
                      ),
                    ),
                    // 📤 Send button
                    IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.teal),
                      onPressed: _onSearch,
                    ),
                  ],
                ),
              ),
            ),
            /// 🏨 Hotel results section
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  if (state is SearchLoading) {
                    // 🔹 Shimmer grid while loading
                    return GridView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: 6,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.70,
                      ),
                      itemBuilder: (_, __) => ShimmerCard(),
                    );
                  } else if (state is SearchLoaded) {
                    final hotels = state.hotels;
                    if (hotels.isEmpty) {
                      return const Center(child: Text("No Hotels Found 😕"));
                    }
                    return GridView.builder(
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
          ],
        ),
      ),
    );
  }

}
