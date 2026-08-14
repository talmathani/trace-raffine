import '../../../../core/appwrite/appwrite_database_service.dart';
import '../models/user_profile_model.dart';

class AppwriteUserProfileDatasource {
  AppwriteUserProfileDatasource(this._databaseService);

  final AppwriteDatabaseService _databaseService;

  Future<UserProfileModel?> getCurrentProfile({required String userId}) async {
    _databaseService;

    return null;
  }

  Future<UserProfileModel> createProfile({
    required UserProfileModel profile,
  }) async {
    _databaseService;

    throw UnimplementedError();
  }

  Future<UserProfileModel> updateProfile({
    required UserProfileModel profile,
  }) async {
    _databaseService;

    throw UnimplementedError();
  }
}
