import 'package:flutter/material.dart';

class TipCard extends StatelessWidget {
  final String tipText;
  const TipCard({super.key, required this.tipText});

  @override
  Widget build(BuildContext context) {
    // Accessing the theme to use defined colors and text styles
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        // Uses the light greenish background mapped to secondary in AppTheme
        color: theme.colorScheme.secondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 18,
                // Uses the Olive Tan color mapped to onSecondary in AppTheme
                color: theme.colorScheme.onSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'DAILY WELLNESS TIP',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSecondary,
                  fontWeight: FontWeight.bold,
                  letterSpacing:
                      1.2, // Gives the text that spaced-out, premium look
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            tipText,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5, // Increases line height for better readability
            ),
          ),
        ],
      ),
    );
  }
}
