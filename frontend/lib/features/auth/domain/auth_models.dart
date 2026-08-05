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

class RegistrationResult {
  const RegistrationResult({
    required this.verificationRequired,
    required this.emailMasked,
  });

  final bool verificationRequired;
  final String emailMasked;

  factory RegistrationResult.fromJson(Map<String, dynamic> json) {
    return RegistrationResult(
      verificationRequired: json['verification_required'] as bool? ?? true,
      emailMasked: json['email_masked'] as String? ?? '',
    );
  }
}

class AccountUsage {
  const AccountUsage({
    required this.aiUnitsRemainingToday,
    required this.storageBytesUsed,
    required this.storageBytesLimit,
  });

  final int? aiUnitsRemainingToday;
  final int storageBytesUsed;
  final int storageBytesLimit;

  factory AccountUsage.fromJson(Map<String, dynamic> json) {
    final ai = json['ai'];
    final userDaily = ai is Map ? ai['user_daily'] : null;
    final storage = json['storage'];
    final dailyUsed = _readInt(userDaily, const ['used']);
    final dailyLimit = _readInt(userDaily, const ['limit']);
    return AccountUsage(
      aiUnitsRemainingToday:
          _readInt(ai, const ['remaining_today', 'units_remaining_today']) ??
          _readInt(json, const ['ai_units_remaining_today']) ??
          (dailyUsed != null && dailyLimit != null
              ? (dailyLimit - dailyUsed).clamp(0, dailyLimit)
              : null),
      storageBytesUsed:
          _readInt(storage, const ['used_bytes', 'bytes_used']) ??
          _readInt(json, const ['storage_bytes_used']) ??
          0,
      storageBytesLimit:
          _readInt(storage, const ['limit_bytes', 'bytes_limit']) ??
          _readInt(json, const ['storage_bytes_limit']) ??
          0,
    );
  }
}

int? _readInt(Object? value, List<String> keys) {
  if (value is! Map) return null;
  for (final key in keys) {
    final candidate = value[key];
    if (candidate is int) return candidate;
    if (candidate is num) return candidate.toInt();
  }
  return null;
}

class AuthState {
  const AuthState._({this.user});

  const AuthState.unauthenticated() : this._();

  const AuthState.authenticated(AppUser user) : this._(user: user);

  final AppUser? user;

  bool get isAuthenticated => user != null;
}
