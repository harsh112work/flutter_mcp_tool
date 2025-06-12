import '../models/chat_message.dart';
import '../models/chat_response.dart';
import '../services/api_service.dart';

class ChatRepository {
  final ApiService _apiService;

  ChatRepository(this._apiService);

  Future<ChatMessage> sendMessage(String message, String componentName) async {
    try {
      final response =
          await _apiService.sendMessageToComponent(message, componentName);
      return ChatMessage.fromApiResponse(response);
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  Future<List<ChatMessage>> fetchMessages(String componentName) async {
    try {
      final response = await _apiService.fetchMessages(componentName);
      final chatResponse = ChatResponse.fromJson(response);

      // Extract all text content from the response
      final List<ChatMessage> messages = [];

      // Add the initial assistant message
      messages.add(ChatMessage(
        text: "Here are your recent ${componentName} chats:",
        isUser: false,
      ));

      // Process each content item
      for (var item in chatResponse.content) {
        if (item.type == 'text' && item.text != null) {
          messages.add(ChatMessage(
            text: item.text!,
            isUser: false,
          ));
        } else if (item.type == 'mcp_tool_result' && item.content != null) {
          // Process tool results
          for (var toolContent in item.content!) {
            if (toolContent.type == 'text' && toolContent.text != null) {
              try {
                // Try to parse the JSON text
                final Map<String, dynamic> chatData = Map<String, dynamic>.from(
                    toolContent.text!.startsWith('{')
                        ? Map<String, dynamic>.from(toolContent.text as Map)
                        : {'text': toolContent.text});

                // Format the chat message
                final String formattedMessage = _formatChatMessage(chatData);
                messages.add(ChatMessage(
                  text: formattedMessage,
                  isUser: false,
                ));
              } catch (e) {
                // If parsing fails, use the raw text
                messages.add(ChatMessage(
                  text: toolContent.text!,
                  isUser: false,
                ));
              }
            }
          }
        }
      }

      return messages;
    } catch (e) {
      throw Exception('Failed to fetch messages: $e');
    }
  }

  String _formatChatMessage(Map<String, dynamic> chatData) {
    final String name = chatData['name'] ?? 'Unknown';
    final String lastMessage = chatData['last_message'] ?? 'No message';
    final String lastMessageTime = chatData['last_message_time'] ?? '';
    final String lastSender = chatData['last_sender'] ?? '';
    final bool isFromMe = chatData['last_is_from_me'] == 1;

    return '''
Chat: $name
Last Message: $lastMessage
Time: $lastMessageTime
From: ${isFromMe ? 'You' : lastSender}
''';
  }
}
