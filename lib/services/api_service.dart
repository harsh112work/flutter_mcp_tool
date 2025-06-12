import 'package:dio/dio.dart';

import '../models/message_request.dart';

class ApiService {
  final Dio _dio;
  final String _baseUrl = 'https://api.anthropic.com/v1';
  final String _apiKey;

  ApiService(this._apiKey) : _dio = Dio() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'X-API-Key': _apiKey,
      'anthropic-version': '2023-06-01',
      'anthropic-beta': 'mcp-client-2025-04-04',
    };
  }

  Future<Response> sendMessage(MessageRequest request) async {
    try {
      final response = await _dio.post(
        '/messages',
        data: request.toJson(),
      );
      return response;
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  Future<Map<String, dynamic>> sendMessageToComponent(
      String message, String componentName) async {
    try {
      final response = await _dio.post(
        '/messages',
        data: {
          'model': 'claude-sonnet-4-20250514',
          'max_tokens': 1000,
          'messages': [
            {'role': 'user', 'content': message}
          ],
          'mcp_servers': [
            {
              'type': 'url',
              'url': 'https://093f-3-82-96-80.ngrok-free.app/sse',
              'name': componentName.toLowerCase(),
            }
          ]
        },

      );

      print("response ${response.data}");
      return response.data;
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  Future<Map<String, dynamic>> fetchMessages(String componentName) async {
    print('Fetching messages for component: $componentName');
    try {
      final response = await _dio.post(
        '/messages',
        data: {
          "model": "claude-sonnet-4-20250514",
          "max_tokens": 1000,
          "messages": [
            {
              "role": "user",
              "content": "List my 5 most recent ${componentName} chats"
            }
          ],
          "mcp_servers": [
            {
              "type": "url",
              "url": "https://093f-3-82-96-80.ngrok-free.app/sse",
              "name": componentName.toLowerCase()
            }
          ]
        },
      );
      print('Response received: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      print('Error fetching messages: ${e.message}');
      if (e.response != null) {
        print('Response data: ${e.response?.data}');
        print('Response status: ${e.response?.statusCode}');
        print('Response headers: ${e.response?.headers}');
      }
      throw Exception('Failed to fetch messages: ${e.message}');
    } catch (e) {
      print('Unexpected error: $e');
      throw Exception('Failed to fetch messages: $e');
    }
  }
}
