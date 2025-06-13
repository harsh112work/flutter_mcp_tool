import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:mcp_tool_app/services/api_service.dart';
import 'package:mcp_tool_app/models/message_request.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  late ApiService apiService;
  const String testApiKey = 'test_api_key';

  setUp(() {
    apiService = ApiService(testApiKey);
  });

  group('ApiService Tests', () {
    test('ApiService initialization with API key', () {
      expect(apiService, isNotNull);
    });

    test('sendMessage with valid request', () async {
      // Create a test message request
      final request = MessageRequest(
        model: 'claude-sonnet-4-20250514',
        maxTokens: 1000,
        messages: [
          Message(role: 'user', content: 'Test message'),
        ],
        mcpServers: [
          McpServer(
            type: 'url',
            url: 'https://test-url.com',
            name: 'test-component',
          ),
        ],
        timeout: 30,
      );

      // Mock the Dio response
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

      // Create a mock Dio instance
      final mockDio = MockDio();
      when(() => mockDio.post(
            '/messages',
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
            data: mockResponse,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/messages'),
          ));

      // Replace the real Dio instance with our mock
      apiService = ApiService(testApiKey);
      apiService._dio = mockDio;

      // Test the sendMessage method
      final response = await apiService.sendMessage(request);
      expect(response.data, equals(mockResponse));
    });

    test('sendMessageToComponent with valid parameters', () async {
      const message = 'Test message';
      const componentName = 'test-component';

      // Mock response
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

      // Create a mock Dio instance
      final mockDio = MockDio();
      when(() => mockDio.post(
            '/messages',
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
            data: mockResponse,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/messages'),
          ));

      // Replace the real Dio instance with our mock
      apiService = ApiService(testApiKey);
      apiService._dio = mockDio;

      // Test the sendMessageToComponent method
      final response = await apiService.sendMessageToComponent(message, componentName);
      expect(response, equals(mockResponse));
    });

    test('fetchMessages with valid component name', () async {
      const componentName = 'test-component';

      // Mock response
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

      // Create a mock Dio instance
      final mockDio = MockDio();
      when(() => mockDio.post(
            '/messages',
            data: any(named: 'data'),
          )).thenAnswer((_) async => Response(
            data: mockResponse,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/messages'),
          ));

      // Replace the real Dio instance with our mock
      apiService = ApiService(testApiKey);
      apiService._dio = mockDio;

      // Test the fetchMessages method
      final response = await apiService.fetchMessages(componentName);
      expect(response, equals(mockResponse));
    });

    test('sendMessage handles DioException', () async {
      // Create a test message request
      final request = MessageRequest(
        model: 'claude-sonnet-4-20250514',
        maxTokens: 1000,
        messages: [
          Message(role: 'user', content: 'Test message'),
        ],
        mcpServers: [
          McpServer(
            type: 'url',
            url: 'https://test-url.com',
            name: 'test-component',
          ),
        ],
        timeout: 30,
      );

      // Create a mock Dio instance that throws an error
      final mockDio = MockDio();
      when(() => mockDio.post(
            '/messages',
            data: any(named: 'data'),
          )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/messages'),
        error: 'Test error',
      ));

      // Replace the real Dio instance with our mock
      apiService = ApiService(testApiKey);
      apiService._dio = mockDio;

      // Test that the error is properly handled
      expect(
        () => apiService.sendMessage(request),
        throwsException,
      );
    });

    test('sendMessageToComponent handles DioException', () async {
      // Create a mock Dio instance that throws an error
      final mockDio = MockDio();
      when(() => mockDio.post(
            '/messages',
            data: any(named: 'data'),
          )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/messages'),
        error: 'Test error',
      ));

      // Replace the real Dio instance with our mock
      apiService = ApiService(testApiKey);
      apiService._dio = mockDio;

      // Test that the error is properly handled
      expect(
        () => apiService.sendMessageToComponent('test', 'test-component'),
        throwsException,
      );
    });

    test('fetchMessages handles DioException', () async {
      // Create a mock Dio instance that throws an error
      final mockDio = MockDio();
      when(() => mockDio.post(
            '/messages',
            data: any(named: 'data'),
          )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/messages'),
        error: 'Test error',
      ));

      // Replace the real Dio instance with our mock
      apiService = ApiService(testApiKey);
      apiService._dio = mockDio;

      // Test that the error is properly handled
      expect(
        () => apiService.fetchMessages('test-component'),
        throwsException,
      );
    });
  });
}

// Mock class for Dio
class MockDio extends Mock implements Dio {} 