import '../entities/user_profile.dart';

abstract class UserProfileRepository {
  Future<UserProfile?> getCurrentProfile();

  Future<UserProfile> createProfile({required UserProfile profile});

  Future<UserProfile> updateProfile({required UserProfile profile});
}
