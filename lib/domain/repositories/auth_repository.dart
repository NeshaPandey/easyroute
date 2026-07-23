import '../entities/route_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> get user;
  Future<UserEntity?> getCurrentUser();
  Future<UserEntity> loginWithEmail(String email, String password);
  Future<UserEntity> signUpWithEmail(String email, String password, String name);
  Future<UserEntity> loginWithGoogle();
  Future<void> logout();
}
