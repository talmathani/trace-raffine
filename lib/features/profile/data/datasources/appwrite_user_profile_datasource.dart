import 'dart:developer' as developer;

import 'package:appwrite/appwrite.dart';

import '../../../../core/appwrite/appwrite_service.dart';
import '../../../../core/appwrite/appwrite_profile_constants.dart';
import '../models/user_profile_model.dart';

class AppwriteUserProfileDatasource {
  AppwriteUserProfileDatasource([TablesDB? tablesDb])
      : _tablesDb = tablesDb ?? TablesDB(AppwriteService.client);

  final TablesDB _tablesDb;

  Future<UserProfileModel?> getCurrentProfile({
    required String userId,
  }) async {
    try {
      final row = await _tablesDb.getRow(
        databaseId: AppwriteProfileConstants.databaseId,
        tableId: AppwriteProfileConstants.collectionId,
        rowId: userId,
      );

      return UserProfileModel.fromMap({
        'id': row.$id,
        ...row.data,
      });
    } on AppwriteException catch (error, stackTrace) {
      if (error.code == 404) {
        developer.log(
          'Profile not found.',
          name: 'TR.Profile',
        );
        return null;
      }

      developer.log(
        'Appwrite profile load failed: ${error.code}',
        name: 'TR.Profile',
        error: error.message,
        stackTrace: stackTrace,
      );
      rethrow;
    } catch (error, stackTrace) {
      developer.log(
        'Profile load failed.',
        name: 'TR.Profile',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<UserProfileModel> createProfile({
    required UserProfileModel profile,
  }) async {
    final userId = profile.id;

    final row = await _tablesDb.createRow(
      databaseId: AppwriteProfileConstants.databaseId,
      tableId: AppwriteProfileConstants.collectionId,
      rowId: userId,
      data: profile.toMap(),
      permissions: [
        Permission.read(Role.user(userId)),
        Permission.update(Role.user(userId)),
        Permission.delete(Role.user(userId)),
      ],
    );

    return UserProfileModel.fromMap({
      'id': row.$id,
      ...row.data,
    });
  }

  Future<UserProfileModel> updateProfile({
    required UserProfileModel profile,
  }) async {
    final row = await _tablesDb.updateRow(
      databaseId: AppwriteProfileConstants.databaseId,
      tableId: AppwriteProfileConstants.collectionId,
      rowId: profile.id,
      data: profile.toMap(),
    );

    return UserProfileModel.fromMap({
      'id': row.$id,
      ...row.data,
    });
  }
}
