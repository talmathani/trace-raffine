import '../../domain/models/customer_design_model.dart';
import '../../domain/repositories/customer_design_repository.dart';
import '../datasources/appwrite/customer_design_appwrite_datasource.dart';

class CustomerDesignRepositoryImpl implements CustomerDesignRepository {
  CustomerDesignRepositoryImpl({
    CustomerDesignAppwriteDataSource? appwriteDataSource,
  }) : _appwriteDataSource =
           appwriteDataSource ?? CustomerDesignAppwriteDataSource();

  final CustomerDesignAppwriteDataSource _appwriteDataSource;

  @override
  Stream<List<CustomerDesignModel>> watchApprovedDesigns({String? category}) {
    return _appwriteDataSource
        .watchApprovedDesigns(category: category)
        .map(
          (documentList) => documentList.documents
              .map(
                (document) => CustomerDesignModel.fromFirestore(
                  document.$id,
                  document.data,
                ),
              )
              .toList(growable: false),
        );
  }

  @override
  Future<CustomerDesignModel?> getDesign({required String designId}) async {
    final document = await _appwriteDataSource.getDesign(designId: designId);

    return CustomerDesignModel.fromFirestore(document.$id, document.data);
  }
}
