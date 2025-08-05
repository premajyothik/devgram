import 'dart:io';
import 'package:devgram/features/auth/domain/entities/app_user.dart';
import 'package:devgram/features/auth/presentation/components/custom_textfiled.dart';
import 'package:devgram/features/auth/presentation/components/my_button.dart';
import 'package:devgram/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:devgram/features/post/domain/entities/post.dart';
import 'package:devgram/features/post/presentation/cubit/post_cubit.dart';
import 'package:devgram/features/post/presentation/cubit/post_states.dart';
import 'package:devgram/utils/imgBB_uploader.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UploadPostPage extends StatefulWidget {
  final Function(String message, String? imageUrl) onPostCreated;

  const UploadPostPage({Key? key, required this.onPostCreated})
    : super(key: key);

  @override
  State<UploadPostPage> createState() => _UploadPostPageState();
}

class _UploadPostPageState extends State<UploadPostPage> {
  final TextEditingController _messageController = TextEditingController();
  PlatformFile? imagePickedFile;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        imagePickedFile = result.files.first;
        print(imagePickedFile?.path.toString());
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No image selected')));
    }
  }

  Future<void> _submitPost() async {
    final message = _messageController.text.trim();

    if (message.isEmpty && imagePickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter text or pick an image.")),
      );
      return;
    }

    setState(() => _isUploading = true);

    String? imageUrl;

    if (imagePickedFile != null) {
      final uploader = ImgBBUploader();
      imageUrl = await uploader.uploadImageFile(imagePickedFile!.path ?? '');
    }

    widget.onPostCreated(message, imageUrl);

    setState(() {
      _isUploading = false;
      _messageController.clear();
      imagePickedFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _messageController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Write something...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            if (imagePickedFile != null)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(imagePickedFile!.path!),
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        setState(() => imagePickedFile = null);
                      },
                    ),
                  ),
                ],
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text("Add Image"),
                ),
                ElevatedButton(
                  onPressed: _isUploading ? null : _submitPost,
                  child: _isUploading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Post"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
