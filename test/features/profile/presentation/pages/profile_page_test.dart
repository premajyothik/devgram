import 'package:bloc_test/bloc_test.dart';
import 'package:devgram/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:devgram/features/post/domain/entities/post.dart';
import 'package:devgram/features/post/presentation/cubit/post_cubit.dart';
import 'package:devgram/features/post/presentation/cubit/post_states.dart';
import 'package:devgram/features/post/presentation/pages/post_tile.dart';
import 'package:devgram/features/profile/domain/entities/profile_user.dart';
import 'package:devgram/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:devgram/features/profile/presentation/cubit/profile_state.dart';
import 'package:devgram/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Mock classes
class MockAuthCubit extends Mock implements AuthCubit {}

class MockProfileCubit extends Mock implements ProfileCubit {}

class MockPostCubit extends Mock implements PostCubit {}

void main() {
  late MockAuthCubit mockAuthCubit;
  late MockProfileCubit mockProfileCubit;
  late MockPostCubit mockPostCubit;

  // Sample data
  final testUser = ProfileUser(
    uid: 'user123',
    name: 'Test User',
    email: 'test@example.com',
    profilePictureUrl: 'https://example.com/profile.jpg',
    bio: 'Test bio',
  );

  final testPost = Post(
    id: 'post1',
    text: 'Test Post Content',
    userId: 'user123',
    userName: 'tester',
    timeStamp: DateTime.now(),
    imageUrl: '',
    // Add other required fields...
  );

  setUp(() {
    mockAuthCubit = MockAuthCubit();
    mockProfileCubit = MockProfileCubit();
    mockPostCubit = MockPostCubit();

    // Mock AuthCubit current user
    when(() => mockAuthCubit.currentUser).thenReturn(testUser);

    // Mock ProfileCubit states
    when(() => mockProfileCubit.state).thenReturn(ProfileLoaded(testUser));
    whenListen(
      mockProfileCubit,
      Stream<ProfileState>.fromIterable([ProfileLoaded(testUser)]),
      initialState: ProfileLoaded(testUser),
    );

    // Mock PostCubit states
    when(() => mockPostCubit.state).thenReturn(PostLoaded([testPost]));
    whenListen(
      mockPostCubit,
      Stream<PostStates>.fromIterable([
        PostLoaded([testPost]),
      ]),
      initialState: PostLoaded([testPost]),
    );

    // Mock deletePost to do nothing async
    when(() => mockPostCubit.deletePost(any())).thenAnswer((_) async {});
  });

  Widget createTestWidget({
    required AuthCubit authCubit,
    required ProfileCubit profileCubit,
    required PostCubit postCubit,
  }) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: authCubit),
        BlocProvider<ProfileCubit>.value(value: profileCubit),
        BlocProvider<PostCubit>.value(value: postCubit),
      ],
      child: MaterialApp(home: ProfilePage(userId: testUser.uid)),
    );
  }

  testWidgets('renders profile data and posts', (tester) async {
    FlutterError.onError = (details) {
      FlutterError.dumpErrorToConsole(details);
      fail(details.exceptionAsString());
    };

    await tester.pumpWidget(
      createTestWidget(
        authCubit: mockAuthCubit,
        profileCubit: mockProfileCubit,
        postCubit: mockPostCubit,
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(testUser.name), findsOneWidget);
    expect(find.text(testUser.email), findsOneWidget);
    expect(find.byType(PostTile), findsOneWidget);
  });

  testWidgets('shows delete dialog when delete post is tapped', (tester) async {
    await tester.pumpWidget(
      createTestWidget(
        authCubit: mockAuthCubit,
        profileCubit: mockProfileCubit,
        postCubit: mockPostCubit,
      ),
    );

    await tester.pumpAndSettle();

    final postTile = find.byType(PostTile).first;
    expect(postTile, findsOneWidget);

    final deleteButton = find.descendant(
      of: postTile,
      matching: find.byIcon(Icons.delete),
    );

    expect(deleteButton, findsOneWidget);

    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    expect(find.text('Delete Post'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('calls deletePost when confirm delete pressed', (tester) async {
    await tester.pumpWidget(
      createTestWidget(
        authCubit: mockAuthCubit,
        profileCubit: mockProfileCubit,
        postCubit: mockPostCubit,
      ),
    );

    await tester.pumpAndSettle();

    final postTile = find.byType(PostTile).first;
    final deleteButton = find.descendant(
      of: postTile,
      matching: find.byIcon(Icons.delete),
    );

    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    final confirmDeleteButton = find.text('Delete');
    expect(confirmDeleteButton, findsOneWidget);

    await tester.tap(confirmDeleteButton);
    await tester.pumpAndSettle();

    verify(() => mockPostCubit.deletePost(testPost.id)).called(1);
  });
}
