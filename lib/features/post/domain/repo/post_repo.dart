import 'package:devgram/features/post/domain/entities/post.dart';

abstract class PostRepo {
  Future<void> createPost(Post post);

  Future<List<Post>> getPostsByUserId(String userId);

  Future<List<Post>> getAllPosts();

  Future<void> deletePost(String postId);

  Future<void> likePost(String postId, String userId);

  Stream<List<Post>> postsStream();
}
