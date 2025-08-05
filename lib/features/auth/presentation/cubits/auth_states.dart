import 'package:devgram/features/auth/domain/entities/app_user.dart';

abstract class AuthStates {}

// intial
class AuthInitial extends AuthStates {}

// loading..
class AuthLoading extends AuthStates {}

//authenticated
class Authenticated extends AuthStates {
  final AppUser appUser;
  Authenticated(this.appUser);
}

// unauthenticated
class Unauthenticated extends AuthStates {}

// error
class AuthError extends AuthStates {
  final String errorMessage;
  AuthError(this.errorMessage);
}
