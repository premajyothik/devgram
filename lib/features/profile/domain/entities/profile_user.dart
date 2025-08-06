import 'package:devgram/features/auth/domain/entities/app_user.dart';

class ProfileUser extends AppUser {
  final String bio;
  final String profilePictureUrl;

  ProfileUser({
    required super.uid,
    required super.name,
    required super.email,
    required this.bio,
    required this.profilePictureUrl,
  });

  ProfileUser copyWith({String? newBio, String? newProfilePictureUrl}) {
    return ProfileUser(
      uid: uid,
      name: name,
      email: email,
      bio: newBio ?? bio,
      profilePictureUrl: newProfilePictureUrl ?? profilePictureUrl,
    );
  }

  // convert map to json
  @override
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'bio': bio,
      'profilePictureUrl': profilePictureUrl,
    };
  }

  // convert json to map
  factory ProfileUser.fromJson(Map<String, dynamic> json) {
    return ProfileUser(
      uid: json['uid'],
      name: json['name'],
      email: json['email'],
      bio: json['bio'],
      profilePictureUrl: json['profilePictureUrl'],
    );
  }
}
