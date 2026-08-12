import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerDesignFirestoreDataSource {
  CustomerDesignFirestoreDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _designsCollection =>
      _firestore.collection('designer_designs');

  Stream<QuerySnapshot<Map<String, dynamic>>> watchApprovedDesigns({
    String? category,
  }) {
    Query<Map<String, dynamic>> query = _designsCollection
        .where('status', isEqualTo: 'approved')
        .orderBy('createdAt', descending: true);

    final normalizedCategory = category?.trim();

    if (normalizedCategory != null && normalizedCategory.isNotEmpty) {
      query = _designsCollection
          .where('status', isEqualTo: 'approved')
          .where('category', isEqualTo: normalizedCategory)
          .orderBy('createdAt', descending: true);
    }

    return query.snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getDesign({
    required String designId,
  }) {
    return _designsCollection.doc(designId).get();
  }
}
