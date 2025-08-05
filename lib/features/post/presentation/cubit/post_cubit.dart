import 'package:devgram/features/post/domain/entities/post.dart';
import 'package:devgram/features/post/domain/repo/post_repo.dart';
import 'package:devgram/features/post/presentation/cubit/post_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostCubit extends Cubit<PostStates> {
  final PostRepo postRepo;
  PostCubit(this.postRepo) : super(PostInitial());

  Future<void> createPost(Post post) async {
    try {
      emit(PostLoading());
      postRepo.createPost(post);
      print('post : ${post.text}');
      fetchAllPosts();
    } catch (error) {
      emit(PostError(error.toString()));
    }
  }

  Future<void> fetchPostsByUserId(String userId) async {
    try {
      emit(PostLoading());
      final posts = await postRepo.getPostsByUserId(userId);
      //print('posts: $posts');
      if (posts.isNotEmpty) {
        emit(PostLoaded(posts));
      } else {
        emit(PostError("No posts found for this user"));
      }
    } catch (error) {
      emit(PostError(error.toString()));
    }
  }

  Future<List<Post>> fetchAllPosts() async {
    try {
      emit(PostLoading());
      final posts = await postRepo.getAllPosts();
      if (posts.isNotEmpty) {
        emit(PostLoaded(posts));
      } else {
        emit(PostError("No posts available"));
      }
      return posts;
    } catch (error) {
      emit(PostError(error.toString()));
      return [];
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      emit(PostLoading());
      await postRepo.deletePost(postId);
      fetchAllPosts();
      // Optionally, you can emit a state to indicate success
    } catch (error) {
      emit(PostError(error.toString()));
    }
  }

  Future<void> toggleLikePost(Post post, String userId) async {
    try {
      //emit(PostLoading());
      await postRepo.likePost(post.id, userId);
      //fetchAllPosts();
      // Optionally, you can emit a state to indicate success
    } catch (error) {
      emit(PostError(error.toString()));
    }
  }

  Stream<List<Post>> get postsStream {
    return postRepo.postsStream();
  }
}
