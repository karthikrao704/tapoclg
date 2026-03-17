import 'package:equatable/equatable.dart';

class FAQItem {
  final String question;
  final String answer;
  final String category;

  const FAQItem({
    required this.question,
    required this.answer,
    required this.category,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FAQItem &&
          runtimeType == other.runtimeType &&
          question == other.question &&
          answer == other.answer &&
          category == other.category;

  @override
  int get hashCode => question.hashCode ^ answer.hashCode ^ category.hashCode;
}

class SupportCenterState extends Equatable {
  final List<FAQItem> faqs;
  final List<FAQItem> filteredFAQs;
  final bool isLoading;
  final String? error;
  final bool ticketSubmitted;

  const SupportCenterState({
    this.faqs = const [],
    this.filteredFAQs = const [],
    this.isLoading = false,
    this.error,
    this.ticketSubmitted = false,
  });

  SupportCenterState copyWith({
    List<FAQItem>? faqs,
    List<FAQItem>? filteredFAQs,
    bool? isLoading,
    String? error,
    bool? ticketSubmitted,
  }) {
    return SupportCenterState(
      faqs: faqs ?? this.faqs,
      filteredFAQs: filteredFAQs ?? this.filteredFAQs,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      ticketSubmitted: ticketSubmitted ?? this.ticketSubmitted,
    );
  }

  @override
  List<Object?> get props => [faqs, filteredFAQs, isLoading, error, ticketSubmitted];
}