import 'dart:convert';

import '../appwrite/appwrite_database_constants.dart';
import '../appwrite/appwrite_database_service.dart';
import '../../features/auth/data/datasources/appwrite_auth_datasource.dart';

class SecurityService {
  SecurityService({
    required this._databaseService,
    required this._authDataSource,
  });

  final AppwriteDatabaseService _databaseService;
  final AppwriteAuthDataSource _authDataSource;

  Future<void> lockSession({
    required String action,
    String? entity,
    String? entityId,
    Map<String, dynamic>? metadata,
  }) async {
    final currentUser = await _authDataSource.currentUser;
    final userId = currentUser?.$id;
    final timestamp = DateTime.now().toUtc().toIso8601String();

    try {
      await _databaseService.createDocument(
        collectionId: AppwriteDatabaseConstants.auditLogsCollection,
        data: {
          ...?userId == null ? null : {'user_id': userId},
          'action': action,
          ...?entity == null ? null : {'entity': entity},
          ...?entityId == null ? null : {'entity_id': entityId},
          ...?metadata?.isNotEmpty == true
              ? {'metadata_json': jsonEncode(metadata)}
              : null,
          'created_at': timestamp,
        },
      );
    } catch (_) {
      // Security enforcement continues even if audit persistence fails.
    }

    if (userId != null) {
      try {
        await _databaseService.createDocument(
          collectionId: AppwriteDatabaseConstants.notificationsCollection,
          data: {
            'user_id': userId,
            'title': 'تنبيه أمني',
            'body': 'تم إنهاء جلستك لحماية محتوى TRACÉ RAFFINÉ المحمي.',
            'is_read': false,
            'created_at': timestamp,
          },
        );
      } catch (_) {
        // Security enforcement continues even if notification persistence fails.
      }
    }

    try {
      await _authDataSource.deleteCurrentSession();
    } catch (_) {
      // Local security lock will still be enforced by the caller.
    }
  }
}
