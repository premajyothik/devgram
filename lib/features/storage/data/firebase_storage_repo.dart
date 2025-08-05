import 'dart:io';

import 'package:devgram/features/storage/domain/repo/storage_repo.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageRepo implements StorageRepo {
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  @override
  Future<String> uploadImageFromMobile(
    String filePath,
    String fileName,
    String userId,
  ) async {
    // Implement the logic to upload an image from mobile
    // This is a placeholder implementation
    // You would typically use Firebase Storage SDK here
    return uploadFile(filePath, fileName, "Profile_images", userId);
  }

  Future<String> uploadFile(
    String filePath,
    String fileName,
    String folder,
    String userId,
  ) async {
    try {
      final ref = firebaseStorage.ref().child('users/$userId/$fileName');
      print('ref : ' + ref.toString());
      final uploadTask = ref.putFile(File(filePath));
      print('uploadTask : ' + uploadTask.toString());
      TaskSnapshot snapshot = await uploadTask;
      print('snapshot : ' + snapshot.toString());

      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (error) {
      throw Exception('Failed to upload image: $error');
    }
  }
}
