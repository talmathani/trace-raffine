import 'package:appwrite/models.dart' as models;

import '../../../domain/entities/user_profile.dart';
import '../../../domain/entities/user_role.dart';
import '../../../domain/repositories/user_profile_repository.dart';
import '../../../core/security/role_policy.dart';
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

  UserProfile? _currentProfile;
  UserRole? _activeRole;

  UserProfile? get currentProfile => _currentProfile;
  UserRole? get activeRole => _activeRole ?? _currentProfile?.role;

  /// يحدد الواجهة النشطة للجلسة دون تغيير الدور الأصلي في Appwrite.
  void setActiveRole(UserRole role) {
    final profile = _currentProfile;
    if (profile == null || !RolePolicy.canUseRole(
      email: profile.email,
      storedRole: profile.role,
      requestedRole: role,
    )) {
      throw StateError('Requested role is not allowed for this account.');
    }
    _activeRole = role;
  }

  Future<UserProfile?> loadCurrentProfile() async {
    final models.User? currentUser = await _authDatasource.currentUser;

    if (currentUser == null) {
      _currentProfile = null;
      _activeRole = null;
      return null;
    }

    final profile = await _getUserProfile(
      userId: currentUser.$id,
    );

    if (profile != null) {
    } else {
    }

    _currentProfile = profile;
    if (profile == null) {
      _activeRole = null;
    }
    return profile;
  }

  Future<UserProfile> ensureCurrentProfile({
    required UserRole role,
  }) async {
    final models.User? currentUser = await _authDatasource.currentUser;

    if (currentUser == null) {
      throw StateError(
        'Cannot ensure profile without an authenticated user.',
      );
    }

    final existingProfile = await _getUserProfile(
      userId: currentUser.$id,
    );

    if (existingProfile != null) {

      _currentProfile = existingProfile;
      return existingProfile;
    }

    final profile = UserProfile(
      id: currentUser.$id,
      email: currentUser.email,
      displayName: currentUser.name,
      role: role,
      createdAt: DateTime.now(),
    );

    final createdProfile = await _repository.createProfile(
      profile: profile,
    );

    _currentProfile = createdProfile;

    return createdProfile;
  }

  Future<UserProfile> createCurrentProfile({
    required UserRole role,
  }) {
    return ensureCurrentProfile(role: role);
  }

  void clear() {
    _currentProfile = null;
    _activeRole = null;
  }
}
