class FeaturedWorkshop {
  final String title;
  final String subtitle;
  final String description;
  final String time;
  final String duration;
  final String date;
  final String tag;
  final String? imagePath;
  final double progress;
  final String theory;
  final String youtubeVideoUrl;
  final List<String> modules;
  final List<bool> moduleCompleted;

  const FeaturedWorkshop({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.time,
    required this.duration,
    required this.date,
    required this.tag,
    this.imagePath,
    required this.progress,
    required this.theory,
    required this.youtubeVideoUrl,
    required this.modules,
    required this.moduleCompleted,
  });

  factory FeaturedWorkshop.fromJson(Map<String, dynamic> json) {
    final title = json['title'] ?? '';
    final category = json['category'] ?? '';
    final description = json['description'] ?? '';
    final time = json['time'] ?? '12:00 PM';

    final durationVal = json['duration'];
    final duration = durationVal != null ? '$durationVal mins' : '60 mins';

    String dateStr = 'Oct 24';
    try {
      final dateTime = DateTime.tryParse(json['date'] ?? '');
      if (dateTime != null) {
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        final month = months[dateTime.month - 1];
        final day = dateTime.day.toString().padLeft(2, '0');
        dateStr = '$month $day';
      }
    } catch (_) {}

    final tag = category.toString().toUpperCase();

    String? imagePath = json['image_url'];
    if (imagePath != null && imagePath.isNotEmpty) {
      if (!imagePath.startsWith('http')) {
        final prefix = imagePath.startsWith('/') ? '' : '/';
        imagePath = 'https://tapovana.onrender.com$prefix$imagePath';
      }
    }

    final videoUrl = json['video_url'] ?? '';
    String finalVideoUrl = '';
    if (videoUrl.isNotEmpty) {
      if (!videoUrl.startsWith('http')) {
        final prefix = videoUrl.startsWith('/') ? '' : '/';
        finalVideoUrl = 'https://tapovana.onrender.com$prefix$videoUrl';
      } else {
        finalVideoUrl = videoUrl;
      }
    }

    List<String> modulesList;
    if (category.toLowerCase().contains('meditation')) {
      modulesList = [
        'Introduction to Mindful Breathing',
        'Body Scan Meditation Practice',
        'Cultivating Inner Peace & Quiet',
        'Loving-Kindness (Metta) Practice'
      ];
    } else if (category.toLowerCase().contains('yoga')) {
      modulesList = [
        'Sun Salutations & Alignment',
        'Standing Postures for Stability',
        'Deep Restorative Stretches',
        'Integrating Breath and Movement'
      ];
    } else {
      modulesList = [
        'Introduction and Setup',
        'Core Concepts and Principles',
        'Practical Application Exercises',
        'Final Integration & Summary'
      ];
    }

    final List<bool> completedList = List.generate(modulesList.length, (idx) => false);

    return FeaturedWorkshop(
      title: title,
      subtitle: category,
      description: description,
      time: time,
      duration: duration,
      date: dateStr,
      tag: tag,
      imagePath: imagePath,
      progress: 0.0,
      theory: description.isNotEmpty ? description : 'No core principles description provided.',
      youtubeVideoUrl: finalVideoUrl,
      modules: modulesList,
      moduleCompleted: completedList,
    );
  }
}

class VedicPackage {
  final String title;
  final String subtitle;
  final String? imagePath;
  final String description;
  final String duration;
  final String price;
  final String originalPrice;
  final List<String> benefits;
  final List<String> whatsIncluded;
  final List<String> tags;

  const VedicPackage({
    required this.title,
    required this.subtitle,
    this.imagePath,
    required this.description,
    required this.duration,
    required this.price,
    required this.originalPrice,
    required this.benefits,
    required this.whatsIncluded,
    required this.tags,
  });
}

class WellnessBlogPost {
  final String category;
  final String title;
  final String? imagePath;
  final String content;
  final String author;
  final String date;
  final String readTime;

  const WellnessBlogPost({
    required this.category,
    required this.title,
    this.imagePath,
    required this.content,
    required this.author,
    required this.date,
    required this.readTime,
  });
}
