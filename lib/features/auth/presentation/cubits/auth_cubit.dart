import 'package:devgram/features/auth/domain/entities/app_user.dart';
import 'package:devgram/features/auth/domain/repository/auth_repo.dart';
import 'package:devgram/features/auth/presentation/cubits/auth_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthStates> {
  final AuthRepo authRepo;
  AppUser? _currentUser;
  AuthCubit(this.authRepo) : super(AuthInitial());

  AppUser get currentUser => _currentUser!;
  void checkAuthentication() async {
    if (_currentUser != null) {
      emit(Authenticated(_currentUser!));
      return;
    }
    try {
      final user = await authRepo.getCurrentUser();
      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (error) {
      emit(AuthError(error.toString()));
    }
  }

  //login with email and password
  Future<void> logIn(String email, String password) async {
    try {
      emit(AuthLoading());
      final user = await authRepo.logInWithEmailAndPassword(email, password);
      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (error) {
      emit(AuthError(error.toString()));
      emit(Unauthenticated());
    }
  }

  // Sign up with email and password
  Future<void> signUp(String email, String name, String password) async {
    try {
      emit(AuthLoading());
      final user = await authRepo.signUpWithEmailAndPassword(
        email,
        name,
        password,
      );
      if (user != null) {
        // print(user.name);
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (error) {
      print(error);
      emit(AuthError(error.toString()));
      emit(Unauthenticated());
    }
  }

  // Logout
  Future<void> logout() async {
    await authRepo.logout();
    _currentUser = null;
    emit(Unauthenticated());
  }
}
