import '../../domain/models/customer_design_model.dart';
import '../../domain/repositories/customer_design_repository.dart';
import '../datasources/firebase/customer_design_firestore_datasource.dart';

class CustomerDesignRepositoryImpl implements CustomerDesignRepository {
  CustomerDesignRepositoryImpl({
    CustomerDesignFirestoreDataSource? firestoreDataSource,
  }) : _firestoreDataSource =
          firestoreDataSource ?? CustomerDesignFirestoreDataSource();

  final CustomerDesignFirestoreDataSource _firestoreDataSource;

  @override
  Stream<List<CustomerDesignModel>> watchApprovedDesigns({
    String? category,
  }) {
    return _firestoreDataSource
        .watchApprovedDesigns(category: category)
        .map(
          (snapshot) => snapshot.docs
              .map(
                (document) => CustomerDesignModel.fromFirestore(
                  document.id,
                  document.data(),
                ),
              )
              .toList(growable: false),
        );
  }

  @override
  Future<CustomerDesignModel?> getDesign({
    required String designId,
  }) async {
    final document = await _firestoreDataSource.getDesign(
      designId: designId,
    );

    if (!document.exists) {
      return null;
    }

    final data = document.data();

    if (data == null) {
      return null;
    }

    return CustomerDesignModel.fromFirestore(
      document.id,
      data,
    );
  }
}
