import 'package:json_annotation/json_annotation.dart';

part 'message_request.g.dart';

@JsonSerializable()
class MessageRequest {
  final String model;
  final int maxTokens;
  final List<Message> messages;
  final List<McpServer> mcpServers;
  final int timeout;

  MessageRequest({
    required this.model,
    required this.maxTokens,
    required this.messages,
    required this.mcpServers,
    required this.timeout,
  });

  factory MessageRequest.fromJson(Map<String, dynamic> json) =>
      _$MessageRequestFromJson(json);

  Map<String, dynamic> toJson() => _$MessageRequestToJson(this);
}

@JsonSerializable()
class Message {
  final String role;
  final String content;

  Message({
    required this.role,
    required this.content,
  });

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);
}

@JsonSerializable()
class McpServer {
  final String type;
  final String url;
  final String name;

  McpServer({
    required this.type,
    required this.url,
    required this.name,
  });

  factory McpServer.fromJson(Map<String, dynamic> json) =>
      _$McpServerFromJson(json);

  Map<String, dynamic> toJson() => _$McpServerToJson(this);
} 