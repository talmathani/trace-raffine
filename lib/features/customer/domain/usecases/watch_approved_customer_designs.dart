import '../models/customer_design_model.dart';
import '../repositories/customer_design_repository.dart';

class WatchApprovedCustomerDesigns {
  const WatchApprovedCustomerDesigns({required this._repository});

  final CustomerDesignRepository _repository;

  Stream<List<CustomerDesignModel>> call({String? category}) {
    return _repository.watchApprovedDesigns(category: category);
  }
}
