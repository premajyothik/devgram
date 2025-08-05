import 'package:devgram/features/profile/domain/entities/profile_user.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final ProfileUser profileUser;
  ProfileLoaded(this.profileUser);
}

class ProfileImageLoaded extends ProfileState {
  final String userId;
  final String profilePic;
  ProfileImageLoaded(this.userId, this.profilePic);
}

class ProfileImageLoading extends ProfileState {}

class ProfileError extends ProfileState {
  final String errorMessage;
  ProfileError(this.errorMessage);
}
