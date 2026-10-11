import 'dart:async';

import 'package:flutter/material.dart';

import 'package:appwrite/models.dart' as models;

import '../../../domain/entities/user_profile.dart';
import '../../../domain/entities/user_role.dart';
import '../../../domain/repositories/user_profile_repository.dart';
import 'package:trace_raffine/core/security/role_policy.dart';
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
  Timer? _presenceTimer;
  bool _presenceStarted = false;
  late final AppLifecycleListener _lifecycleListener;

  UserProfile? get currentProfile => _currentProfile;
  UserRole? get activeRole => _activeRole ?? _currentProfile?.role;

  void initializeLifecycle() {
    _lifecycleListener = AppLifecycleListener(
      onStateChange: (state) {
        if (state == AppLifecycleState.resumed) {
          if (_currentProfile != null) {
            _startPresenceHeartbeat();
          }
        } else if (state == AppLifecycleState.inactive ||
            state == AppLifecycleState.hidden ||
            state == AppLifecycleState.paused) {
          _stopPresenceHeartbeat();
        }
      },
    );
  }

  /// يحدد الواجهة النشطة للجلسة دون تغيير الدور الأصلي في Appwrite.
  void setActiveRole(UserRole role) {
    final profile = _currentProfile;
    if (profile == null ||
        !RolePolicy.canUseRole(
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

    final profile = await _getUserProfile(userId: currentUser.$id);

    _currentProfile = profile;

    if (profile != null) {
      if ((profile.phone ?? '').trim().isEmpty &&
          currentUser.phone.trim().isNotEmpty) {
        _currentProfile = await _repository.updateProfile(
          profile: profile.copyWith(phone: currentUser.phone),
        );
      }
      _startPresenceHeartbeat();
    } else {
      _stopPresenceHeartbeat();
    }
    if (profile == null) {
      _activeRole = null;
    }
    return _currentProfile;
  }

  Future<UserProfile> ensureCurrentProfile({required UserRole role}) async {
    final models.User? currentUser = await _authDatasource.currentUser;

    if (currentUser == null) {
      throw StateError('Cannot ensure profile without an authenticated user.');
    }

    final existingProfile = await _getUserProfile(userId: currentUser.$id);

    if (existingProfile != null) {
      _currentProfile = existingProfile;
      return existingProfile;
    }

    final profile = UserProfile(
      id: currentUser.$id,
      email: currentUser.email,
      displayName: currentUser.name,
      phone: currentUser.phone,
      role: role,
      createdAt: DateTime.now(),
    );

    final createdProfile = await _repository.createProfile(profile: profile);

    _currentProfile = createdProfile;

    return createdProfile;
  }

  Future<UserProfile> createCurrentProfile({required UserRole role}) {
    return ensureCurrentProfile(role: role);
  }

  void _startPresenceHeartbeat() {
    if (_presenceStarted) return;
    _presenceStarted = true;
    _presenceTimer?.cancel();
    unawaited(_touchPresence());
    _presenceTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => unawaited(_touchPresence()),
    );
  }

  void _stopPresenceHeartbeat() {
    _presenceTimer?.cancel();
    _presenceTimer = null;
    _presenceStarted = false;
  }

  Future<void> _touchPresence() async {
    final profile = _currentProfile;
    if (profile == null) return;

    try {
      final updated = await _repository.touchPresence(userId: profile.id);
      _currentProfile = updated;
    } catch (_) {
      // Presence is advisory; a transient write failure must not log the user out.
    }
  }

  Future<void> clearPresence() async {
    final profile = _currentProfile;
    _stopPresenceHeartbeat();
    if (profile == null) return;
    try {
      await _repository.clearPresence(userId: profile.id);
    } catch (_) {
      // Logout must still complete if the presence write is unavailable.
    }
  }

  void clear() {
    _stopPresenceHeartbeat();
    _currentProfile = null;
    _activeRole = null;
  }

  void dispose() {
    _stopPresenceHeartbeat();
    _lifecycleListener.dispose();
    _currentProfile = null;
    _activeRole = null;
  }
}
