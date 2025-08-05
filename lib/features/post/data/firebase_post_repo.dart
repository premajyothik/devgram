import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devgram/features/post/domain/entities/post.dart';
import 'package:devgram/features/post/domain/repo/post_repo.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebasePostRepo implements PostRepo {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  final CollectionReference postsCollection = FirebaseFirestore.instance
      .collection('posts');

  @override
  Future<void> createPost(Post post) async {
    try {
      await postsCollection.add(post.toJson());
    } catch (error) {
      throw Exception('Failed to create post: $error');
    }
  }

  @override
  Future<List<Post>> getPostsByUserId(String userId) async {
    try {
      final snapshot = await postsCollection
          .where('userId', isEqualTo: userId)
          .get();
      return snapshot.docs
          .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch posts by user: $error');
    }
  }

  @override
  Future<List<Post>> getAllPosts() async {
    try {
      final snapshot = await postsCollection
          .orderBy('timeStamp', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch posts: $error');
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      print('delete post : $postId');
      final postDoc = await postsCollection
          .where('id', isEqualTo: postId)
          .get();
      postDoc.docs.first.reference.delete();
      print("Document successfully deleted!");
    } catch (error) {
      print('Failed to delete post : $postId');
      throw Exception('Failed to delete post: $error');
    }
  }

  @override
  Future<void> likePost(String postId, String userId) async {
    try {
      final postDoc = await postsCollection
          .where('id', isEqualTo: postId)
          .get();

      final post = postDoc.docs
          .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
          .toList()
          .first;

      //print(post.text);
      final hasLike = post.likeBy?.contains(userId) ?? false;
      if (hasLike == true) {
        //print(hasLike);
        // Unlike
        post.likeBy?.remove(userId);
      } else {
        // Like
        post.likeBy?.add(userId);
      }
      //print(post.likeBy);
      await postDoc.docs.first.reference.update({'likeBy': post.likeBy});
    } catch (error) {
      throw Exception('Failed to like post: $error');
    }
  }

  Stream<List<Post>> postsStream() {
    return postsCollection
        .orderBy('timeStamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
              .toList(),
        );
  }
}
