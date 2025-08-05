import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devgram/features/profile/domain/entities/profile_user.dart';
import 'package:devgram/features/profile/domain/repo/profile_repo.dart';
import 'package:devgram/features/profile/presentation/cubit/profile_state.dart';

class FirebaseProfileRepo implements ProfileRepo {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  @override
  Future<ProfileUser?> fetchUserProfile(String userId) async {
    try {
      final userDoc = await firebaseFirestore
          .collection("users")
          .doc(userId)
          .get();
      if (userDoc.exists) {
        final user = userDoc.data();
        if (user != null) {
          return ProfileUser(
            uid: userId,
            email: user['email'] ?? '',
            name: user['name'] ?? '',
            bio: user['bio'] ?? '',
            profilePictureUrl: user['profilePictureUrl'] ?? '',
          );
        } else {
          return null; // User data is null
        }
      } else {
        return null; // User not found
      }
    } catch (error) {
      // Handle exceptions
      throw Exception('Failed to fetch user profile: $error');
    }
  }

  @override
  Future<void> updateProfile(ProfileUser updateProfile) async {
    try {
      await firebaseFirestore
          .collection("users")
          .doc(updateProfile.uid)
          .update(updateProfile.toJson());
    } catch (error) {
      // Handle exceptions
      throw Exception('Failed to update profile: $error');
    }
  }

  @override
  Future<String?> fetchUserProfilePic(String userId) async {
    // TODO: implement fetchUserProfilePic
    try {
      final userDoc = await firebaseFirestore
          .collection("users")
          .doc(userId)
          .get();
      if (userDoc.exists) {
        final user = userDoc.data();
        return user?['profilePictureUrl'] ?? '';
      }
      return '';
    } catch (error) {
      // Handle exceptions
      throw Exception('Failed to get profile pic: $error');
    }
    // Ensure a non-nullable String is always returned
  }
}
