import '../models/customer_design_model.dart';

abstract class CustomerDesignRepository {
  Stream<List<CustomerDesignModel>> watchApprovedDesigns({
    String? category,
  });

  Future<CustomerDesignModel?> getDesign({
    required String designId,
  });
}
