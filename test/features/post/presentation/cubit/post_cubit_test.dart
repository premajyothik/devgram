import 'package:bloc_test/bloc_test.dart';
import 'package:devgram/features/post/domain/entities/post.dart';
import 'package:devgram/features/post/domain/repo/post_repo.dart';
import 'package:devgram/features/post/presentation/cubit/post_cubit.dart';
import 'package:devgram/features/post/presentation/cubit/post_states.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock class
class MockPostRepo extends Mock implements PostRepo {}

void main() {
  late PostCubit postCubit;
  late MockPostRepo mockPostRepo;

  final post = Post(
    id: '1',
    userId: 'user123',
    userName: 'Tester',
    text: 'Hello World',
    timeStamp: DateTime.now(),
  );

  setUp(() {
    mockPostRepo = MockPostRepo();
    postCubit = PostCubit(mockPostRepo);
    registerFallbackValue(post);
  });

  tearDown(() {
    postCubit.close();
  });

  group('PostCubit', () {
    blocTest<PostCubit, PostStates>(
      'emits [PostLoading, PostLoaded] when fetchPostsByUserId is successful',
      build: () {
        when(
          () => mockPostRepo.getPostsByUserId('user123'),
        ).thenAnswer((_) async => [post]);
        return postCubit;
      },
      act: (cubit) => cubit.fetchPostsByUserId('user123'),
      expect: () => [
        PostLoading(),
        PostLoaded([post]),
      ],
    );

    blocTest<PostCubit, PostStates>(
      'emits [PostLoading, PostError] when fetchPostsByUserId returns empty',
      build: () {
        when(
          () => mockPostRepo.getPostsByUserId('user123'),
        ).thenAnswer((_) async => []);
        return postCubit;
      },
      act: (cubit) => cubit.fetchPostsByUserId('user123'),
      expect: () => [PostLoading(), PostError("No posts found for this user")],
    );

    blocTest<PostCubit, PostStates>(
      'emits [PostLoading, PostLoaded] when fetchAllPosts is successful',
      build: () {
        when(() => mockPostRepo.getAllPosts()).thenAnswer((_) async => [post]);
        return postCubit;
      },
      act: (cubit) => cubit.fetchAllPosts(),
      expect: () => [
        PostLoading(),
        PostLoaded([post]),
      ],
    );

    blocTest<PostCubit, PostStates>(
      'emits [PostLoading, PostError] when fetchAllPosts fails',
      build: () {
        when(() => mockPostRepo.getAllPosts()).thenThrow(Exception('fail'));
        return postCubit;
      },
      act: (cubit) => cubit.fetchAllPosts(),
      expect: () => [PostLoading(), isA<PostError>()],
    );

    blocTest<PostCubit, PostStates>(
      'emits [PostLoading] and calls fetchAllPosts when createPost is called',
      build: () {
        when(() => mockPostRepo.createPost(any())).thenAnswer((_) async => {});
        when(() => mockPostRepo.getAllPosts()).thenAnswer((_) async => [post]);
        return postCubit;
      },
      act: (cubit) => cubit.createPost(post),
      expect: () => [
        PostLoading(),
        PostLoaded([post]),
      ],
    );

    blocTest<PostCubit, PostStates>(
      'emits [PostLoading] and calls fetchAllPosts when deletePost is called',
      build: () {
        when(
          () => mockPostRepo.deletePost(post.id),
        ).thenAnswer((_) async => {});
        when(() => mockPostRepo.getAllPosts()).thenAnswer((_) async => []);
        return postCubit;
      },
      act: (cubit) => cubit.deletePost(post.id),
      expect: () => [PostLoading(), PostError("No posts available")],
    );

    blocTest<PostCubit, PostStates>(
      'emits [PostError] when toggleLikePost throws error',
      build: () {
        when(
          () => mockPostRepo.likePost(post.id, 'user123'),
        ).thenThrow(Exception('like failed'));
        return postCubit;
      },
      act: (cubit) => cubit.toggleLikePost(post, 'user123'),
      expect: () => [isA<PostError>()],
    );
  });
}
