import 'package:flutter_bloc/flutter_bloc.dart';
import 'support_center_event.dart';
import 'support_center_state.dart';

class SupportCenterBloc extends Bloc<SupportCenterEvent, SupportCenterState> {
  SupportCenterBloc() : super(const SupportCenterState()) {
    on<LoadFAQ>(_onLoadFAQ);
    on<SubmitTicket>(_onSubmitTicket);
    on<SearchFAQ>(_onSearchFAQ);
  }

  Future<void> _onLoadFAQ(LoadFAQ event, Emitter<SupportCenterState> emit) async {
    emit(state.copyWith(isLoading: true));
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      final faqs = [
        const FAQItem(
          question: 'How do I reset my password?',
          answer: 'You can reset your password by going to Settings > Privacy & Security > Change Password.',
          category: 'Account',
        ),
        const FAQItem(
          question: 'How do I enable two-factor authentication?',
          answer: 'Go to Settings > Privacy & Security and toggle on Two-Factor Authentication.',
          category: 'Security',
        ),
        const FAQItem(
          question: 'How do I update my profile information?',
          answer: 'Navigate to the Profile page and tap the edit button to update your information.',
          category: 'Profile',
        ),
        const FAQItem(
          question: 'How do I manage notification preferences?',
          answer: 'Go to Settings > Notification Settings to customize your notification preferences.',
          category: 'Notifications',
        ),
      ];
      
      emit(state.copyWith(
        faqs: faqs,
        filteredFAQs: faqs,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: 'Failed to load FAQ: ${e.toString()}',
        isLoading: false,
      ));
    }
  }

  Future<void> _onSubmitTicket(SubmitTicket event, Emitter<SupportCenterState> emit) async {
    emit(state.copyWith(isLoading: true, ticketSubmitted: false));
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      emit(state.copyWith(
        isLoading: false,
        ticketSubmitted: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: 'Failed to submit ticket: ${e.toString()}',
        isLoading: false,
        ticketSubmitted: false,
      ));
    }
  }

  Future<void> _onSearchFAQ(SearchFAQ event, Emitter<SupportCenterState> emit) async {
    if (event.query.isEmpty) {
      emit(state.copyWith(filteredFAQs: state.faqs));
      return;
    }

    final filtered = state.faqs.where((faq) {
      return faq.question.toLowerCase().contains(event.query.toLowerCase()) ||
          faq.answer.toLowerCase().contains(event.query.toLowerCase()) ||
          faq.category.toLowerCase().contains(event.query.toLowerCase());
    }).toList();

    emit(state.copyWith(filteredFAQs: filtered));
  }
}