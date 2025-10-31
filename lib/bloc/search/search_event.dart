import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class FetchHotelsEvent extends SearchEvent {
  final int page;
  final String? selectedSearchType;
  final List<String>? searchQuery;

  const FetchHotelsEvent({
    this.page = 1,
    this.selectedSearchType,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [page,selectedSearchType,searchQuery];
}

class LoadMoreHotelsEvent extends SearchEvent {
  final int page;
  final String selectedSearchType;
  final List<String>? searchQuery;

  const LoadMoreHotelsEvent({
    required this.page,
    required this.selectedSearchType,
    this.searchQuery
  });

  @override
  List<Object?> get props => [ page,selectedSearchType,searchQuery];
}
