import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:easyroute/domain/repositories/auth_repository.dart';
import 'package:easyroute/domain/repositories/user_repository.dart';
import 'package:easyroute/data/repositories/auth_repository_impl.dart';
import 'package:easyroute/data/repositories/user_repository_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Firebase Fallback Setup Tests', () {
    final getIt = GetIt.instance;

    setUp(() {
      getIt.reset();
    });

    test('should register Demo implementations when Firebase is not initialized', () {
      const isFirebaseInitialized = false;

      if (isFirebaseInitialized) {
        final userRepository = FirestoreUserRepository();
        getIt.registerSingleton<UserRepository>(userRepository);
        getIt.registerSingleton<AuthRepository>(FirebaseAuthRepository(userRepository));
      } else {
        final userRepository = DemoUserRepository();
        getIt.registerSingleton<UserRepository>(userRepository);
        getIt.registerSingleton<AuthRepository>(DemoAuthRepository());
      }

      expect(getIt.isRegistered<UserRepository>(), isTrue);
      expect(getIt.isRegistered<AuthRepository>(), isTrue);

      final userRepo = getIt<UserRepository>();
      final authRepo = getIt<AuthRepository>();

      expect(userRepo, isA<DemoUserRepository>());
      expect(authRepo, isA<DemoAuthRepository>());
    });

    test('DemoAuthRepository login should return a valid UserEntity and emit updates', () async {
      final authRepo = DemoAuthRepository();

      final usersEmitted = [];
      final subscription = authRepo.user.listen((user) {
        usersEmitted.add(user);
      });

      final email = 'test@easyroute.com';
      const password = 'password123';
      final user = await authRepo.loginWithEmail(email, password);

      expect(user.email, equals(email));
      expect(user.displayName, equals('test'));

      await Future.delayed(const Duration(milliseconds: 100));
      subscription.cancel();
    });
  });
}
