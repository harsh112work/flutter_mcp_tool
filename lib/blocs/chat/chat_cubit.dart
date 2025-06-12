import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/chat_message.dart';
import '../../repositories/chat_repository.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _repository;
  final String componentName;

  ChatCubit(this._repository, {required this.componentName})
      : super(ChatState.initial()) {
    // fetchMessages();
  }

  /*Future<void> fetchMessages() async {
    try {
      emit(state.copyWith(isLoading: true));
      final messages = await _repository.fetchMessages(componentName);
      emit(state.copyWith(
        messages: messages,
        isLoading: false,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }*/

  Future<void> sendMessage(String text) async {
    try {
      // Add user message immediately
      final userMessage = ChatMessage(text: text, isUser: true);
      emit(state.copyWith(
        messages: [...state.messages, userMessage],
        isLoading: true,
      ));

      // Send message and get response
      final response = await _repository.sendMessage(text, componentName);

      // Add response message
      emit(state.copyWith(
        messages: [...state.messages, response],
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }
}
