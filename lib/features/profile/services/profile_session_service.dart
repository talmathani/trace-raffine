import '../../../domain/entities/user_profile.dart';
import '../../../domain/entities/user_role.dart';
import '../../../domain/repositories/user_profile_repository.dart';
import '../../auth/data/datasources/appwrite_auth_datasource.dart';
import '../domain/usecases/get_user_profile.dart';

class ProfileSessionService {
  ProfileSessionService(
    this._authDatasource,
    this._getUserProfile,
    this._repository,
  );

  final AppwriteAuthDataSource _authDatasource;
  final GetUserProfile _getUserProfile;
  final UserProfileRepository _repository;

  Future<UserProfile?> loadCurrentProfile() async {
    final user = _authDatasource.currentUser;

    if (user == null) {
      return null;
    }

    final profile = await _getUserProfile(userId: user.$id);

    if (profile != null) {
      return profile;
    }

    final newProfile = UserProfile(
      id: user.$id,
      email: user.email,
      displayName: user.name,
      role: UserRole.customer,
      createdAt: DateTime.now(),
    );

    return _repository.createProfile(profile: newProfile);
  }
}
