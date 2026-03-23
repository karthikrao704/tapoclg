class FeaturedWorkshop {
  final String title;
  final String subtitle;
  final String description;
  final String time;
  final String duration;
  final String date;
  final String tag;
  // imagePath will be set when user provides actual images
  final String? imagePath;

  const FeaturedWorkshop({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.time,
    required this.duration,
    required this.date,
    required this.tag,
    this.imagePath,
  });
}

class VedicPackage {
  final String title;
  final String subtitle;
  // imagePath will be set when user provides actual images
  final String? imagePath;

  const VedicPackage({
    required this.title,
    required this.subtitle,
    this.imagePath,
  });
}

class EducationalCourse {
  final String title;
  final String lessons;
  final String level;
  final String iconType; // 'book' or 'lotus'
  final String? imagePath;

  const EducationalCourse({
    required this.title,
    required this.lessons,
    required this.level,
    required this.iconType,
    this.imagePath,
  });
}

class WellnessBlogPost {
  final String category;
  final String title;
  final String? imagePath;

  const WellnessBlogPost({
    required this.category,
    required this.title,
    this.imagePath,
  });
}
