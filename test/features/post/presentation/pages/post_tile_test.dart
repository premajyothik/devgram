import 'package:bloc_test/bloc_test.dart';
import 'package:devgram/features/auth/domain/entities/app_user.dart';
import 'package:devgram/features/post/domain/entities/post.dart';
import 'package:devgram/features/post/presentation/cubit/post_cubit.dart';
import 'package:devgram/features/post/presentation/cubit/post_states.dart';
import 'package:devgram/features/post/presentation/pages/post_tile.dart';
import 'package:devgram/features/profile/presentation/cubit/Profilepic_cubit.dart';
import 'package:devgram/features/profile/presentation/cubit/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:intl/intl.dart';

// Mock Classes
class MockPostCubit extends Mock implements PostCubit {}

class MockProfilePicCubit extends Mock implements ProfilePicCubit {}

void main() {
  late MockPostCubit mockPostCubit;
  late MockProfilePicCubit mockProfilePicCubit;
  late AppUser currentUser;
  late Post testPost;

  setUpAll(() {
    testPost = Post(
      id: 'post1',
      userId: 'user123',
      userName: 'Test User',
      text: 'Hello world',
      likeBy: <String>[],
      timeStamp: DateTime.now(),
      imageUrl: '',
    );
    registerFallbackValue(ProfileInitial());
    registerFallbackValue(testPost);
  });

  setUp(() {
    mockPostCubit = MockPostCubit();
    mockProfilePicCubit = MockProfilePicCubit();

    currentUser = AppUser(
      uid: 'user123',
      name: 'Test User',
      email: 'test@example.com',
    );

    when(
      () => mockProfilePicCubit.fetchUserProfilePic(any()),
    ).thenAnswer((_) async {});
    whenListen(
      mockProfilePicCubit,
      Stream.value(ProfileInitial()),
      initialState: ProfileInitial(),
    );

    when(() => mockPostCubit.state).thenReturn(PostInitial());
    when(
      () => mockPostCubit.stream,
    ).thenAnswer((_) => Stream<PostStates>.empty());
  });

  Widget createWidgetUnderTest({
    required Post post,
    required AppUser user,
    required VoidCallback onDelete,
  }) {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<PostCubit>.value(value: mockPostCubit),
          BlocProvider<ProfilePicCubit>.value(value: mockProfilePicCubit),
        ],
        child: Scaffold(
          body: PostTile(post: post, currentUser: user, onDelete: onDelete),
        ),
      ),
    );
  }

  testWidgets('renders post details correctly', (tester) async {
    await tester.pumpWidget(
      createWidgetUnderTest(post: testPost, user: currentUser, onDelete: () {}),
    );

    // Check username and post text display
    expect(find.text(testPost.userName), findsOneWidget);
    expect(find.text(testPost.text), findsOneWidget);

    // Check like icon (should be unliked initially)
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsNothing);

    // Like count text
    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('toggles like state on double tap', (tester) async {
    // Mock toggleLikePost to return a completed future
    when(
      () => mockPostCubit.toggleLikePost(any(), any()),
    ).thenAnswer((_) async {});

    await tester.pumpWidget(
      createWidgetUnderTest(post: testPost, user: currentUser, onDelete: () {}),
    );

    final likeIconFinder = find.byIcon(Icons.favorite_border);
    expect(likeIconFinder, findsOneWidget);

    // Simulate double tap with two taps and small delay
    await tester.tap(likeIconFinder);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(likeIconFinder);

    // Wait for all async tasks and animations to finish
    await tester.pumpAndSettle();

    // Now the icon should be favorite (liked)
    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });

  testWidgets('shows delete button if currentUser owns the post', (
    tester,
  ) async {
    bool deleteCalled = false;
    await tester.pumpWidget(
      createWidgetUnderTest(
        post: testPost,
        user: currentUser,
        onDelete: () {
          deleteCalled = true;
        },
      ),
    );

    final deleteButton = find.byIcon(Icons.delete_outline);
    expect(deleteButton, findsOneWidget);

    // Tap delete button and verify callback is called
    await tester.tap(deleteButton);
    expect(deleteCalled, true);
  });

  testWidgets(
    'does not show delete button if currentUser does not own the post',
    (tester) async {
      final otherUser = AppUser(
        uid: 'user999',
        name: 'Other User',
        email: 'other@example.com',
      );

      await tester.pumpWidget(
        createWidgetUnderTest(post: testPost, user: otherUser, onDelete: () {}),
      );

      final deleteButton = find.byIcon(Icons.delete_outline);
      expect(deleteButton, findsNothing);
    },
  );
}
