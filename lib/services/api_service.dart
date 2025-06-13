import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/message_request.dart';

class ApiService {
  late final Dio _dio;
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

    // Add logging interceptor for debugging
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  // Add setter for testing
  @visibleForTesting
  set dio(Dio value) => _dio = value;

  Future<Response> sendMessage(MessageRequest request) async {
    try {
      final response = await _dio.post(
        '/messages',
        data: request.toJson(),
      );
      return response;
    } on DioException catch (e) {
      debugPrint('DioException details:');
      debugPrint('Type: ${e.type}');
      debugPrint('Message: ${e.message}');
      debugPrint('Response: ${e.response?.data}');
      debugPrint('Status code: ${e.response?.statusCode}');
      throw Exception(
          'Failed to send message: ${e.message}\nResponse: ${e.response?.data}');
    } catch (e) {
      debugPrint('Unexpected error: $e');
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

      debugPrint("response ${response.data}");
      return response.data;
    } on DioException catch (e) {
      debugPrint('DioException details:');
      debugPrint('Type: ${e.type}');
      debugPrint('Message: ${e.message}');
      debugPrint('Response: ${e.response?.data}');
      debugPrint('Status code: ${e.response?.statusCode}');
      throw Exception(
          'Failed to send message: ${e.message}\nResponse: ${e.response?.data}');
    } catch (e) {
      debugPrint('Unexpected error: $e');
      throw Exception('Failed to send message: $e');
    }
  }

  Future<Map<String, dynamic>> fetchMessages(String componentName) async {
    debugPrint('Fetching messages for component: $componentName');
    try {
      final response = await _dio.post(
        '/messages',
        data: {
          "model": "claude-sonnet-4-20250514",
          "max_tokens": 1000,
          "messages": [
            {
              "role": "user",
              "content": "List my 5 most recent $componentName chats"
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
      debugPrint('Response received: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      debugPrint('DioException details:');
      debugPrint('Type: ${e.type}');
      debugPrint('Message: ${e.message}');
      debugPrint('Response: ${e.response?.data}');
      debugPrint('Status code: ${e.response?.statusCode}');
      throw Exception(
          'Failed to fetch messages: ${e.message}\nResponse: ${e.response?.data}');
    } catch (e) {
      debugPrint('Unexpected error: $e');
      throw Exception('Failed to fetch messages: $e');
    }
  }
}
