import 'dart:typed_data';

import 'package:devgram/features/profile/domain/repo/profile_repo.dart';
import 'package:devgram/features/profile/presentation/cubit/profile_state.dart';
import 'package:devgram/features/storage/domain/repo/storage_repo.dart';
import 'package:devgram/utils/imgBB_uploader.dart';
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
    Uint8List? imageBytes,
  ) async {
    try {
      print('enterd updateProfile');
      emit(ProfileLoading());
      final user = await profileRepo.fetchUserProfile(uid);
      if (user == null) {
        emit(ProfileError("Failed to fetch user profile"));
        return;
      }
      //print('imagePath:$imagePath');
      String? uploadedImageUrl = '';
      if (imageBytes != null) {
        uploadedImageUrl = await uploadImageToImgBB(imageBytes);
        print('uploadedImageUrl $uploadedImageUrl');
      }
      final updatedProfile = user.copyWith(
        newBio: newBio,
        newProfilePictureUrl: uploadedImageUrl,
      );
      await profileRepo.updateProfile(updatedProfile);
      final profileUser = await profileRepo.fetchUserProfile(uid);
      if (profileUser != null) {
        emit(ProfileLoaded(profileUser));
      }
    } catch (error) {
      print('error profile image $error.toString()');
      emit(ProfileError(error.toString()));
    }
  }

  Future<String?> uploadImageToImgBB(Uint8List imageBytes) async {
    return await ImgBBUploader().uploadImageFile(imageBytes);
  }
}
