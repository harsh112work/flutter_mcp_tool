import 'package:equatable/equatable.dart';

import '../../screens/content_generator_screen.dart';
import '../../models/chat_message.dart';

class ChatMessageModel {
  final String text;
  final bool isUser;

  ChatMessageModel({
    required this.text,
    required this.isUser,
  });
}

class ChatState extends Equatable {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  const ChatState({
    required this.messages,
    required this.isLoading,
    this.error,
  });

  factory ChatState.initial() => const ChatState(
        messages: [],
        isLoading: false,
        error: null,
      );

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [messages, isLoading, error];
} 