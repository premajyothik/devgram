import 'package:flutter/widgets.dart';

class AppUser {
  final String uid;
  final String email;
  final String name;

  AppUser({required this.uid, required this.email, required this.name});

  // convert appuser to json
  Map<String, dynamic> toJson() {
    return {'uid': uid, 'email': email, 'name': name};
  }

  // Convert json to appuser
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
    );
  }
}
