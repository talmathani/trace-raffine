import 'dart:async';
import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:trace_raffine/core/appwrite/appwrite_config.dart';
import 'package:flutter/foundation.dart';
import 'package:trace_raffine/core/appwrite/appwrite_database_constants.dart';
import 'package:trace_raffine/core/appwrite/appwrite_database_service.dart';
import 'package:trace_raffine/core/appwrite/appwrite_service.dart';
import 'package:trace_raffine/core/auth/current_user_service.dart';
import '../../../domain/models/designer_design_model.dart';

class DesignerDesignAppwriteDataSource {
  final AppwriteDatabaseService _databaseService;

  DesignerDesignAppwriteDataSource({AppwriteDatabaseService? databaseService})
    : _databaseService = databaseService ?? AppwriteDatabaseService();

  Future<String> createDesign({
    required String designId,
    required Map<String, dynamic> data,
  }) async {
    final currentUserId = await CurrentUserService.userId;
    final designerId = data['designer_id']?.toString().trim() ?? '';
    if (currentUserId == null ||
        designerId.isEmpty ||
        designerId != currentUserId) {
      throw AppwriteException('Designer ownership validation failed', 403);
    }

    final document = await _databaseService.createDocument(
      collectionId: AppwriteDatabaseConstants.designsCollectionId,
      documentId: designId,
      data: data,
      permissions: [
        Permission.read(Role.user(data['designer_id']?.toString() ?? '')),
        Permission.read(Role.team(AppwriteConfig.adminsTeamId)),
        Permission.update(Role.user(data['designer_id']?.toString() ?? '')),
        Permission.delete(Role.user(data['designer_id']?.toString() ?? '')),
      ],
    );

    try {
      final execution = await Functions(AppwriteService.client).createExecution(
        functionId: 'admin-user-control',
        body: jsonEncode({
          'action': 'design_submitted',
          'designId': document.$id,
        }),
        xasync: false,
      );
      final responseBody = execution.responseBody.trim();
      if (responseBody.isEmpty) {
        throw StateError('Design submission notification returned an empty response.');
      }
      final response = jsonDecode(responseBody);
      if (response is! Map || response['success'] != true) {
        throw StateError(
          response is Map
              ? response['error']?.toString() ?? 'Could not notify administrators.'
              : 'Invalid design submission notification response.',
        );
      }
    } catch (error, stackTrace) {
      // The design document is already persisted. A notification failure must
      // never delete the user's design or make the UI report a false upload
      // failure. Keep the pending design available in the admin review list and
      // retain the precise failure in logs for diagnosis.
      debugPrint(
        'DESIGN SUBMISSION WARNING: design saved but admin notification failed '
        'designId=${document.$id} errorType=${error.runtimeType} error=$error',
      );
      debugPrintStack(stackTrace: stackTrace);
    }

    return document.$id;
  }

  Future<DesignerDesignModel?> getDesign({required String designId}) async {
    try {
      final document = await _databaseService.getDocument(
        collectionId: AppwriteDatabaseConstants.designsCollectionId,
        documentId: designId,
      );
      await _requireOwner(document.data);
      return DesignerDesignModel.fromAppwrite(document.$id, document.data);
    } on AppwriteException catch (error) {
      if (error.code == 404) return null;
      rethrow;
    }
  }

  Future<void> updateDesign({
    required String designId,
    required Map<String, dynamic> data,
  }) async {
    final current = await _databaseService.getDocument(
      collectionId: AppwriteDatabaseConstants.designsCollectionId,
      documentId: designId,
    );
    await _requireOwner(current.data);
    final requestedDesignerId = data['designer_id']?.toString().trim();
    if (requestedDesignerId != null &&
        requestedDesignerId != (await CurrentUserService.userId)) {
      throw AppwriteException('Designer ownership validation failed', 403);
    }
    await _databaseService.updateDocument(
      collectionId: AppwriteDatabaseConstants.designsCollectionId,
      documentId: designId,
      data: data,
    );
  }

  Future<void> deleteDesign({required String designId}) async {
    final current = await _databaseService.getDocument(
      collectionId: AppwriteDatabaseConstants.designsCollectionId,
      documentId: designId,
    );
    await _requireOwner(current.data);
    await _databaseService.deleteDocument(
      collectionId: AppwriteDatabaseConstants.designsCollectionId,
      documentId: designId,
    );
  }

  Future<void> _requireOwner(Map<String, dynamic> data) async {
    final currentUserId = await CurrentUserService.userId;
    final ownerId = data['designer_id']?.toString().trim();
    if (currentUserId == null || ownerId == null || ownerId != currentUserId) {
      throw AppwriteException('Designer ownership validation failed', 403);
    }
  }

  Stream<List<DesignerDesignModel>> watchDesignerDesigns({
    required String designerId,
  }) async* {
    final currentUserId = await CurrentUserService.userId;
    if (currentUserId == null || currentUserId != designerId) {
      throw AppwriteException('Designer ownership validation failed', 403);
    }

    Future<List<DesignerDesignModel>> loadDesigns() async {
      final documentList = await _databaseService.listDocuments(
        collectionId: AppwriteDatabaseConstants.designsCollectionId,
        queries: [Query.equal('designer_id', designerId)],
      );
      return documentList.documents
          .map((doc) => DesignerDesignModel.fromAppwrite(doc.$id, doc.data))
          .toList(growable: false);
    }

    // Render current data immediately, then listen for changes from the admin.
    yield await loadDesigns();

    final realtime = Realtime(AppwriteService.client);
    final subscription = realtime.subscribe([
      Channel.database(AppwriteDatabaseConstants.databaseId)
          .collection(AppwriteDatabaseConstants.designsCollectionId)
          .document(),
      // The review log is written before its notification; listening to both
      // ensures the feedback lookup runs after the latest review is persisted.
      Channel.database(AppwriteDatabaseConstants.databaseId)
          .collection(AppwriteDatabaseConstants.notificationsCollection)
          .document(),
    ]);
    final updates = StreamController<List<DesignerDesignModel>>();
    var refreshing = false;

    Future<void> refresh() async {
      if (refreshing || updates.isClosed) return;
      refreshing = true;
      try {
        updates.add(await loadDesigns());
      } catch (error, stackTrace) {
        updates.addError(error, stackTrace);
      } finally {
        refreshing = false;
      }
    }

    final realtimeListener = subscription.stream.listen(
      (_) => refresh(),
      onError: (_) => refresh(),
    );
    // Recovery path if a WebSocket is temporarily unavailable.
    final fallbackTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => refresh(),
    );

    try {
      yield* updates.stream;
    } finally {
      fallbackTimer.cancel();
      await realtimeListener.cancel();
      await subscription.close();
      await updates.close();
    }
  }
}
