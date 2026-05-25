class SecurityPolicy {
  SecurityPolicy._();

  static const int minLength = 8;

  static const List<String> rules = [
    'Au moins 8 caractères',
    'Une lettre majuscule (A-Z)',
    'Une lettre minuscule (a-z)',
    'Un chiffre (0-9)',
    'Un caractère spécial (!@#\$%^&*…)',
  ];

  static String? validate(String password) {
    if (password.length < minLength) {
      return 'Le mot de passe doit contenir au moins $minLength caractères.';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Ajoutez au moins une lettre majuscule.';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Ajoutez au moins une lettre minuscule.';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Ajoutez au moins un chiffre.';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\/]').hasMatch(password)) {
      return 'Ajoutez au moins un caractère spécial.';
    }
    return null;
  }

  static double strengthScore(String password) {
    var score = 0.0;
    if (password.length >= minLength) score += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(password)) score += 0.2;
    if (RegExp(r'[a-z]').hasMatch(password)) score += 0.2;
    if (RegExp(r'[0-9]').hasMatch(password)) score += 0.2;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\/]').hasMatch(password)) score += 0.15;
    if (password.length >= 12) score += 0.1;
    return score.clamp(0.0, 1.0);
  }
}
