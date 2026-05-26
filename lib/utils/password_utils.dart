import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

String hashPassword(String password) {
  final saltBytes = List<int>.generate(16, (_) => Random.secure().nextInt(256));
  final salt = base64Url.encode(saltBytes);
  final digest = sha256.convert(utf8.encode('$salt:$password')).toString();
  return 'sha256\$$salt\$$digest';
}

bool verifyPassword(String password, String storedHash) {
  final parts = storedHash.split(r'$');
  if (parts.length == 3 && parts[0] == 'sha256') {
    final salt = parts[1];
    final digest = sha256.convert(utf8.encode('$salt:$password')).toString();
    return digest == parts[2];
  }
  return sha256.convert(utf8.encode(password)).toString() == storedHash;
}
