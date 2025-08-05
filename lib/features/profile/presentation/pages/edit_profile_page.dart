import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:devgram/features/auth/presentation/components/custom_textfiled.dart';
import 'package:devgram/features/profile/domain/entities/profile_user.dart';
import 'package:devgram/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:devgram/features/profile/presentation/cubit/profile_state.dart';
import 'package:file_picker/file_picker.dart';
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

  void save() {
    // Save the profile changes
    final newBio = bioTextController.text.isEmpty
        ? null
        : bioTextController.text;
    final imageFile = imagePickedFile?.path ?? "";
    if (newBio != null || imageFile != null) {
      print('imageFile: ' + imageFile);
      context.read<ProfileCubit>().updateProfile(
        widget.profileUser.uid,
        newBio,
        imageFile,
      );
    }
    // else {
    //   ScaffoldMessenger.of(
    //     context,
    //   ).showSnackBar(SnackBar(content: Text('Bio cannot be empty')));
    //   return;
    // }
  }

  Future<void> pickImage() async {
    print('result llll');
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    print('result $result');
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
          print('error:' + state.errorMessage);
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
                    ? Image.file(
                        File(imagePickedFile!.path!),
                        fit: BoxFit.cover,
                        width: 200,
                        height: 200,
                      )
                    : CachedNetworkImage(
                        imageUrl: widget.profileUser.profilePictureUrl,
                        placeholder: (context, url) => Icon(
                          Icons.person,
                          size: 100,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        imageBuilder: (context, imageProvider) =>
                            Image(image: imageProvider, fit: BoxFit.cover),
                      ),
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
}
