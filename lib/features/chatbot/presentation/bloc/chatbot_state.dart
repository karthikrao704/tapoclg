import 'package:equatable/equatable.dart';
import 'package:tapovana_mobile_app/features/chatbot/domain/models/message_model.dart';

abstract class ChatbotState extends Equatable {
  const ChatbotState();

  @override
  List<Object> get props => [];
}

class ChatbotInitial extends ChatbotState {
  final List<ChatMessage> messages;

  const ChatbotInitial({required this.messages});

  @override
  List<Object> get props => [messages];
}

class ChatbotLoading extends ChatbotState {
  final List<ChatMessage> messages;

  const ChatbotLoading({required this.messages});

  @override
  List<Object> get props => [messages];
}

class ChatbotLoaded extends ChatbotState {
  final List<ChatMessage> messages;

  const ChatbotLoaded({required this.messages});

  @override
  List<Object> get props => [messages];
}

class ChatbotError extends ChatbotState {
  final String error;
  final List<ChatMessage> messages;

  const ChatbotError({required this.error, required this.messages});

  @override
  List<Object> get props => [error, messages];
}
