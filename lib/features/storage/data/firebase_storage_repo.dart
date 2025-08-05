import 'dart:io';

import 'package:devgram/features/storage/domain/repo/storage_repo.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageRepo implements StorageRepo {
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  @override
  Future<String> uploadImageFromMobile(String filePath, String fileName) async {
    // Implement the logic to upload an image from mobile
    // This is a placeholder implementation
    // You would typically use Firebase Storage SDK here
    return uploadFile(filePath, fileName, "Profile_images");
  }

  Future<String> uploadFile(
    String filePath,
    String fileName,
    String folder,
  ) async {
    try {
      final ref = firebaseStorage.ref().child('images/$fileName');
      print('ref : ' + ref.toString());
      final uploadTask = ref.putFile(File(filePath));
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (error) {
      throw Exception('Failed to upload image: $error');
    }
  }
}
