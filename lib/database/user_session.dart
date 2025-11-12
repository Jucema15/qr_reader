class UserSession {
  static String? _username;

  static String? get username => _username;
  static void setUsername(String username) => _username = username;
  static void clear() => _username = null;
}