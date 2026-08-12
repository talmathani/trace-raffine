import 'package:cloud_firestore/cloud_firestore.dart';

class DesignerDesignFirestoreDataSource {
  DesignerDesignFirestoreDataSource({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _designsCollection =>
      _firestore.collection('designer_designs');

  Future<String> createDesign({
    required String designId,
    required Map<String, dynamic> data,
  }) async {
    await _designsCollection.doc(designId).set({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return designId;
  }

  Future<void> updateDesign({
    required String designId,
    required Map<String, dynamic> data,
  }) {
    return _designsCollection.doc(designId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteDesign({
    required String designId,
  }) {
    return _designsCollection.doc(designId).delete();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchDesignerDesigns({
    required String designerId,
  }) {
    return _designsCollection
        .where('designerId', isEqualTo: designerId)
        .snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getDesign({
    required String designId,
  }) {
    return _designsCollection.doc(designId).get();
  }
}

