import 'package:devgram/features/auth/domain/entities/app_user.dart';
import 'package:devgram/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:devgram/features/post/domain/entities/post.dart';
import 'package:devgram/features/post/presentation/cubit/post_cubit.dart';
import 'package:devgram/utils/avatar_color_util.dart';
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
  bool isLikedBy() {
    // final currentUser = context.read<AuthCubit>().currentUser;
    print(widget.post!.likeBy?.contains(widget.currentUser.uid));
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
  Widget build(BuildContext context) {
    final formattedDate = widget.post?.timeStamp != null
        ? DateFormat('hh:mm a • dd MMM').format(widget.post!.timeStamp)
        : '';

    return Card(
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
                CircleAvatar(
                  radius: 20,
                  backgroundColor: generateColorFromUsername(
                    widget.post?.userName ?? '',
                  ),
                  child: Text(
                    (widget.post?.userName?.isEmpty == true)
                        ? ''
                        : widget.post?.userName?[0].toUpperCase() ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.post?.userName ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Flexible(
                  child: Text(
                    formattedDate,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Message
            Text(widget.post?.text ?? '', style: const TextStyle(fontSize: 16)),

            const SizedBox(height: 12),

            // Row: Like + Delete
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isLikedBy() == true
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: isLikedBy() == true ? Colors.red : Colors.grey,
                      ),
                      onPressed: toggleLike,
                    ),
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
    );
  }
}
