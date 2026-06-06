import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tapovana_mobile_app/core/theme/app_colors.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';
import 'package:tapovana_mobile_app/features/chatbot/domain/models/message_model.dart';
import 'package:tapovana_mobile_app/features/chatbot/presentation/components/chat_bubble.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  final List<String> _suggestions = [
    "Recommend a Vedic program",
    "What is Deep Tissue Revive?",
    "Tips for stress relief",
    "How do I book an appointment?",
  ];

  @override
  void initState() {
    super.initState();
    // Welcome message from Tapo
    _messages.add(
      ChatMessage(
        id: 'welcome',
        text: "Namaste! I am Tapo, your personal wellness guide. How can I help you on your health and wellness journey today?",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
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

    // Add user message
    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().toString(),
          text: text,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isTyping = true;
    });
    _controller.clear();
    _scrollToBottom();

    // Trigger Tapo's response after a natural delay
    Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      
      final botResponse = _getTapoResponse(text);
      
      setState(() {
        _isTyping = false;
        _messages.add(
          ChatMessage(
            id: DateTime.now().toString(),
            text: botResponse,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
      _scrollToBottom();
    });
  }

  String _getTapoResponse(String userQuery) {
    final query = userQuery.toLowerCase();

    if (query.contains("vedic") || query.contains("program") || query.contains("package")) {
      return "At Tapovana, we recommend our specialized Vedic Programs tailored to balance your mind and body:\n\n"
          "🌿 *Vedic Aromatherapy*: Combines essential herbal extracts with rhythmic strokes to calm the nervous system.\n"
          "🧘 *Private Yoga Session*: A direct, personalized yoga plan suited to your posture and flexibility goals.\n"
          "💆 *Ayurvedic Abhyanga*: A signature full-body warm herbal oil massage to detoxify and rejuvenate cells.";
    }

    if (query.contains("deep tissue") || query.contains("revive") || query.contains("massage")) {
      return "Our *Deep Tissue Revive* session is excellent for relieving chronic muscle tension. It focuses on the deeper layers of muscle tissue and tendons using slow, firm strokes. \n\n"
          "You can select your preferred therapist (like Dr. Aris or Sarah W.) and date directly from the Services tab!";
    }

    if (query.contains("relax") || query.contains("stress") || query.contains("anxious") || query.contains("relief")) {
      return "For immediate stress relief, here are a few simple wellness tips:\n"
          "1. Practice 5 minutes of deep belly breathing (Pranayama).\n"
          "2. Sip warm chamomile or ginger tea.\n"
          "3. Try our calming *Swedish Massage* or a *Private Yoga Session* to release physical tension.\n\n"
          "Would you like me to guide you to our calming services?";
    }

    if (query.contains("appointment") || query.contains("book") || query.contains("how to")) {
      return "Booking an appointment is simple:\n"
          "1. Go to the *Services* tab on the bottom bar.\n"
          "2. Tap on the service card you want (e.g., Deep Tissue Revive).\n"
          "3. Tap the *Book Appointment* button at the bottom.\n"
          "4. Select your date, preferred time slot, therapist, and tap *Confirm Booking*!";
    }

    return "Thank you for asking! I am dedicated to helping you align your health. You can ask me about our wellness services, how to book appointments, or tips on maintaining your daily mind-body balance.";
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
      body: Column(
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
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ChatBubble(message: _messages[index]);
              },
            ),
          ),

          // Typing Indicator
          if (_isTyping)
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
          if (_messages.length == 1 && !_isTyping)
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
                const SizedBox(width: 8),
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
