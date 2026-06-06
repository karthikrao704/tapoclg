/// Model for a service summary (from GET /api/services list).
class ServiceModel {
  final String id;
  final String serviceId;
  final String name;
  final String category;
  final String subcategory;
  final String basePrice;
  final int durationMinutes;
  final String status;
  final String? imageUrl;
  final DateTime createdAt;
  final String createdByName;

  const ServiceModel({
    required this.id,
    required this.serviceId,
    required this.name,
    required this.category,
    required this.subcategory,
    required this.basePrice,
    required this.durationMinutes,
    required this.status,
    this.imageUrl,
    required this.createdAt,
    required this.createdByName,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    String? imageUrl = json['image_url'];
    if (imageUrl != null && imageUrl.isNotEmpty) {
      if (!imageUrl.startsWith('http')) {
        // Handle leading slash safely
        final prefix = imageUrl.startsWith('/') ? '' : '/';
        imageUrl = 'https://tapovana.onrender.com$prefix$imageUrl';
      }
    }

    return ServiceModel(
      id: json['id']?.toString() ?? '',
      serviceId: json['service_id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      subcategory: json['subcategory'] ?? '',
      basePrice: json['base_price'] ?? '0.00',
      durationMinutes: json['duration_minutes'] ?? 0,
      status: json['status'] ?? '',
      imageUrl: imageUrl,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      createdByName: json['created_by_name'] ?? '',
    );
  }

  /// Formatted price with ₹ symbol.
  String get formattedPrice => '₹${double.tryParse(basePrice)?.toStringAsFixed(0) ?? basePrice}';

  /// Formatted duration string.
  String get formattedDuration => '$durationMinutes mins';

  /// Duration and category combined.
  String get durationAndCategory => '$formattedDuration • $category';
}
