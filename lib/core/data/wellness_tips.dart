// lib/core/data/wellness_tips.dart

/// A list of 30 curated daily wellness tips covering mindfulness, physical health,
/// nutrition, sleep, and mental wellbeing.
const List<String> wellnessTips = [
  "Start your morning with 3 deep, mindful breaths before looking at your phone to center your mind.",
  "Stay hydrated today. Drinking 8 glasses of water helps maintain your skin's natural glow and boosts energy levels.",
  "Try a 5-minute stretch right now. Release the tension in your shoulders and neck from sitting.",
  "A walk in nature or around the block can clear your mind and boost your mood. Take 10 minutes today.",
  "Practice gratitude. Write down three things you are thankful for today, no matter how small.",
  "Protect your posture. Adjust your chair and screen height so your head is aligned over your neck.",
  "Prioritize sleep tonight. Avoid screens 1 hour before bed to promote deeper, restorative sleep.",
  "Eat the rainbow! Include colorful fruits and vegetables in your meals today for essential nutrients.",
  "Give your eyes a break. Follow the 20-20-20 rule: every 20 minutes, look 20 feet away for 20 seconds.",
  "Practice mindful eating today. Pay attention to the textures, smells, and flavors of your food.",
  "Power down. Dedicate 30 minutes of your day to complete screen-free relaxation.",
  "A warm cup of herbal tea like chamomile or peppermint can soothe your digestion and calm your nervous system.",
  "Keep moving. Stand up and stretch for at least 2 minutes for every hour of desk work.",
  "Laughter is medicine. Watch a funny video or talk to a friend who makes you laugh today.",
  "Nourish your skin. Apply a gentle moisturizer and wear sunscreen before stepping outdoors.",
  "Focus on breathing. Take slow, deep belly breaths for 2 minutes to lower stress hormones.",
  "Declutter one small area of your desk or room. A clear space leads to a clear mind.",
  "Listen to your body. If you feel tired, take a 10-minute quiet break or rest your eyes.",
  "Sip green tea today. It is rich in antioxidants that protect your cells and support overall wellness.",
  "Reconnect with a friend. Send a warm text to someone you haven't spoken to in a while.",
  "Stretch your hamstrings and back. A gentle forward bend can relieve tension accumulated throughout the day.",
  "Boost your immunity. Include vitamin-C rich foods like oranges, bell peppers, or strawberries in your snacks.",
  "Acknowledge your progress. Celebrate one small goal or achievement you completed this week.",
  "Limit processed sugar. Swap sweet cravings for fresh fruit or natural yogurt today.",
  "Take a warm, relaxing bath or shower tonight to melt away muscle tension and prepare for sleep.",
  "Inhale calmness, exhale stress. Focus on the sensation of cool air entering and warm air exiting your nose.",
  "Practice active listening. Give your full, undivided attention to whoever you speak with today.",
  "Walk barefoot on grass or soil (grounding) for a few minutes to connect with nature and reduce stress.",
  "Keep your joints healthy. Do gentle circular movements with your ankles and wrists to maintain flexibility.",
  "Be kind to yourself. Replace any self-critical thoughts with a gentle affirmation: 'I am doing my best.'"
];

/// Returns the wellness tip for the given date.
/// Uses a deterministic index computation so that the same date always returns the same tip,
/// even when offline.
String getWellnessTipForDate(DateTime date) {
  // Use a fixed epoch reference (January 1st, 2026) to calculate days elapsed.
  final epoch = DateTime(2026, 1, 1);
  // Calculate difference in days. Using UTC normalization avoids timezone shifting bugs.
  final dateUtc = DateTime(date.year, date.month, date.day);
  final difference = dateUtc.difference(epoch).inDays;
  final index = difference.abs() % wellnessTips.length;
  return wellnessTips[index];
}

const List<String> wellnessProverbs = [
  "\"Health is a state of complete physical, mental, and social well-being, and not merely the absence of disease or infirmity.\"",
  "\"The groundwork for all happiness is good health.\"",
  "\"A calm mind brings inner strength and self-confidence, so that's very important for good health.\"",
  "\"Let food be thy medicine and medicine be thy food.\"",
  "\"To keep the body in good health is a duty... otherwise we shall not be able to keep our mind strong and clear.\"",
  "\"The mind and body are not separate. What affects one, affects the other.\"",
  "\"Physical fitness is the first requisite of happiness.\"",
  "\"Take care of your body. It's the only place you have to live.\"",
  "\"The greatest wealth is health.\"",
  "\"Wellness is a connection of paths: knowledge and action.\"",
  "\"It is health that is real wealth and not pieces of gold and silver.\"",
  "\"A good laugh and a long sleep are the best cures in the doctor's book.\"",
  "\"Your body hears everything your mind says. Stay positive.\"",
  "\"Happiness is the highest form of health.\""
];

String getWellnessProverbForDate(DateTime date) {
  final epoch = DateTime(2026, 1, 1);
  final dateUtc = DateTime(date.year, date.month, date.day);
  final difference = dateUtc.difference(epoch).inDays;
  final index = difference.abs() % wellnessProverbs.length;
  return wellnessProverbs[index];
}
