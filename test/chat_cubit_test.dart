import 'package:flutter_test/flutter_test.dart';
import 'package:mcp_tool_app/blocs/chat/chat_cubit.dart';
import 'package:mcp_tool_app/blocs/chat/chat_state.dart';
import 'package:mcp_tool_app/models/chat_message.dart';
import 'package:mcp_tool_app/repositories/chat_repository.dart';
import 'package:mockito/mockito.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late ChatCubit chatCubit;
  late MockChatRepository mockRepository;
  const String testComponentName = 'test-component';

  setUp(() {
    mockRepository = MockChatRepository();
    chatCubit = ChatCubit(mockRepository, componentName: testComponentName);
  });

  group('ChatCubit Tests', () {
    test('initial state is correct', () {
      expect(chatCubit.state, equals(ChatState.initial()));
    });

    test('sendMessage success flow', () async {
      // Mock repository response
      const mockResponse = ChatMessage(
        text: 'Test response',
        isUser: false,
      );

      when(mockRepository.sendMessage('test message', testComponentName))
          .thenAnswer((_) async => mockResponse);

      // Send message
      await chatCubit.sendMessage('test message');

      // Verify state changes
      expect(chatCubit.state.messages.length, equals(2));
      expect(chatCubit.state.messages[0].text, equals('test message'));
      expect(chatCubit.state.messages[0].isUser, isTrue);
      expect(chatCubit.state.messages[1].text, equals('Test response'));
      expect(chatCubit.state.messages[1].isUser, isFalse);
      expect(chatCubit.state.isLoading, isFalse);
      expect(chatCubit.state.error, isNull);
    });

    test('sendMessage error handling', () async {
      // Mock repository to throw error
      when(mockRepository.sendMessage('test message', testComponentName))
          .thenThrow(Exception('Test error'));

      // Send message
      await chatCubit.sendMessage('test message');

      // Verify state changes
      expect(chatCubit.state.messages.length, equals(1));
      expect(chatCubit.state.messages[0].text, equals('test message'));
      expect(chatCubit.state.messages[0].isUser, isTrue);
      expect(chatCubit.state.isLoading, isFalse);
      expect(chatCubit.state.error, isNotNull);
      expect(chatCubit.state.error, contains('Test error'));
    });

    test('sendMessage loading state', () async {
      // Mock repository with delay
      when(mockRepository.sendMessage('test message', testComponentName))
          .thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return const ChatMessage(text: 'Test response', isUser: false);
      });

      // Start sending message
      final future = chatCubit.sendMessage('test message');

      // Verify loading state
      expect(chatCubit.state.isLoading, isTrue);
      expect(chatCubit.state.messages.length, equals(1));
      expect(chatCubit.state.messages[0].text, equals('test message'));
      expect(chatCubit.state.messages[0].isUser, isTrue);

      // Wait for completion
      await future;

      // Verify final state
      expect(chatCubit.state.isLoading, isFalse);
      expect(chatCubit.state.messages.length, equals(2));
    });

    test('sendMessage preserves existing messages', () async {
      // Add some existing messages
      const existingMessage =
          ChatMessage(text: 'Existing message', isUser: true);
      chatCubit.emit(ChatState(
        messages: [existingMessage],
        isLoading: false,
        error: null,
      ));

      // Mock repository response
      const mockResponse = ChatMessage(
        text: 'Test response',
        isUser: false,
      );

      when(mockRepository.sendMessage('test message', testComponentName))
          .thenAnswer((_) async => mockResponse);

      // Send new message
      await chatCubit.sendMessage('test message');

      // Verify state changes
      expect(chatCubit.state.messages.length, equals(3));
      expect(chatCubit.state.messages[0].text, equals('Existing message'));
      expect(chatCubit.state.messages[1].text, equals('test message'));
      expect(chatCubit.state.messages[2].text, equals('Test response'));
    });
  });
}
