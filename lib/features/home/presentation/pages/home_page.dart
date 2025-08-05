import 'package:devgram/features/auth/domain/entities/app_user.dart';
import 'package:devgram/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:devgram/features/post/domain/entities/post.dart';
import 'package:devgram/features/post/presentation/cubit/post_cubit.dart';
import 'package:devgram/features/post/presentation/cubit/post_states.dart';
import 'package:devgram/features/post/presentation/pages/post_tile.dart';
import 'package:devgram/features/post/presentation/pages/upload_post_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final postCubit = context.read<PostCubit>();
  late final authCubit = context.read<AuthCubit>();

  AppUser currentUser() {
    return authCubit.currentUser;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchAllPosts();
  }

  void fetchAllPosts() {
    postCubit.fetchAllPosts();
  }

  void deletePost(String postId) {
    postCubit.deletePost(postId);
  }

  void showDeleteOptions(String postId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Post'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () {
              print('postId :$postId');
              postCubit.deletePost(postId);
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        foregroundColor: Colors.grey[900],
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline),
            onPressed: () {
              // Handle notifications
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: UploadPostPage(
                        onPostCreated: (message, imageUrl) {
                          final user = currentUser();
                          print('post imageurl : $imageUrl ');
                          final newPost = Post(
                            id: DateTime.now().microsecondsSinceEpoch
                                .toString(),
                            userId: user.uid,
                            userName: user.name,
                            timeStamp: DateTime.now(),
                            text: message,
                            imageUrl: imageUrl,
                          );
                          postCubit.createPost(newPost);
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Post>>(
        stream: postCubit.postsStream, // Your stream providing posts
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final allPosts = snapshot.data ?? [];
          if (allPosts.isEmpty) {
            return const Center(child: Text('No Post Available'));
          }
          return ListView.builder(
            itemCount: allPosts.length,
            itemBuilder: (context, index) {
              final post = allPosts[index];
              return PostTile(
                post: post,
                currentUser: currentUser(),
                onDelete: () {
                  showDeleteOptions(post.id);
                },
              );
            },
          );
        },
      ),
    );
  }
}
