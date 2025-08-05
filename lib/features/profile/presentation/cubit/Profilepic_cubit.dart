import 'package:devgram/features/profile/domain/repo/profile_repo.dart';
import 'package:devgram/features/profile/presentation/cubit/profile_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfilePicCubit extends Cubit<ProfileState> {
  final ProfileRepo repo;

  ProfilePicCubit(this.repo) : super(ProfileImageLoading());

  Future<void> fetchUserProfilePic(String userId) async {
    try {
      final profilePic = await repo.fetchUserProfilePic(userId);
      if (profilePic != null) {
        emit(ProfileImageLoaded(userId, profilePic));
      }
    } catch (error) {
      print(error.toString());
    }
  }
}
