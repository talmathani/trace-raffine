import 'dart:typed_data';

import '../models/designer_design_model.dart';

abstract class DesignerDesignRepository {
  Future<String> createDesign({
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
  });

  Future<void> updateDesign({
    required String designId,
    required Map<String, dynamic> data,
  });

  Future<void> deleteDesign({
    required String designId,
    required String? imagePath,
    required String? embroideryPath,
  });

  Stream<List<DesignerDesignModel>> watchDesignerDesigns({
    required String designerId,
  });

  Future<DesignerDesignModel?> getDesign({required String designId});
}
