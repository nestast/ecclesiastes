import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  FirebaseService._();

  static bool _ready = false;

  static bool get isReady => _ready;

  static FirebaseAuth get auth => FirebaseAuth.instance;

  static FirebaseFirestore get firestore => FirebaseFirestore.instance;

  static Future<void> init() async {
    if (_ready) return;
    await Firebase.initializeApp();
    _ready = true;
  }

  static String emailFromIdentifiant(String identifiant) {
    final safe = identifiant
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '.')
        .replaceAll(RegExp(r'^\.+|\.+$'), '');
    return '$safe@ecclesiaste.app';
  }

  static Future<UserCredential> signInWithIdentifiant({
    required String identifiant,
    required String password,
  }) {
    return auth.signInWithEmailAndPassword(
      email: emailFromIdentifiant(identifiant),
      password: password,
    );
  }

  static Future<UserCredential> createUserWithIdentifiant({
    required String identifiant,
    required String password,
  }) {
    return auth.createUserWithEmailAndPassword(
      email: emailFromIdentifiant(identifiant),
      password: password,
    );
  }
}

