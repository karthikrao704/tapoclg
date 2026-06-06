import 'package:flutter/material.dart';
import 'package:tapovana_mobile_app/features/chatbot/presentation/pages/chatbot_page.dart';

class FloatingChatButton extends StatelessWidget {
  const FloatingChatButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: const Color(0xFFC9A14A), // Tapovana Gold
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 4,
      onPressed: () {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (_) => const ChatbotPage(),
          ),
        );
      },
      child: const Icon(
        Icons.chat_bubble_outline_rounded,
        size: 26,
      ),
    );
  }
}
