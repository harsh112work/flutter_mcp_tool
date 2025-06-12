// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageRequest _$MessageRequestFromJson(Map<String, dynamic> json) =>
    MessageRequest(
      model: json['model'] as String,
      maxTokens: (json['maxTokens'] as num).toInt(),
      messages: (json['messages'] as List<dynamic>)
          .map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList(),
      mcpServers: (json['mcpServers'] as List<dynamic>)
          .map((e) => McpServer.fromJson(e as Map<String, dynamic>))
          .toList(),
      timeout: (json['timeout'] as num).toInt(),
    );

Map<String, dynamic> _$MessageRequestToJson(MessageRequest instance) =>
    <String, dynamic>{
      'model': instance.model,
      'maxTokens': instance.maxTokens,
      'messages': instance.messages,
      'mcpServers': instance.mcpServers,
      'timeout': instance.timeout,
    };

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
      role: json['role'] as String,
      content: json['content'] as String,
    );

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'role': instance.role,
      'content': instance.content,
    };

McpServer _$McpServerFromJson(Map<String, dynamic> json) => McpServer(
      type: json['type'] as String,
      url: json['url'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$McpServerToJson(McpServer instance) => <String, dynamic>{
      'type': instance.type,
      'url': instance.url,
      'name': instance.name,
    };
