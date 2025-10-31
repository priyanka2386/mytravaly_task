import 'package:equatable/equatable.dart';
import '../../../models/hotel_model.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<HotelModel> hotels;
  final bool hasMore;

  const SearchLoaded({required this.hotels, this.hasMore = true});

  SearchLoaded copyWith({
    List<HotelModel>? hotels,
    bool? hasMore,
  }) {
    return SearchLoaded(
      hotels: hotels ?? this.hotels,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object?> get props => [hotels, hasMore];
}

class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);

  @override
  List<Object?> get props => [message];
}
