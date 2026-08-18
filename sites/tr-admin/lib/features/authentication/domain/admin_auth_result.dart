final class AdminAuthResult {
  const AdminAuthResult({
    required this.isAuthenticated,
    this.userId,
    this.email,
    this.name,
    this.errorMessage,
  });

  final bool isAuthenticated;
  final String? userId;
  final String? email;
  final String? name;
  final String? errorMessage;

  const AdminAuthResult.authenticated({
    required String userId,
    required String email,
    required String name,
  }) : this(
          isAuthenticated: true,
          userId: userId,
          email: email,
          name: name,
        );

  const AdminAuthResult.unauthenticated({
    String? errorMessage,
  }) : this(
          isAuthenticated: false,
          errorMessage: errorMessage,
        );
}
