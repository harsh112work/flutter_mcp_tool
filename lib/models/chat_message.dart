class ChatMessage {
  final String text;
  final bool isUser;
  final String? id;
  final String? type;
  final String? role;
  final String? model;
  final String? stopReason;
  final String? stopSequence;
  final Map<String, dynamic>? usage;

  const ChatMessage({
    required this.text,
    required this.isUser,
    this.id,
    this.type,
    this.role,
    this.model,
    this.stopReason,
    this.stopSequence,
    this.usage,
  });

  factory ChatMessage.fromApiResponse(Map<String, dynamic> response) {
    // Extract text content from the content array
    String messageText = '';
    if (response['content'] != null && response['content'] is List) {
      for (var item in response['content']) {
        if ((item['type'] == 'text') && item['text'] != null) {
          messageText = item['text'];
          // break;
        }

        if ((item['type'] == 'mcp_tool_result') && item['content'] != null) {
          (item['content'] as List<dynamic>).forEach((e) {
            messageText = "$messageText \n\n ${e['text']}";
          });
        }
      }
    }

    return ChatMessage(
      text: messageText,
      isUser: false,
      id: response['id'],
      type: response['type'],
      role: response['role'],
      model: response['model'],
      stopReason: response['stop_reason'],
      stopSequence: response['stop_sequence'],
      usage: response['usage'],
    );
  }
}
