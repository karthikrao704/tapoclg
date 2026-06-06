import 'package:flutter/material.dart';
import 'package:tapovana_mobile_app/core/theme/app_fonts.dart';
import 'package:tapovana_mobile_app/features/chatbot/domain/models/message_model.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Bubbles styling config
    final Alignment alignment = message.isUser ? Alignment.centerRight : Alignment.centerLeft;
    
    final Color bubbleColor = message.isUser
        ? const Color(0xFFC9A14A) // Premium Tapovana Gold
        : (isDark ? const Color(0xFF1E293B) : const Color(0xFFFAF6EE)); // Dark slate vs soft cream

    final Color textColor = message.isUser
        ? Colors.white
        : (isDark ? Colors.white : const Color(0xFF191F38));

    final BorderRadius borderRadius = message.isUser
        ? const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(2),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(2),
            bottomRight: Radius.circular(16),
          );

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.75,
        ),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: borderRadius,
          border: message.isUser
              ? null
              : Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFEADFCA),
                  width: 1,
                ),
        ),
        child: Text(
          message.text,
          style: AppFonts.poppinsRegular(
            fontSize: 14.5,
            color: textColor,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
