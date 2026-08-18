import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';

import '../../../core/config/appwrite_config.dart';
import '../../../core/config/appwrite_services.dart';
import '../../../core/security/admin_roles.dart';
import '../domain/admin_access.dart';
import '../domain/admin_authorization_repository.dart';

final class AppwriteAdminAuthorizationRepository
    implements AdminAuthorizationRepository {
  AppwriteAdminAuthorizationRepository({
    Teams? teams,
  }) : _teams = teams ?? AppwriteServices.teams;

  final Teams _teams;

  @override
  Future<AdminAccess> getCurrentAdminAccess({
    required String userId,
  }) async {
    try {
      debugPrint('=== ADMIN AUTHORIZATION CHECK ===');
      debugPrint('User ID: $userId');
      debugPrint('Team ID: ${AppwriteConfig.adminsTeamId}');

      final memberships = await _teams.listMemberships(
        teamId: AppwriteConfig.adminsTeamId,
        queries: [
          Query.equal('userId', userId),
        ],
        total: false,
      );

      debugPrint(
        'Memberships returned: ${memberships.memberships.length}',
      );

      final roles = <AdminRole>{};

      for (final membership in memberships.memberships) {
        debugPrint(
          'Membership roles: ${membership.roles}',
        );

        for (final roleName in membership.roles) {
          final role = AdminRole.fromString(roleName);

          if (role != null) {
            roles.add(role);
          }
        }
      }

      debugPrint('Resolved admin roles: $roles');

      return AdminAccess(
        userId: userId,
        roles: roles.toList(growable: false),
      );
    } on AppwriteException catch (error, stackTrace) {
      debugPrint('=== APPWRITE AUTHORIZATION ERROR ===');
      debugPrint('Code: ${error.code}');
      debugPrint('Type: ${error.type}');
      debugPrint('Message: ${error.message}');
      debugPrint('Response: ${error.response}');
      debugPrint('$stackTrace');
      rethrow;
    } catch (error, stackTrace) {
      debugPrint('=== UNKNOWN AUTHORIZATION ERROR ===');
      debugPrint('Error: $error');
      debugPrint('$stackTrace');
      rethrow;
    }
  }
}


