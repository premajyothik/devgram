import 'package:cached_network_image/cached_network_image.dart';
import 'package:devgram/features/auth/domain/entities/app_user.dart';
import 'package:devgram/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:devgram/features/post/presentation/cubit/post_cubit.dart';
import 'package:devgram/features/post/presentation/cubit/post_states.dart';
import 'package:devgram/features/post/presentation/pages/post_tile.dart';
import 'package:devgram/features/profile/presentation/components/box_bio.dart';
import 'package:devgram/features/profile/presentation/components/profile_avatar.dart';
import 'package:devgram/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:devgram/features/profile/presentation/cubit/profile_state.dart';
import 'package:devgram/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfilePage extends StatefulWidget {
  final String userId;

  const ProfilePage({super.key, required this.userId});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final authCubit = context.read<AuthCubit>();
  late final profileCubit = context.read<ProfileCubit>();
  late final postCubit = context.read<PostCubit>();

  late AppUser? user = authCubit.currentUser;

  @override
  void initState() {
    super.initState();
    profileCubit.fetchUserProfile(widget.userId);
    postCubit.fetchPostsByUserId(widget.userId);
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
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, profileState) {
        if (profileState is ProfileLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (profileState is ProfileLoaded) {
          final profileUser = profileState.profileUser;
          return Scaffold(
            appBar: AppBar(
              title: Text(profileUser.name),
              foregroundColor: Theme.of(context).colorScheme.primary,
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditProfilePage(profileUser: profileUser),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    authCubit.logout();
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                spacing: 10,
                children: [
                  const SizedBox(height: 10),
                  Center(
                    child: ProfileAvatar(
                      name: profileUser.name,
                      imageUrl: profileUser.profilePictureUrl,
                      radius: 50,
                    ),
                  ),
                  Text(profileUser.email),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          "Bio",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        BoxBio(bio: profileUser.bio),
                        const SizedBox(height: 20),
                        Text(
                          "Posts",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// ✅ BlocBuilder inside scrollable Column — safe now
                  BlocBuilder<PostCubit, PostStates>(
                    builder: (context, state) {
                      if (state is PostLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state is PostLoaded) {
                        final allPosts = state.posts;
                        if (allPosts.isEmpty) {
                          return const Center(child: Text('No Post Available'));
                        }

                        return ListView.builder(
                          shrinkWrap: true, // ✅ This is key inside a Column
                          physics:
                              const NeverScrollableScrollPhysics(), // ✅ Prevent nested scrolls
                          itemCount: allPosts.length,
                          itemBuilder: (context, index) {
                            final post = allPosts[index];
                            return PostTile(
                              post: post,
                              currentUser: user!,
                              onDelete: () {
                                showDeleteOptions(post.id);
                              },
                            );
                          },
                        );
                      } else if (state is PostError) {
                        return Center(
                          child: Text('Error: ${state.errorMessage}'),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          );
        } else if (profileState is ProfileError) {
          return Scaffold(body: Center(child: Text(profileState.errorMessage)));
        }
        return const SizedBox.shrink();
      },
    );
  }
}
