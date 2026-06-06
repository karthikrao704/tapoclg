import 'dart:async';
import 'package:flutter/material.dart';

class TipCard extends StatefulWidget {
  final String tipText;
  const TipCard({super.key, required this.tipText});

  @override
  State<TipCard> createState() => _TipCardState();
}

class _TipCardState extends State<TipCard> {
  bool _isExpanded = true;
  Timer? _collapseTimer;

  @override
  void initState() {
    super.initState();
    // Schedule compression after 4 seconds
    _collapseTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _isExpanded = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _collapseTimer?.cancel();
    super.dispose();
  }

  void _toggleExpanded() {
    // Cancel the timer if the user interacts manually
    _collapseTimer?.cancel();
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Accessing the theme to use defined colors and text styles
    final theme = Theme.of(context);

    // Fetch the system's text scaler to scale non-text UI elements proportionally
    final textScaler = MediaQuery.textScalerOf(context);

    return GestureDetector(
      onTap: _toggleExpanded,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic,
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    // Scales the base 18px size by the user's font scale preference
                    size: textScaler.scale(18),
                    color: theme.colorScheme.onSecondary,
                  ),
                  const SizedBox(width: 8),
                  // Expanded prevents horizontal overflow if the font is huge
                  Expanded(
                    child: Text(
                      'DAILY WELLNESS TIP',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSecondary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  // Animated Chevron to indicate expansion state
                  AnimatedRotation(
                    turns: _isExpanded ? 0.0 : 0.5,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOutCubic,
                    child: Icon(
                      Icons.keyboard_arrow_up,
                      color: theme.colorScheme.onSecondary.withValues(alpha: 0.8),
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Body text collapses/expands smoothly
              Text(
                widget.tipText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  color: theme.colorScheme.onSecondary.withValues(alpha: 0.9),
                ),
                maxLines: _isExpanded ? null : 1,
                overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
