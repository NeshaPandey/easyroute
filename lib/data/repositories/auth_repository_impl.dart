import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/entities/route_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/user_repository.dart';

// ─── Demo Auth Repository Implementation ──────────────────────────────────────

class DemoAuthRepository implements AuthRepository {
  final _controller = StreamController<UserEntity?>.broadcast();
  UserEntity? _currentUser;

  DemoAuthRepository() {
    _controller.add(null);
  }

  @override
  Stream<UserEntity?> get user => _controller.stream;

  @override
  Future<UserEntity?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<UserEntity> loginWithEmail(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _currentUser = UserEntity(
      id: 'demo_user_001',
      email: email,
      displayName: email.split('@')[0],
      preferences: const UserPreferences(),
    );
    _controller.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<UserEntity> signUpWithEmail(String email, String password, String name) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _currentUser = UserEntity(
      id: 'demo_user_001',
      email: email,
      displayName: name.isNotEmpty ? name : email.split('@')[0],
      preferences: const UserPreferences(),
    );
    _controller.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<UserEntity> loginWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 800));
    _currentUser = const UserEntity(
      id: 'demo_user_google_001',
      email: 'google.user@gmail.com',
      displayName: 'Google User',
      preferences: UserPreferences(),
    );
    _controller.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
    _controller.add(null);
  }
}

// ─── Firebase Auth Repository Implementation ──────────────────────────────────

class FirebaseAuthRepository implements AuthRepository {
  final fb.FirebaseAuth _firebaseAuth = fb.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final UserRepository _userRepository;

  FirebaseAuthRepository(this._userRepository);

  @override
  Stream<UserEntity?> get user {
    return _firebaseAuth.authStateChanges().asyncMap((fbUser) async {
      if (fbUser == null) return null;
      try {
        return await _userRepository.getUser(fbUser.uid);
      } catch (_) {
        final newUser = UserEntity(
          id: fbUser.uid,
          email: fbUser.email ?? '',
          displayName: fbUser.displayName ?? fbUser.email?.split('@')[0] ?? 'EasyRoute User',
          photoUrl: fbUser.photoURL,
          preferences: const UserPreferences(),
        );
        await _userRepository.saveUser(newUser);
        return newUser;
      }
    });
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final fbUser = _firebaseAuth.currentUser;
    if (fbUser == null) return null;
    try {
      return await _userRepository.getUser(fbUser.uid);
    } catch (_) {
      return UserEntity(
        id: fbUser.uid,
        email: fbUser.email ?? '',
        displayName: fbUser.displayName ?? fbUser.email?.split('@')[0] ?? 'EasyRoute User',
        photoUrl: fbUser.photoURL,
        preferences: const UserPreferences(),
      );
    }
  }

  @override
  Future<UserEntity> loginWithEmail(String email, String password) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final fbUser = credential.user!;
    try {
      return await _userRepository.getUser(fbUser.uid);
    } catch (_) {
      final newUser = UserEntity(
        id: fbUser.uid,
        email: fbUser.email ?? '',
        displayName: fbUser.displayName ?? fbUser.email?.split('@')[0] ?? 'EasyRoute User',
        photoUrl: fbUser.photoURL,
        preferences: const UserPreferences(),
      );
      await _userRepository.saveUser(newUser);
      return newUser;
    }
  }

  @override
  Future<UserEntity> signUpWithEmail(String email, String password, String name) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final fbUser = credential.user!;
    await fbUser.updateDisplayName(name);
    
    final newUser = UserEntity(
      id: fbUser.uid,
      email: fbUser.email ?? '',
      displayName: name.isNotEmpty ? name : (fbUser.email?.split('@')[0] ?? 'EasyRoute User'),
      preferences: const UserPreferences(),
    );
    await _userRepository.saveUser(newUser);
    return newUser;
  }

  @override
  Future<UserEntity> loginWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google sign in aborted by user.');
    }
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final credential = fb.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final authResult = await _firebaseAuth.signInWithCredential(credential);
    final fbUser = authResult.user!;
    try {
      return await _userRepository.getUser(fbUser.uid);
    } catch (_) {
      final newUser = UserEntity(
        id: fbUser.uid,
        email: fbUser.email ?? '',
        displayName: fbUser.displayName ?? fbUser.email?.split('@')[0] ?? 'EasyRoute User',
        photoUrl: fbUser.photoURL,
        preferences: const UserPreferences(),
      );
      await _userRepository.saveUser(newUser);
      return newUser;
    }
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut().catchError((_) {});
  }
}
