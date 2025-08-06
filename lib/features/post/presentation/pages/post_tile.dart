import 'package:cached_network_image/cached_network_image.dart';
import 'package:devgram/features/auth/domain/entities/app_user.dart';
import 'package:devgram/features/post/domain/entities/post.dart';
import 'package:devgram/features/post/presentation/cubit/post_cubit.dart';
import 'package:devgram/features/profile/presentation/components/profile_avatar.dart';
import 'package:devgram/features/profile/presentation/cubit/Profilepic_cubit.dart';
import 'package:devgram/features/profile/presentation/cubit/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class PostTile extends StatefulWidget {
  final Post? post;
  final AppUser currentUser;
  final VoidCallback onDelete;
  const PostTile({
    super.key,
    this.post,
    required this.currentUser,
    required this.onDelete,
  });

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  late final ProfilePicCubit _profilePicCubit;

  bool isLikedBy() {
    return widget.post!.likeBy?.contains(widget.currentUser.uid) == true
        ? true
        : false;
  }

  void toggleLike() {
    final isLiked =
        widget.post?.likeBy?.contains(widget.currentUser.uid) ?? false;
    setState(() {
      if (isLiked) {
        widget.post?.likeBy?.remove(widget.currentUser.uid);
      } else {
        widget.post?.likeBy?.add(widget.currentUser.uid);
      }
    });
    final postCubit = context.read<PostCubit>();
    postCubit.toggleLikePost(widget.post!, widget.currentUser.uid).catchError((
      error,
    ) {
      setState(() {
        if (isLiked) {
          widget.post?.likeBy?.remove(widget.currentUser.uid);
        } else {
          widget.post?.likeBy?.add(widget.currentUser.uid);
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _profilePicCubit = context.read<ProfilePicCubit>();
    _profilePicCubit.fetchUserProfilePic(widget.post!.userId);
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = widget.post?.timeStamp != null
        ? DateFormat('hh:mm a • dd MMM').format(widget.post!.timeStamp)
        : '';

    return GestureDetector(
      onDoubleTap: toggleLike,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row: Avatar + Name + Date
              Row(
                children: [
                  BlocBuilder<ProfilePicCubit, ProfileState>(
                    buildWhen: (previous, current) {
                      if (current is ProfileImageLoaded &&
                          current.userId == widget.post!.userId) {
                        return true;
                      }
                      return false;
                    },
                    builder: (context, state) {
                      final imageUrl =
                          (state is ProfileImageLoaded &&
                              state.userId == widget.post!.userId)
                          ? state.profilePic
                          : '';
                      return ProfileAvatar(
                        name: widget.post?.userName ?? '',
                        imageUrl: imageUrl,
                        radius: 20,
                      );
                    },
                  ),

                  const SizedBox(width: 10),
                  Text(
                    widget.post?.userName ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  Text(
                    formattedDate,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              if (widget.post?.imageUrl != null &&
                  widget.post?.imageUrl?.isNotEmpty == true)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: widget.post!.imageUrl ?? '',
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.broken_image,
                      size: 80,
                      color: Colors.grey,
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              // Message
              const SizedBox(height: 12),
              Text(
                widget.post?.text ?? '',
                style: const TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 12),

              // Row: Like + Delete
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    spacing: 5,
                    children: [
                      Icon(
                        isLikedBy() == true
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: isLikedBy() == true ? Colors.red : Colors.grey,
                      ),
                      Text((widget.post?.likeBy?.length ?? 0).toString()),
                    ],
                  ),
                  if (widget.post?.userId == widget.currentUser.uid)
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: widget.onDelete,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
