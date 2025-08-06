import 'dart:io';
import 'dart:io' as io;
import 'package:devgram/utils/imgBB_uploader.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb

class UploadPostPage extends StatefulWidget {
  final Function(String message, String? imageUrl) onPostCreated;

  const UploadPostPage({super.key, required this.onPostCreated});

  @override
  State<UploadPostPage> createState() => UploadPostPageState();
}

class UploadPostPageState extends State<UploadPostPage> {
  final TextEditingController _messageController = TextEditingController();
  PlatformFile? imagePickedFile;
  bool isUploading = false;

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      final pickedFile = result.files.first;
      Uint8List? imageBytes = pickedFile.bytes;
      if (imageBytes != null) {
        setState(() {
          imagePickedFile = pickedFile; // Save for later use if needed
        });
        print('Picked image name (web): ${pickedFile.name}');
      } else {
        // On mobile/desktop, use file path
        String? filePath = pickedFile.path;
        if (filePath != null) {
          setState(() {
            imagePickedFile = pickedFile;
          });
          print('Picked image path: $filePath');
        }
      }
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

    setState(() => isUploading = true);

    String? imageUrl;
    Uint8List? imageBytes;

    if (kIsWeb) {
      imageBytes = imagePickedFile?.bytes;
    } else {
      imageBytes = await io.File(imagePickedFile!.path ?? '').readAsBytes();
    }
    if (imageBytes != null) {
      final uploader = ImgBBUploader();
      imageUrl = await uploader.uploadImageFile(imageBytes);
    }

    widget.onPostCreated(message, imageUrl);

    setState(() {
      isUploading = false;
      _messageController.clear();
      imagePickedFile = null;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
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
                      child: imagePickedFile != null
                          ? (kIsWeb
                                ? Image.memory(
                                    imagePickedFile!.bytes!,
                                    width: double.infinity,
                                    height: 180,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    File(imagePickedFile!.path!),
                                    width: double.infinity,
                                    height: 180,
                                    fit: BoxFit.cover,
                                  ))
                          : Container(
                              width: double.infinity,
                              height: 180,
                              color: Colors.grey[300],
                              child: Center(child: Text('No image selected')),
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
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text("Add Image"),
                  ),
                  ElevatedButton(
                    onPressed: isUploading ? null : _submitPost,

                    child: isUploading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text("Post"),
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
