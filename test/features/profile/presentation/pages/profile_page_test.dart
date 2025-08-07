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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

// --- Mock Classes ---
class MockAuthCubit extends Mock implements AuthCubit {}

class MockProfileCubit extends Mock implements ProfileCubit {}

class MockPostCubit extends Mock implements PostCubit {}

void main() {
  late MockAuthCubit mockAuthCubit;
  late MockProfileCubit mockProfileCubit;
  late MockPostCubit mockPostCubit;

  final testUser = ProfileUser(
    uid: 'testUserId',
    name: 'test',
    email: 'test@gmail.com',
    profilePictureUrl: '',
    bio: 'This is a test bio',
  );

  final testPost = Post(
    id: 'post1',
    userId: 'testUserId',
    userName: 'Test User',
    text: 'Hello Test Post',
    imageUrl: '',
    likeBy: [],
    timeStamp: DateTime.now(),
  );

  setUpAll(() {
    registerFallbackValue(ProfileLoading());
    registerFallbackValue(PostLoading());
  });

  setUp(() {
    mockAuthCubit = MockAuthCubit();
    mockProfileCubit = MockProfileCubit();
    mockPostCubit = MockPostCubit();
    // Only needed if you use `any<ProfileState>()`

    when(() => mockProfileCubit.state).thenReturn(ProfileLoaded(testUser));
    when(
      () => mockProfileCubit.stream,
    ).thenAnswer((_) => Stream.value(ProfileLoaded(testUser)));

    when(() => mockPostCubit.state).thenReturn(PostLoaded([testPost]));
    when(
      () => mockPostCubit.stream,
    ).thenAnswer((_) => Stream.value(PostLoaded([testPost])));
  });

  Widget createTestWidget() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: mockAuthCubit),
        BlocProvider<ProfileCubit>.value(value: mockProfileCubit),
        BlocProvider<PostCubit>.value(value: mockPostCubit),
      ],
      child: MaterialApp(home: ProfilePage(userId: testUser.uid)),
    );
  }

  testWidgets('shows profile and posts when loaded', (tester) async {
    // Mock states
    when(() => mockProfileCubit.state).thenReturn(ProfileLoaded(testUser));
    when(() => mockPostCubit.state).thenReturn(PostLoaded([testPost]));

    // ✅ Mock streams to prevent "Null" errors
    when(
      () => mockProfileCubit.stream,
    ).thenAnswer((_) => Stream.value(ProfileLoaded(testUser)));
    when(
      () => mockPostCubit.stream,
    ).thenAnswer((_) => Stream.value(PostLoaded([testPost])));

    await tester.pumpWidget(createTestWidget());

    await tester.pumpAndSettle();

    // Profile info
    expect(find.text(testUser.name), findsOneWidget);
    expect(find.text(testUser.email), findsOneWidget);
    expect(find.text(testUser.bio), findsOneWidget);

    // PostTile
    expect(find.byType(PostTile), findsOneWidget);
    expect(find.text(testPost.text), findsOneWidget);
  });

  testWidgets('shows no posts message when posts list is empty', (
    tester,
  ) async {
    when(() => mockProfileCubit.state).thenReturn(ProfileLoaded(testUser));
    when(() => mockPostCubit.state).thenReturn(PostLoaded([]));

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('No Post Available'), findsOneWidget);
  });

  testWidgets('shows profile error message', (tester) async {
    when(
      () => mockProfileCubit.state,
    ).thenReturn(ProfileError('Failed to load profile'));

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Failed to load profile'), findsOneWidget);
  });

  testWidgets('shows post error message', (tester) async {
    when(() => mockProfileCubit.state).thenReturn(ProfileLoaded(testUser));
    when(
      () => mockPostCubit.state,
    ).thenReturn(PostError('Failed to load posts'));

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Error: Failed to load posts'), findsOneWidget);
  });

  testWidgets('tapping delete icon shows delete confirmation dialog', (
    tester,
  ) async {
    when(() => mockProfileCubit.state).thenReturn(ProfileLoaded(testUser));
    when(() => mockPostCubit.state).thenReturn(PostLoaded([testPost]));

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    final deleteButton = find.descendant(
      of: find.byType(PostTile),
      matching: find.byIcon(Icons.delete_outline),
    );

    expect(deleteButton, findsOneWidget);

    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    expect(find.text('Delete Post'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });
}
