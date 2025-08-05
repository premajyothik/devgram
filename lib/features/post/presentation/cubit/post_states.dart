import 'package:devgram/features/post/domain/entities/post.dart';

abstract class PostStates {}

// Initial state
class PostInitial extends PostStates {}

// Loading state
class PostLoading extends PostStates {}

// uploading state
class PostUploading extends PostStates {}

// Loaded state with a list of posts
class PostLoaded extends PostStates {
  final List<Post> posts;
  PostLoaded(this.posts);
}

// Error state with an error message
class PostError extends PostStates {
  final String errorMessage;
  PostError(this.errorMessage);
}
