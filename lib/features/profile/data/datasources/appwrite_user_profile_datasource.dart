import 'package:appwrite/appwrite.dart';

import '../../../../core/appwrite/appwrite_database_service.dart';
import '../../../../core/appwrite/appwrite_profile_constants.dart';
import '../models/user_profile_model.dart';

class AppwriteUserProfileDatasource {
  AppwriteUserProfileDatasource(this._databaseService);

  final AppwriteDatabaseService _databaseService;

  Future<UserProfileModel?> getCurrentProfile({required String userId}) async {
    try {
      final document = await _databaseService.getDocument(
        collectionId: AppwriteProfileConstants.collectionId,
        documentId: userId,
      );

      return UserProfileModel.fromMap({'id': document.$id, ...document.data});
    } catch (error, stackTrace) {
      print('PROFILE LOAD ERROR: $error');
      print(stackTrace);
      return null;
    }
  }

  Future<UserProfileModel> createProfile({
    required UserProfileModel profile,
  }) async {
    final userId = profile.id;

    final document = await _databaseService.createDocument(
      collectionId: AppwriteProfileConstants.collectionId,
      documentId: userId,
      data: profile.toMap(),
      permissions: [
        Permission.read(Role.user(userId)),
        Permission.update(Role.user(userId)),
        Permission.delete(Role.user(userId)),
      ],
    );

    return UserProfileModel.fromMap({'id': document.$id, ...document.data});
  }

  Future<UserProfileModel> updateProfile({
    required UserProfileModel profile,
  }) async {
    await _databaseService.updateDocument(
      collectionId: AppwriteProfileConstants.collectionId,
      documentId: profile.id,
      data: profile.toMap(),
    );

    return profile;
  }
}
