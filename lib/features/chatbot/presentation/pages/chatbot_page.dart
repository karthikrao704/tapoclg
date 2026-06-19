import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:tapovana_mobile_app/core/theme/app_colors.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';
import 'package:tapovana_mobile_app/features/chatbot/domain/models/message_model.dart';
import 'package:tapovana_mobile_app/features/chatbot/domain/repositories/chat_repository.dart';
import 'package:tapovana_mobile_app/features/chatbot/presentation/bloc/chatbot_cubit.dart';
import 'package:tapovana_mobile_app/features/chatbot/presentation/bloc/chatbot_state.dart';
import 'package:tapovana_mobile_app/features/chatbot/presentation/components/chat_bubble.dart';

class ChatbotPage extends StatelessWidget {
  const ChatbotPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatbotCubit(ChatRepository()),
      child: const _ChatbotPageView(),
    );
  }
}

class _ChatbotPageView extends StatefulWidget {
  const _ChatbotPageView();

  @override
  State<_ChatbotPageView> createState() => _ChatbotPageViewState();
}

class _ChatbotPageViewState extends State<_ChatbotPageView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  bool _speechEnabled = false;

  final List<String> _suggestions = [
    "Recommend a Vedic program",
    "What is Deep Tissue Revive?",
    "Tips for stress relief",
    "How do I book an appointment?",
  ];

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    try {
      _speechEnabled = await _speechToText.initialize();
      setState(() {});
    } catch (e) {
      print("Speech initialization failed: $e");
    }
  }

  void _startListening() async {
    if (!_speechEnabled) {
      _speechEnabled = await _speechToText.initialize();
      if (!_speechEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Microphone permission denied or not available.")),
          );
        }
        return;
      }
    }
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {
      _isListening = true;
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      // Append or replace? It's better to replace while listening to reflect the full sentence recognized.
      _controller.text = result.recognizedWords;
      // move cursor to end
      _controller.selection = TextSelection.fromPosition(TextPosition(offset: _controller.text.length));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSend(String text) {
    if (text.trim().isEmpty) return;
    context.read<ChatbotCubit>().sendMessage(text);
    _controller.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFC9A14A).withAlpha(30),
              child: const Icon(
                Icons.spa,
                size: 20,
                color: Color(0xFFC9A14A),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Ask Tapo",
                  style: AppFonts.headland(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Online",
                      style: AppFonts.poppinsRegular(
                        fontSize: 11,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: BlocConsumer<ChatbotCubit, ChatbotState>(
        listener: (context, state) {
          if (state is ChatbotLoaded || state is ChatbotLoading) {
            _scrollToBottom();
          }
          if (state is ChatbotError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        builder: (context, state) {
          List<ChatMessage> messages = [];
          bool isTyping = false;

          if (state is ChatbotInitial) messages = state.messages;
          else if (state is ChatbotLoading) {
            messages = state.messages;
            isTyping = true;
          } else if (state is ChatbotLoaded) messages = state.messages;
          else if (state is ChatbotError) messages = state.messages;

          return Column(
            children: [
              // Divider
              Divider(
                height: 1,
                thickness: 1,
                color: isDark ? const Color(0xFF334155) : const Color(0xFFEADFCA),
              ),

              // Message viewport
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16.0),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return ChatBubble(message: messages[index]);
                  },
                ),
              ),

              // Typing Indicator
              if (isTyping)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Text(
                          "Tapo is typing",
                          style: AppFonts.poppinsRegular(
                            fontSize: 12,
                            color: theme.textTheme.bodySmall?.color ?? AppColors.primaryBlack40,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const _TypingIndicatorDots(),
                      ],
                    ),
                  ),
                ),

              // Suggestion Chips
              if (messages.length == 1 && !isTyping)
                SizedBox(
                  height: 44,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _suggestions.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: InputChip(
                          label: Text(
                            _suggestions[index],
                            style: AppFonts.poppinsMedium(
                              fontSize: 12.5,
                              color: isDark ? const Color(0xFFC9A14A) : const Color(0xFF8C6623),
                            ),
                          ),
                          backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFFAF6EE),
                          selectedColor: const Color(0xFFC9A14A).withAlpha(50),
                          side: BorderSide(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFEADFCA),
                          ),
                          onPressed: () {
                            _handleSend(_suggestions[index]);
                          },
                        ),
                      );
                    },
                  ),
                ),
              
              const SizedBox(height: 8),

              // Bottom Input Bar
              Container(
                padding: EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  MediaQuery.of(context).viewPadding.bottom > 0
                      ? MediaQuery.of(context).viewPadding.bottom + 8
                      : 16,
                ),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFAF8F5),
                  border: Border(
                    top: BorderSide(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFEADFCA),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 15),
                        textInputAction: TextInputAction.send,
                        onSubmitted: _handleSend,
                        decoration: InputDecoration(
                          hintText: "Ask Tapo anything...",
                          hintStyle: AppFonts.poppinsRegular(
                            color: theme.textTheme.bodySmall?.color ?? AppColors.primaryBlack40,
                            fontSize: 14.5,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        color: _isListening ? Colors.red : const Color(0xFFC9A14A),
                      ),
                      onPressed: () {
                        if (_isListening) {
                          _stopListening();
                        } else {
                          _startListening();
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.send_rounded,
                        color: Color(0xFFC9A14A),
                      ),
                      onPressed: () => _handleSend(_controller.text),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TypingIndicatorDots extends StatefulWidget {
  const _TypingIndicatorDots();

  @override
  State<_TypingIndicatorDots> createState() => _TypingIndicatorDotsState();
}

class _TypingIndicatorDotsState extends State<_TypingIndicatorDots> {
  int _dotCount = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 350), (timer) {
      if (mounted) {
        setState(() {
          _dotCount = (_dotCount + 1) % 4;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '.' * _dotCount,
          style: AppFonts.poppinsBold(
            fontSize: 14,
            color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.primaryBlack40,
          ),
        ),
      ),
    );
  }
}
