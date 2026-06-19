import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tapovana_mobile_app/features/chatbot/domain/models/message_model.dart';
import 'package:tapovana_mobile_app/features/chatbot/domain/repositories/chat_repository.dart';
import 'chatbot_state.dart';

class ChatbotCubit extends Cubit<ChatbotState> {
  final ChatRepository _chatRepository;

  ChatbotCubit(this._chatRepository) : super(
    ChatbotInitial(
      messages: [
        ChatMessage(
          id: 'welcome',
          text: "Namaste! I am Tapo, your personal wellness guide. How can I help you on your health and wellness journey today?",
          isUser: false,
          timestamp: DateTime.now(),
        )
      ],
    ),
  );

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final currentState = state;
    List<ChatMessage> currentMessages = [];
    if (currentState is ChatbotInitial) currentMessages = currentState.messages;
    else if (currentState is ChatbotLoading) currentMessages = currentState.messages;
    else if (currentState is ChatbotLoaded) currentMessages = currentState.messages;
    else if (currentState is ChatbotError) currentMessages = currentState.messages;

    final userMessage = ChatMessage(
      id: DateTime.now().toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    final updatedMessages = List<ChatMessage>.from(currentMessages)..add(userMessage);
    
    emit(ChatbotLoading(messages: updatedMessages));

    try {
      final responseText = await _chatRepository.sendMessage(text);
      
      final botMessage = ChatMessage(
        id: DateTime.now().toString(),
        text: responseText,
        isUser: false,
        timestamp: DateTime.now(),
      );

      final finalMessages = List<ChatMessage>.from(updatedMessages)..add(botMessage);
      
      emit(ChatbotLoaded(messages: finalMessages));
    } catch (e) {
      emit(ChatbotError(error: e.toString(), messages: updatedMessages));
    }
  }
}
