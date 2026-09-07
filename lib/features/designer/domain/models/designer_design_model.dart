import '../../../../core/appwrite/appwrite_config.dart';

enum DesignerDesignStatus { pending, approved, published, rejected }

class DesignerDesignModel {
  const DesignerDesignModel({
    required this.id,
    required this.designerId,
    required this.title,
    required this.category,
    required this.fileExtension,
    required this.price,
    required this.status,
    this.description,
    this.designImageUrl,
    this.embroideryFileUrl,
    this.stitchDetails,
    this.beadDetails,
    this.sequinDetails,
    this.additionalDetails,
    this.submittedAt,
    this.updatedAt,
    this.rejectionReason,
  });

  final String id;
  final String designerId;
  final String title;
  final String category;
  final String fileExtension;
  final double price;
  final DesignerDesignStatus status;
  final String? description;
  final String? designImageUrl;
  final String? embroideryFileUrl;
  final String? stitchDetails;
  final String? beadDetails;
  final String? sequinDetails;
  final String? additionalDetails;
  final DateTime? submittedAt;
  final DateTime? updatedAt;
  final String? rejectionReason;

  factory DesignerDesignModel.fromAppwrite(String id, Map<String, dynamic> data) {
    return DesignerDesignModel(
      id: id,
      designerId: _stringValue(data['designer_id']),
      title: _stringValue(data['title']),
      category: _stringValue(data['category_id']),
      fileExtension: _stringValue(data['file_key']).split('.').last,
      price: _doubleValue(data['price']),
      status: _statusValue(data['status']),
      description: _nullableString(data['description']),
      designImageUrl: _buildImageUrl(data['cover_image_url']),
      embroideryFileUrl: _nullableString(data['file_key']),
      additionalDetails: _nullableString(data['additional_details']),
      stitchDetails: _nullableString(data['stitch_details']),
      beadDetails: _nullableString(data['bead_details']),
      sequinDetails: _nullableString(data['sequin_details']),
      submittedAt: _dateTimeValue(data['\$createdAt']),
      updatedAt: _dateTimeValue(data['\$updatedAt']),
      rejectionReason: _nullableString(data['rejection_reason']),
    );
  }

  static String? _buildImageUrl(dynamic value) {
    if (value == null) return null;
    final str = value.toString().trim();
    if (str.isEmpty) return null;

    if (str.startsWith('http://') || str.startsWith('https://')) {
      if (str.contains('appwrite.io') && !str.contains('project=')) {
        final separator = str.contains('?') ? '&' : '?';
        return '$str${separator}project=${AppwriteConfig.projectId}';
      }
      return str;
    }

    return '${AppwriteConfig.endpoint}/storage/buckets/${AppwriteConfig.designFilesBucketId}/files/$str/view?project=${AppwriteConfig.projectId}';
  }

  static DesignerDesignStatus _statusValue(dynamic value) {
    switch (value?.toString().trim().toLowerCase()) {
      case 'approved':
        return DesignerDesignStatus.approved;
      case 'published':
        return DesignerDesignStatus.published;
      case 'rejected':
        return DesignerDesignStatus.rejected;
      case 'pending':
      default:
        return DesignerDesignStatus.pending;
    }
  }

  static String _stringValue(dynamic value) => value?.toString().trim() ?? '';
  static String? _nullableString(dynamic value) {
    final normalized = value?.toString().trim();
    if (normalized == null || normalized.isEmpty) return null;
    return normalized;
  }
  static double _doubleValue(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString().trim() ?? '') ?? 0;
  }
  static DateTime? _dateTimeValue(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}