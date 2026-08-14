import '../../../../domain/entities/user_profile.dart';
import '../../../../domain/repositories/user_profile_repository.dart';

class UpdateUserProfile {
  const UpdateUserProfile(this.repository);

  final UserProfileRepository repository;

  Future<UserProfile> call(UserProfile profile) {
    return repository.updateProfile(profile: profile);
  }
}
