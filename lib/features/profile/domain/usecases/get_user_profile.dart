import '../../../../domain/entities/user_profile.dart';
import '../../../../domain/repositories/user_profile_repository.dart';

class GetUserProfile {
  const GetUserProfile(this.repository);

  final UserProfileRepository repository;

  Future<UserProfile?> call() {
    return repository.getCurrentProfile();
  }
}
