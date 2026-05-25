import 'dart:convert';
import 'package:crypto/crypto.dart';

const String SALT = 'your-secure-salt-change-me';

String hashPassword(String password) {
  // Ajout d'un sel et plusieurs itérations pour plus de sécurité
  final bytes = utf8.encode(password + SALT);
  final digest = sha256.convert(bytes);
  return sha256.convert(utf8.encode(digest.toString() + SALT)).toString();
}

bool verifyPassword(String password, String storedHash) {
  return hashPassword(password) == storedHash;
}
