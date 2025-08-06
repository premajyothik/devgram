import 'dart:io';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:devgram/features/auth/presentation/components/custom_textfiled.dart';
import 'package:devgram/features/profile/domain/entities/profile_user.dart';
import 'package:devgram/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:devgram/features/profile/presentation/cubit/profile_state.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditProfilePage extends StatefulWidget {
  final ProfileUser profileUser;
  const EditProfilePage({super.key, required this.profileUser});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController bioTextController = TextEditingController();
  PlatformFile? imagePickedFile;
  @override
  void dispose() {
    bioTextController.dispose();
    super.dispose();
  }

  void save() async {
    // Save the profile changes
    final newBio = bioTextController.text.isEmpty
        ? null
        : bioTextController.text;
    final imageFile = imagePickedFile?.path ?? "";
    Uint8List? imageBytes;

    if (kIsWeb) {
      imageBytes = imagePickedFile?.bytes;
    } else {
      imageBytes = await io.File(imageFile).readAsBytes();
    }
    if (newBio != null || imageBytes != null) {
      // print('imageFile: $imageFile');
      context.read<ProfileCubit>().updateProfile(
        widget.profileUser.uid,
        newBio,
        imageBytes,
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Bio cannot be empty')));
      return;
    }
  }

  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty) {
      final pickedFile = result.files.first;
      Uint8List? imageBytes = pickedFile.bytes;
      if (imageBytes != null) {
        setState(() {
          imagePickedFile = pickedFile; // Save for later use if needed
        });
        // print('Picked image name (web): ${pickedFile.name}');
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 10,
                children: [CircularProgressIndicator(), Text('uploading...')],
              ),
            ),
          );
        } else if (state is ProfileError) {
          print('error:${state.errorMessage}');
          return ScaffoldMessenger(
            child: SnackBar(content: Text('Error: ${state.errorMessage}')),
          );
        } else {
          //edit page
          return buildEditProfile();
        }
      },
      listener: (context, state) {
        if (state is ProfileLoaded) {
          Navigator.pop(context);
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.errorMessage}')),
          );
        }
      },
    );
  }

  Widget buildEditProfile({double uploadProgress = 0.0}) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Theme.of(context).colorScheme.primary,
        title: Text('Edit Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload),
            onPressed: () {
              // Save the profile changes
              save();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 10,
          children: [
            Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.hardEdge,
                child: imagePickedFile != null
                    ? (kIsWeb
                          ? Image.memory(
                              imagePickedFile!.bytes!,
                              fit: BoxFit.cover,
                              width: 200,
                              height: 200,
                            )
                          : Image.file(
                              File(imagePickedFile!.path!),
                              fit: BoxFit.cover,
                              width: 200,
                              height: 200,
                            ))
                    : buildProfileImage(widget.profileUser.profilePictureUrl),
              ),
            ),
            Center(
              child: MaterialButton(
                onPressed: pickImage,
                color: Colors.blue,
                child: Text('Change Profile Picture'),
              ),
            ),
            Text('bio'),
            CustomTextField(
              controller: bioTextController,
              hintText: 'Enter your bio',
              obscureText: false,
            ),
            // Add more fields as needed
          ],
        ),
      ),
    );
  }

  Widget buildProfileImage(String? imageUrl) {
    print(imageUrl);
    if (imageUrl == null || imageUrl.isEmpty) {
      return Icon(Icons.person, size: 100, color: Colors.grey);
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      placeholder: (context, url) => Icon(
        Icons.person,
        size: 100,
        color: Theme.of(context).colorScheme.primary,
      ),
      errorWidget: (context, url, error) =>
          Icon(Icons.error, size: 100, color: Colors.red),
      imageBuilder: (context, imageProvider) =>
          Image(image: imageProvider, fit: BoxFit.cover),
    );
  }
}
