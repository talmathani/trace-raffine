enum DesignerDesignStatus { pending, approved, rejected }

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
    this.designImagePath,
    this.designImageUrl,
    this.embroideryFilePath,
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

  final String? designImagePath;
  final String? designImageUrl;

  final String? embroideryFilePath;
  final String? embroideryFileUrl;

  final String? stitchDetails;
  final String? beadDetails;
  final String? sequinDetails;
  final String? additionalDetails;

  final DateTime? submittedAt;
  final DateTime? updatedAt;

  final String? rejectionReason;

  factory DesignerDesignModel.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    return DesignerDesignModel(
      id: id,
      designerId: _stringValue(data['designerId']),
      title: _stringValue(data['title']),
      category: _stringValue(data['category']),
      fileExtension: _stringValue(data['fileExtension']),
      price: _doubleValue(data['price']),
      status: _statusValue(data['status']),
      description: _nullableString(data['description']),
      designImagePath: _nullableString(data['designImagePath']),
      designImageUrl: _nullableString(data['designImageUrl']),
      embroideryFilePath: _nullableString(data['embroideryFilePath']),
      embroideryFileUrl: _nullableString(data['embroideryFileUrl']),
      stitchDetails: _nullableString(data['stitchDetails']),
      beadDetails: _nullableString(data['beadDetails']),
      sequinDetails: _nullableString(data['sequinDetails']),
      additionalDetails: _nullableString(data['additionalDetails']),
      submittedAt: _dateTimeValue(data[r'$createdAt'] ?? data['createdAt']),
      updatedAt: _dateTimeValue(data[r'$updatedAt'] ?? data['updatedAt']),
      rejectionReason: _nullableString(data['rejectionReason']),
    );
  }

  static DesignerDesignStatus _statusValue(dynamic value) {
    switch (value?.toString().trim().toLowerCase()) {
      case 'approved':
        return DesignerDesignStatus.approved;
      case 'rejected':
        return DesignerDesignStatus.rejected;
      case 'pending':
      default:
        return DesignerDesignStatus.pending;
    }
  }

  static String _stringValue(dynamic value) {
    return value?.toString().trim() ?? '';
  }

  static String? _nullableString(dynamic value) {
    final normalized = value?.toString().trim();

    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    return normalized;
  }

  static double _doubleValue(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString().trim() ?? '') ?? 0;
  }

  static DateTime? _dateTimeValue(dynamic value) {
    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }
}
