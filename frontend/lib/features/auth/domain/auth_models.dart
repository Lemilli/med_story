class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.locale,
  });

  final String id;
  final String email;
  final String fullName;
  final String locale;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      locale: json['locale'] as String? ?? 'en',
    );
  }
}

class AuthTokens {
  const AuthTokens({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['access'] as String? ?? '',
      refreshToken: json['refresh'] as String? ?? '',
    );
  }
}

class AuthSession {
  const AuthSession({required this.user, required this.tokens});

  final AppUser user;
  final AuthTokens tokens;
}

class AuthState {
  const AuthState._({this.user});

  const AuthState.unauthenticated() : this._();

  const AuthState.authenticated(AppUser user) : this._(user: user);

  final AppUser? user;

  bool get isAuthenticated => user != null;
}
