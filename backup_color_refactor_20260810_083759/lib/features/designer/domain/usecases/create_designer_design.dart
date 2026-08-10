import 'dart:typed_data';

import '../repositories/designer_design_repository.dart';

class CreateDesignerDesign {
  CreateDesignerDesign({
    required this._repository,
  });

  final DesignerDesignRepository _repository;

  Future<String> call({
    required String designerId,
    required String title,
    required String category,
    required String description,
    required double price,
    required String fileExtension,
    required Uint8List designImageBytes,
    required String designImageName,
    required Uint8List embroideryFileBytes,
    required String embroideryFileName,
    String? stitchDetails,
    String? beadDetails,
    String? sequinDetails,
    String? additionalDetails,
  }) {
    return _repository.createDesign(
      designerId: designerId,
      title: title,
      category: category,
      description: description,
      price: price,
      fileExtension: fileExtension,
      designImageBytes: designImageBytes,
      designImageName: designImageName,
      embroideryFileBytes: embroideryFileBytes,
      embroideryFileName: embroideryFileName,
      stitchDetails: stitchDetails,
      beadDetails: beadDetails,
      sequinDetails: sequinDetails,
      additionalDetails: additionalDetails,
    );
  }
}




