class ChatResponse {
  final String id;
  final String type;
  final String role;
  final String model;
  final List<ContentItem> content;
  final String stopReason;
  final String? stopSequence;
  final Usage usage;

  ChatResponse({
    required this.id,
    required this.type,
    required this.role,
    required this.model,
    required this.content,
    required this.stopReason,
    this.stopSequence,
    required this.usage,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      id: json['id'] as String,
      type: json['type'] as String,
      role: json['role'] as String,
      model: json['model'] as String,
      content: (json['content'] as List)
          .map((item) => ContentItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      stopReason: json['stop_reason'] as String,
      stopSequence: json['stop_sequence'] as String?,
      usage: Usage.fromJson(json['usage'] as Map<String, dynamic>),
    );
  }
}

class ContentItem {
  final String type;
  final String? text;
  final String? id;
  final String? name;
  final Map<String, dynamic>? input;
  final String? serverName;
  final String? toolUseId;
  final bool? isError;
  final List<ContentItem>? content;

  ContentItem({
    required this.type,
    this.text,
    this.id,
    this.name,
    this.input,
    this.serverName,
    this.toolUseId,
    this.isError,
    this.content,
  });

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    return ContentItem(
      type: json['type'] as String,
      text: json['text'] as String?,
      id: json['id'] as String?,
      name: json['name'] as String?,
      input: json['input'] as Map<String, dynamic>?,
      serverName: json['server_name'] as String?,
      toolUseId: json['tool_use_id'] as String?,
      isError: json['is_error'] as bool?,
      content: json['content'] != null
          ? (json['content'] as List)
              .map((item) => ContentItem.fromJson(item as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}

class Usage {
  final int inputTokens;
  final int cacheCreationInputTokens;
  final int cacheReadInputTokens;
  final int outputTokens;
  final String serviceTier;
  final ServerToolUse serverToolUse;

  Usage({
    required this.inputTokens,
    required this.cacheCreationInputTokens,
    required this.cacheReadInputTokens,
    required this.outputTokens,
    required this.serviceTier,
    required this.serverToolUse,
  });

  factory Usage.fromJson(Map<String, dynamic> json) {
    return Usage(
      inputTokens: json['input_tokens'] as int,
      cacheCreationInputTokens: json['cache_creation_input_tokens'] as int,
      cacheReadInputTokens: json['cache_read_input_tokens'] as int,
      outputTokens: json['output_tokens'] as int,
      serviceTier: json['service_tier'] as String,
      serverToolUse: ServerToolUse.fromJson(
          json['server_tool_use'] as Map<String, dynamic>),
    );
  }
}

class ServerToolUse {
  final int webSearchRequests;

  ServerToolUse({
    required this.webSearchRequests,
  });

  factory ServerToolUse.fromJson(Map<String, dynamic> json) {
    return ServerToolUse(
      webSearchRequests: json['web_search_requests'] as int,
    );
  }
}
