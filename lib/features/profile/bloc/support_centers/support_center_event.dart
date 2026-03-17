import 'package:equatable/equatable.dart';

abstract class SupportCenterEvent extends Equatable {
  const SupportCenterEvent();

  @override
  List<Object> get props => [];
}

class LoadFAQ extends SupportCenterEvent {}

class SubmitTicket extends SupportCenterEvent {
  final String subject;
  final String description;
  final String category;

  const SubmitTicket({
    required this.subject,
    required this.description,
    required this.category,
  });

  @override
  List<Object> get props => [subject, description, category];
}

class SearchFAQ extends SupportCenterEvent {
  final String query;

  const SearchFAQ(this.query);

  @override
  List<Object> get props => [query];
}