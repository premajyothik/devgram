import 'package:devgram/features/auth/domain/entities/app_user.dart';
import 'package:equatable/equatable.dart';

abstract class AuthStates extends Equatable {
  @override
  List<Object?> get props => [];
}

// intial
class AuthInitial extends AuthStates {}

// loading..
class AuthLoading extends AuthStates {}

//authenticated
class Authenticated extends AuthStates {
  final AppUser appUser;
  Authenticated(this.appUser);
  @override
  List<Object?> get props => [appUser];
}

// unauthenticated
class Unauthenticated extends AuthStates {}

// error
class AuthError extends AuthStates {
  final String errorMessage;
  AuthError(this.errorMessage);
  @override
  List<Object?> get props => [errorMessage];
}
