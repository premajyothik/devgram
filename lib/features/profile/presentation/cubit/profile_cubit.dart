import 'package:devgram/features/profile/domain/repo/profile_repo.dart';
import 'package:devgram/features/profile/presentation/cubit/profile_state.dart';
import 'package:devgram/features/storage/domain/repo/storage_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo profileRepo;
  final StorageRepo storageRepo;
  ProfileCubit(this.profileRepo, this.storageRepo) : super(ProfileInitial());

  Future<void> fetchUserProfile(String userId) async {
    try {
      emit(ProfileLoading());
      final profile = await profileRepo.fetchUserProfile(userId);
      if (profile != null) {
        emit(ProfileLoaded(profile));
      } else {
        emit(ProfileError("Profile not found"));
      }
    } catch (error) {
      emit(ProfileError(error.toString()));
    }
  }

  Future<void> updateProfile(
    String uid,
    String? newBio,
    String imagePath,
  ) async {
    try {
      print('enterd updateProfile');
      emit(ProfileLoading());
      final user = await profileRepo.fetchUserProfile(uid);
      if (user == null) {
        emit(ProfileError("Failed to fetch user profile"));
        return;
      }
      print('imagePath:' + imagePath);

      if (imagePath.isNotEmpty) {
        // Upload the new profile picture

        final uploadedImageUrl = await storageRepo.uploadImageFromMobile(
          imagePath,
          'profile_$uid.jpg',
        );
        if (uploadedImageUrl.isEmpty) {
          print('uploadedImageUrl:empty');
          emit(ProfileError("Failed to upload profile picture"));
          return;
        }
        imagePath = uploadedImageUrl;
        print('uploadedImageUrl:' + uploadedImageUrl);
      }
      print('uploadedImageUrl nil:');
      final updatedProfile = user.copyWith(
        newBio: newBio,
        newProfilePictureUrl: imagePath,
      );
      await profileRepo.updateProfile(updatedProfile);
      final profileUser = await profileRepo.fetchUserProfile(uid);
      if (profileUser != null) {
        emit(ProfileLoaded(profileUser));
      }
    } catch (error) {
      emit(ProfileError(error.toString()));
    }
  }
}
