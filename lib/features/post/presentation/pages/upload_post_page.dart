import 'package:devgram/features/auth/domain/entities/app_user.dart';
import 'package:devgram/features/auth/presentation/components/custom_textfiled.dart';
import 'package:devgram/features/auth/presentation/components/my_button.dart';
import 'package:devgram/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:devgram/features/post/domain/entities/post.dart';
import 'package:devgram/features/post/presentation/cubit/post_cubit.dart';
import 'package:devgram/features/post/presentation/cubit/post_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UploadPostPage extends StatefulWidget {
  const UploadPostPage({super.key});

  @override
  State<UploadPostPage> createState() => _UploadPostPageState();
}

class _UploadPostPageState extends State<UploadPostPage> {
  final TextEditingController postController = TextEditingController();
  AppUser? currentUser;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    // This method should be implemented to fetch the current user
    // For now, we will just set a dummy user
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
  }

  @override
  void dispose() {
    postController.dispose();
    super.dispose();
  }

  void uploadPost() {
    final postText = postController.text;
    if (postText.isNotEmpty && currentUser != null) {
      // Call your post upload service here
      final newPost = Post(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        userId: currentUser!.uid,
        userName: currentUser!.name,
        timeStamp: DateTime.now(),
        text: postText,
      );
      print(newPost.userName);
      context.read<PostCubit>().createPost(newPost);
      // After successful upload, you can navigate back or show a success message
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter some text for the post'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PostCubit, PostStates>(
      builder: (context, state) {
        if (state is PostLoading || state is PostUploading) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        // else if (state is PostError) {
        //   return Scaffold(
        //     appBar: AppBar(title: Text('Create Post')),
        //     body: Center(child: Text('Error: ${state.errorMessage}')),
        //   );
        // }
        return buildUploadPage();
      },
      listener: (context, state) {
        if (state is PostLoaded) {
          Navigator.pop(context);
        }
      },
    );
  }

  Widget buildUploadPage() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Post'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextField(
              controller: postController,
              hintText: "Add text",
              obscureText: false,
              numberOflines: 5,
            ),
            SizedBox(height: 20),
            Row(
              spacing: 20,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MyButton(onTap: uploadPost, text: 'Upload Post'),
                MyButton(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  text: 'Cancel',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
