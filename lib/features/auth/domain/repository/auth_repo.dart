import 'package:devgram/features/auth/domain/entities/app_user.dart';

abstract class AuthRepo {
  Future<AppUser?> logInWithEmailAndPassword(String email, String password);

  Future<AppUser?> signUpWithEmailAndPassword(
    String email,
    String name,
    String password,
  );

  Future<void> logout();

  Future<AppUser?> getCurrentUser();
}
