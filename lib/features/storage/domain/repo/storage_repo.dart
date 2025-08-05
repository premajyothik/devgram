abstract class StorageRepo {
  Future<String> uploadImageFromMobile(
    String filePath,
    String fileName,
    String userId,
  );
}
