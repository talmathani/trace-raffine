import '../../../../domain/entities/user_profile.dart';
import '../../../../domain/repositories/user_profile_repository.dart';
import '../datasources/appwrite_user_profile_datasource.dart';
import '../models/user_profile_model.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  UserProfileRepositoryImpl(this._datasource);

  final AppwriteUserProfileDatasource _datasource;

  @override
  Future<UserProfile?> getCurrentProfile() async {
    return null;
  }

  @override
  Future<UserProfile> createProfile({required UserProfile profile}) async {
    final model = UserProfileModel(
      id: profile.id,
      email: profile.email,
      displayName: profile.displayName,
      role: profile.role,
      createdAt: profile.createdAt,
    );

    return _datasource.createProfile(profile: model);
  }

  @override
  Future<UserProfile> updateProfile({required UserProfile profile}) async {
    final model = UserProfileModel(
      id: profile.id,
      email: profile.email,
      displayName: profile.displayName,
      role: profile.role,
      createdAt: profile.createdAt,
    );

    return _datasource.updateProfile(profile: model);
  }
}
