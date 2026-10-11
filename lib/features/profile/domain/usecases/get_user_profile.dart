import '../../../../domain/entities/user_profile.dart';
import '../../../../domain/repositories/user_profile_repository.dart';

class GetUserProfile {
  const GetUserProfile(this.repository);

  final UserProfileRepository repository;

  Future<UserProfile?> call({required String userId}) {
    return repository.getCurrentProfile(userId: userId);
  }
}
