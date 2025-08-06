import 'package:devgram/features/profile/domain/entities/profile_user.dart';
import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final ProfileUser profileUser;
  ProfileLoaded(this.profileUser);
  @override
  List<Object?> get props => [profileUser];
}

class ProfileImageLoaded extends ProfileState {
  final String userId;
  final String profilePic;
  ProfileImageLoaded(this.userId, this.profilePic);
  @override
  List<Object?> get props => [
    {userId, profilePic},
  ];
}

class ProfileImageLoading extends ProfileState {}

class ProfileError extends ProfileState {
  final String errorMessage;
  ProfileError(this.errorMessage);
  List<Object?> get props => [errorMessage];
}
