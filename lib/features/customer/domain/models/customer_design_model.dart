class CustomerDesignModel {
  const CustomerDesignModel({
    required this.id,
    required this.designerId,
    required this.title,
    required this.category,
    required this.price,
    required this.fileExtension,
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
  });

  final String id;
  final String designerId;
  final String title;
  final String category;
  final double price;
  final String fileExtension;
  final String status;

  final String? description;

  final String? designImagePath;
  final String? designImageUrl;

  final String? embroideryFilePath;
  final String? embroideryFileUrl;

  final String? stitchDetails;
  final String? beadDetails;
  final String? sequinDetails;
  final String? additionalDetails;

  factory CustomerDesignModel.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    return CustomerDesignModel(
      id: id,
      designerId: _stringValue(data['designerId']),
      title: _stringValue(data['title']),
      category: _stringValue(data['category']),
      price: _doubleValue(data['price']),
      fileExtension: _stringValue(data['fileExtension']),
      status: _stringValue(data['status']),
      description: _nullableString(data['description']),
      designImagePath: _nullableString(data['designImagePath']),
      designImageUrl: _nullableString(data['designImageUrl']),
      embroideryFilePath: _nullableString(data['embroideryFilePath']),
      embroideryFileUrl: _nullableString(data['embroideryFileUrl']),
      stitchDetails: _nullableString(data['stitchDetails']),
      beadDetails: _nullableString(data['beadDetails']),
      sequinDetails: _nullableString(data['sequinDetails']),
      additionalDetails: _nullableString(data['additionalDetails']),
    );
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

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
