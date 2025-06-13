import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../blocs/chat/chat_cubit.dart';
import '../blocs/chat/chat_state.dart';
import '../models/chat_message.dart';
import '../repositories/chat_repository.dart';
import '../services/api_service.dart';

class ContentGeneratorScreen extends StatelessWidget {
  final String componentName;

  const ContentGeneratorScreen({
    super.key,
    required this.componentName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatCubit(
        ChatRepository(
          ApiService(dotenv.env['ANTHOPIC_AUTH_KEY'] ?? ""),
        ),
        componentName: componentName,
      ),
      child: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state) {
          return _ContentGeneratorView(
            componentName: componentName,
            state: state,
          );
        },
      ),
    );
  }
}

class _ContentGeneratorView extends StatefulWidget {
  final String componentName;
  final ChatState state;

  const _ContentGeneratorView({
    required this.componentName,
    required this.state,
  });

  @override
  State<_ContentGeneratorView> createState() => _ContentGeneratorViewState();
}

class _ContentGeneratorViewState extends State<_ContentGeneratorView> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _text = '';
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    await _speech.initialize(
      onStatus: (status) => debugPrint('Speech status: $status'),
      onError: (error) => debugPrint('Speech error: $error'),
    );
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          listenFor: const Duration(seconds: 30),
          listenOptions:
              stt.SpeechListenOptions(listenMode: stt.ListenMode.dictation),
          onResult: (result) {
            setState(() {
              _text = result.recognizedWords;
              _textController.text = _text;
              if (_text.trim().isNotEmpty) {
                context.read<ChatCubit>().sendMessage(_text);
                _textController.clear();
                _text = '';
              }
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade900,
              Colors.purple.shade900,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon:
                          const Icon(Icons.arrow_back_ios, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.componentName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    children: [
                      ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        reverse: true,
                        itemCount: widget.state.messages.length,
                        itemBuilder: (context, index) {
                          final message = widget.state.messages[
                              widget.state.messages.length - 1 - index];
                          return _buildMessage(message, context);
                        },
                      ),
                      if (widget.state.isLoading)
                        Positioned(
                          bottom: 16,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Loading...',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (widget.state.error != null)
                Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 8.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Text(
                    widget.state.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              Container(
                margin: const EdgeInsets.only(top: 24),
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                ),
                child: _buildTextComposer(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessage(ChatMessage message, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: message.isUser
                    ? Colors.blue.withOpacity(0.8)
                    : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(
                  color: message.isUser
                      ? Colors.blue.withOpacity(0.3)
                      : Colors.white.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: message.isUser
                        ? Colors.blue.withOpacity(0.2)
                        : Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser
                      ? Colors.white
                      : Colors.white.withOpacity(0.9),
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: (text) {
                if (text.trim().isNotEmpty) {
                  context.read<ChatCubit>().sendMessage(text);
                  _textController.clear();
                  _text = '';
                }
              },
              enabled: !widget.state.isLoading,
            ),
          ),
          IconButton(
            icon: Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              color: _isListening ? Colors.red : Colors.white,
            ),
            onPressed: _startListening,
          ),
          IconButton(
            icon: Icon(
              Icons.send,
              color: widget.state.isLoading
                  ? Colors.white.withOpacity(0.5)
                  : Colors.white,
            ),
            onPressed: widget.state.isLoading
                ? null
                : () {
                    final text = _textController.text;
                    if (text.trim().isNotEmpty) {
                      context.read<ChatCubit>().sendMessage(text);
                      _textController.clear();
                      _text = '';
                    }
                  },
          ),
        ],
      ),
    );
  }
}
