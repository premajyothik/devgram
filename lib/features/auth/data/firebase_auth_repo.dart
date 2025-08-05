import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devgram/features/auth/domain/entities/app_user.dart';
import 'package:devgram/features/auth/domain/repository/auth_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthRepo implements AuthRepo {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  @override
  Future<AppUser?> logInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    //Sign in with email and password using Firebase Auth
    try {
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      if (user != null) {
        DocumentSnapshot doc = await firebaseFirestore
            .collection('users')
            .doc(user.uid)
            .get();
        return AppUser(
          uid: user.uid,
          email: user.email ?? '',
          name: doc['name'] ?? '',
        );
      } else {
        return null;
      }
    }
    // Handle errors such as user not found, wrong password, etc.
    catch (error) {
      // Handle exceptions
      throw Exception('Login failed:$error');
    }
  }

  @override
  Future<AppUser?> signUpWithEmailAndPassword(
    String email,
    String name,
    String password,
  ) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      if (user != null) {
        final appUser = AppUser(
          uid: user.uid,
          email: user.email ?? '',
          name: name,
        );
        await firebaseFirestore
            .collection("users")
            .doc(appUser.uid)
            .set(appUser.toJson());
        return appUser;
      } else {
        return null;
      }
    }
    // Handle errors such as user not found, wrong password, etc.
    catch (error) {
      // Handle exceptions
      throw Exception('Login failed:$error');
    }
  }

  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final firebaseUser = firebaseAuth.currentUser;

    if (firebaseUser == null) {
      return null;
    }
    DocumentSnapshot doc = await firebaseFirestore
        .collection("users")
        .doc(firebaseUser.uid)
        .get();

    final appUser = AppUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      name: doc['name'] ?? '',
    );
    return appUser;
  }
}
