import '../entities/user_profile.dart';

abstract class UserProfileRepository {
  Future<UserProfile?> getCurrentProfile({required String userId});

  Future<UserProfile> createProfile({required UserProfile profile});

  Future<UserProfile> updateProfile({required UserProfile profile});

  Future<UserProfile> touchPresence({required String userId});

  Future<void> clearPresence({required String userId});
}
