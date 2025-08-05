import 'package:devgram/features/auth/data/firebase_auth_repo.dart';
import 'package:devgram/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:devgram/features/auth/presentation/cubits/auth_states.dart';
import 'package:devgram/features/auth/presentation/pages/auth_page.dart';
import 'package:devgram/features/home/presentation/pages/root_page.dart';
import 'package:devgram/features/post/data/firebase_post_repo.dart';
import 'package:devgram/features/post/presentation/cubit/post_cubit.dart';
import 'package:devgram/features/profile/data/firebase_profile_repo.dart';
import 'package:devgram/features/profile/presentation/cubit/Profilepic_cubit.dart';
import 'package:devgram/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:devgram/features/storage/data/firebase_storage_repo.dart';
import 'package:devgram/themes/light_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainApp extends StatelessWidget {
  final authRepo = FirebaseAuthRepo();
  final profileRepo = FirebaseProfileRepo();
  final storageRepo = FirebaseStorageRepo();
  final postRepo = FirebasePostRepo();
  MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(authRepo)..checkAuthentication(),
        ),
        BlocProvider<ProfileCubit>(
          create: (context) => ProfileCubit(profileRepo, storageRepo),
        ),
        BlocProvider<ProfilePicCubit>(
          create: (context) => ProfilePicCubit(profileRepo),
        ),
        BlocProvider<PostCubit>(create: (context) => PostCubit(postRepo)),
      ],
      child: MaterialApp(
        theme: lightMode,
        debugShowCheckedModeBanner: false,
        home: BlocConsumer<AuthCubit, AuthStates>(
          builder: (context, authSate) {
            if (authSate is Authenticated) {
              // Navigate to home page or main app page
              return RootPage(uid: context.read<AuthCubit>().currentUser.uid);
            } else if (authSate is Unauthenticated) {
              // Show the authentication page
              return AuthPage();
            } else if (authSate is AuthLoading) {
              // Show a loading indicator while checking authentication
              return Scaffold(body: Center(child: CircularProgressIndicator()));
            } else if (authSate is AuthError) {
              // Show an error message
              return Scaffold(
                body: Center(child: Text('Error: ${authSate.errorMessage}')),
              );
            }
            return AuthPage();
          },
          listener: (context, state) {
            if (state is AuthError) {
              // Show an error message if authentication fails
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Authentication Error: ${state.errorMessage}'),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
