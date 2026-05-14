/// Model for full service details (from GET /api/services/:id).
class ServiceDetailModel {
  final String id;
  final String serviceId;
  final String authUserId;
  final String name;
  final String category;
  final String subcategory;
  final String description;
  final String benefits;
  final String tools;
  final String basePrice;
  final int durationMinutes;
  final String? requiredCertification;
  final String? experienceLevel;
  final String? imageUrl;
  final String? imageNextcloudPath;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? publishedAt;
  final String firstName;
  final String lastName;
  final String? specialization;
  final String? avatarUrl;

  const ServiceDetailModel({
    required this.id,
    required this.serviceId,
    required this.authUserId,
    required this.name,
    required this.category,
    required this.subcategory,
    required this.description,
    required this.benefits,
    required this.tools,
    required this.basePrice,
    required this.durationMinutes,
    this.requiredCertification,
    this.experienceLevel,
    this.imageUrl,
    this.imageNextcloudPath,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.publishedAt,
    required this.firstName,
    required this.lastName,
    this.specialization,
    this.avatarUrl,
  });

  factory ServiceDetailModel.fromJson(Map<String, dynamic> json) {
    return ServiceDetailModel(
      id: json['id']?.toString() ?? '',
      serviceId: json['service_id'] ?? '',
      authUserId: json['auth_user_id']?.toString() ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      subcategory: json['subcategory'] ?? '',
      description: json['description'] ?? '',
      benefits: json['benefits'] ?? '',
      tools: json['tools'] ?? '',
      basePrice: json['base_price'] ?? '0.00',
      durationMinutes: json['duration_minutes'] ?? 0,
      requiredCertification: json['required_certification'],
      experienceLevel: json['experience_level'],
      imageUrl: json['image_url'],
      imageNextcloudPath: json['image_nextcloud_path'],
      status: json['status'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      publishedAt: json['published_at'] != null
          ? DateTime.tryParse(json['published_at'])
          : null,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      specialization: json['specialization'],
      avatarUrl: json['avatar_url'],
    );
  }

  /// Full name of the expert who created this service.
  String get expertName => '$firstName $lastName'.trim();

  /// Formatted price with ₹ symbol.
  String get formattedPrice =>
      '₹${double.tryParse(basePrice)?.toStringAsFixed(0) ?? basePrice}';

  /// Formatted duration string.
  String get formattedDuration => '$durationMinutes Minutes';

  /// Benefits as a list (split by newline).
  List<String> get benefitsList =>
      benefits.split('\n').where((b) => b.trim().isNotEmpty).toList();

  /// Tools as a list (split by newline).
  List<String> get toolsList =>
      tools.split('\n').where((t) => t.trim().isNotEmpty).toList();
}
