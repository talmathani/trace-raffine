enum DesignerDesignStatus {
  pending,
  approved,
  rejected,
}

class DesignerDesignModel {
  const DesignerDesignModel({
    required this.title,
    required this.category,
    required this.fileExtension,
    required this.price,
    required this.status,
    this.description,
    this.designImagePath,
    this.embroideryFilePath,
    this.stitchDetails,
    this.beadDetails,
    this.sequinDetails,
    this.additionalDetails,
    this.submittedAt,
    this.rejectionReason,
  });

  final String title;
  final String category;
  final String fileExtension;
  final double price;

  final DesignerDesignStatus status;

  final String? description;

  final String? designImagePath;
  final String? embroideryFilePath;

  final String? stitchDetails;
  final String? beadDetails;
  final String? sequinDetails;
  final String? additionalDetails;

  final DateTime? submittedAt;
  final String? rejectionReason;
}
