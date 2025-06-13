import 'package:flutter_test/flutter_test.dart';
import 'package:mcp_tool_app/models/chat_message.dart';
import 'package:mcp_tool_app/repositories/chat_repository.dart';
import 'package:mcp_tool_app/services/api_service.dart';
import 'package:mockito/mockito.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late ChatRepository chatRepository;
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
    chatRepository = ChatRepository(mockApiService);
  });

  group('ChatRepository Tests', () {
    test('sendMessage success', () async {
      // Mock API response
      final mockResponse = {
        'id': 'test-id',
        'type': 'message',
        'role': 'assistant',
        'content': [
          {
            'type': 'text',
            'text': 'Test response',
          }
        ],
      };

      // Setup mock behavior
      when(mockApiService.sendMessageToComponent(
              'test message', 'test-component'))
          .thenAnswer((_) async => mockResponse);

      // Test the method
      final result =
          await chatRepository.sendMessage('test message', 'test-component');

      // Verify the result
      expect(result, isA<ChatMessage>());
      expect(result.text, contains('Test response'));
      expect(result.isUser, false);
    });

    test('sendMessage handles error', () async {
      // Setup mock to throw an error
      when(mockApiService.sendMessageToComponent(
              'test message', 'test-component'))
          .thenThrow(Exception('Test error'));

      // Test that the error is properly propagated
      expect(
        () => chatRepository.sendMessage('test message', 'test-component'),
        throwsException,
      );
    });

    test('fetchMessages success', () async {
      // Mock API response
      final mockResponse = {
        'id': 'test-id',
        'type': 'message',
        'role': 'assistant',
        'content': [
          {
            'type': 'text',
            'text': 'Test response',
          }
        ],
      };

      // Setup mock behavior
      when(mockApiService.fetchMessages('test-component'))
          .thenAnswer((_) async => mockResponse);

      // Test the method
      final result = await chatRepository.fetchMessages('test-component');

      // Verify the result
      expect(result, isA<List<ChatMessage>>());
      expect(result.length, greaterThan(0));
      expect(result.first.text, contains('Test response'));
      expect(result.first.isUser, false);
    });

    test('fetchMessages handles error', () async {
      // Setup mock to throw an error
      when(mockApiService.fetchMessages('test-component'))
          .thenThrow(Exception('Test error'));

      // Test that the error is properly propagated
      expect(
        () => chatRepository.fetchMessages('test-component'),
        throwsException,
      );
    });

    test('fetchMessages formats chat messages correctly', () async {
      // Mock API response with tool results
      final mockResponse = {
        'id': 'test-id',
        'type': 'message',
        'role': 'assistant',
        'content': [
          {
            'type': 'text',
            'text': 'Here are your recent chats:',
          },
          {
            'type': 'mcp_tool_result',
            'content': [
              {
                'type': 'text',
                'text':
                    '{"name": "Test Chat", "last_message": "Hello", "last_message_time": "2024-03-20", "last_sender": "User", "last_is_from_me": 0}',
              }
            ],
          }
        ],
      };

      // Setup mock behavior
      when(mockApiService.fetchMessages('test-component'))
          .thenAnswer((_) async => mockResponse);

      // Test the method
      final result = await chatRepository.fetchMessages('test-component');

      // Verify the result
      expect(result, isA<List<ChatMessage>>());
      expect(result.length, greaterThan(1));
      expect(result[1].text, contains('Test Chat'));
      expect(result[1].text, contains('Hello'));
      expect(result[1].text, contains('2024-03-20'));
      expect(result[1].text, contains('User'));
    });
  });
}
