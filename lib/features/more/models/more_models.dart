class FeaturedWorkshop {
  final String title;
  final String subtitle;
  final String description;
  final String time;
  final String duration;
  final String date;
  final String tag;
  final String? imagePath;
  final String youtubeVideoUrl;

  const FeaturedWorkshop({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.time,
    required this.duration,
    required this.date,
    required this.tag,
    this.imagePath,
    required this.youtubeVideoUrl,
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

    return FeaturedWorkshop(
      title: title,
      subtitle: category,
      description: description,
      time: time,
      duration: duration,
      date: dateStr,
      tag: tag,
      imagePath: imagePath,
      youtubeVideoUrl: finalVideoUrl,
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

  factory VedicPackage.fromJson(Map<String, dynamic> json) {
    final title = json['title'] ?? '';
    final type = json['type'] ?? 'Program';
    final description = json['description'] ?? '';
    final duration = json['duration'] ?? '';

    // Format price with ₹ symbol
    final priceNum = json['price'];
    final priceStr = priceNum != null ? '₹${priceNum.toString()}' : '₹0';
    // Generate an original price ~40% higher for display
    final originalPriceNum = priceNum != null ? (priceNum * 1.4).round() : 0;
    final originalPriceStr = '₹$originalPriceNum';

    // Resolve image URL
    String? imagePath = json['image_url'];
    if (imagePath != null && imagePath.isNotEmpty) {
      if (!imagePath.startsWith('http') && !imagePath.startsWith('data:image')) {
        final prefix = imagePath.startsWith('/') ? '' : '/';
        imagePath = 'https://tapovana.onrender.com$prefix$imagePath';
      }
    }

    // Services list → whatsIncluded
    final List<String> services = (json['services'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList() ?? [];

    // Generate tags from type and languages
    final List<String> tags = [type.toString().toUpperCase()];
    final languages = json['languages'] as List<dynamic>?;
    if (languages != null) {
      for (var lang in languages) {
        tags.add(lang.toString().toUpperCase());
      }
    }

    // Generate benefits from accommodations and capacity
    final List<String> benefits = [];
    final accommodations = json['accommodations'];
    if (accommodations != null && accommodations.toString().isNotEmpty) {
      benefits.add('Accommodation: $accommodations');
    }
    final capacity = json['capacity'];
    if (capacity != null) {
      benefits.add('Limited to $capacity participants');
    }
    final consultantName = json['consultant_name'];
    if (consultantName != null && consultantName.toString().isNotEmpty) {
      benefits.add('Led by $consultantName');
    }
    if (benefits.isEmpty) {
      benefits.add('Holistic Wellness Experience');
    }

    return VedicPackage(
      title: title,
      subtitle: type,
      imagePath: imagePath,
      description: description,
      duration: duration,
      price: priceStr,
      originalPrice: originalPriceStr,
      benefits: benefits,
      whatsIncluded: services,
      tags: tags,
    );
  }
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

  factory WellnessBlogPost.fromJson(Map<String, dynamic> json) {
    String dateStr = 'Unknown Date';
    try {
      final dateTime = DateTime.tryParse(json['published_at'] ?? json['created_at'] ?? '');
      if (dateTime != null) {
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        final month = months[dateTime.month - 1];
        final day = dateTime.day.toString().padLeft(2, '0');
        final year = dateTime.year.toString();
        dateStr = '$month $day, $year';
      }
    } catch (_) {}

    String? imagePath = json['featured_image'];
    if (imagePath != null && imagePath.isNotEmpty) {
      if (!imagePath.startsWith('http')) {
        final prefix = imagePath.startsWith('/') ? '' : '/';
        imagePath = 'https://tapovana.onrender.com$prefix$imagePath';
      }
    }

    String authorName = 'Unknown Author';
    if (json['author'] != null && json['author']['name'] != null) {
      authorName = json['author']['name'];
    }

    return WellnessBlogPost(
      category: json['category'] ?? 'WELLNESS',
      title: json['title'] ?? '',
      imagePath: imagePath,
      content: json['summary'] ?? json['content'] ?? '',
      author: authorName,
      date: dateStr,
      readTime: json['read_time'] ?? '5 min read',
    );
  }
}
