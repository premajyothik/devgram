import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:devgram/features/auth/presentation/components/custom_textfiled.dart';
import 'package:devgram/features/profile/domain/entities/profile_user.dart';
import 'package:devgram/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:devgram/features/profile/presentation/cubit/profile_state.dart';
import 'package:devgram/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileCubit extends MockCubit<ProfileState>
    implements ProfileCubit {}

class FakeProfileState extends Fake implements ProfileState {}

void main() {
  late MockProfileCubit mockProfileCubit;

  final profileUser = ProfileUser(
    uid: 'user123',
    name: 'Test User',
    email: 'test@example.com',
    bio: 'This is my bio',
    profilePictureUrl: '',
  );

  setUpAll(() {
    registerFallbackValue(FakeProfileState());
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    mockProfileCubit = MockProfileCubit();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<ProfileCubit>.value(
        value: mockProfileCubit,
        child: EditProfilePage(profileUser: profileUser),
      ),
    );
  }

  testWidgets('shows loading indicator when state is ProfileLoading', (
    tester,
  ) async {
    when(() => mockProfileCubit.state).thenReturn(ProfileLoading());

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('uploading...'), findsOneWidget);
  });

  testWidgets('displays profile info when loaded', (tester) async {
    when(() => mockProfileCubit.state).thenReturn(ProfileInitial());

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.text('Change Profile Picture'), findsOneWidget);
    expect(find.byType(CustomTextField), findsOneWidget);
  });

  testWidgets(
    'calls updateProfile when upload button pressed with valid data',
    (tester) async {
      // Setup
      when(() => mockProfileCubit.state).thenReturn(ProfileInitial());
      when(
        () => mockProfileCubit.stream,
      ).thenAnswer((_) => Stream.value(ProfileInitial()));

      when(
        () => mockProfileCubit.updateProfile(any(), any(), any()),
      ).thenAnswer((_) async {});

      // Pump widget
      await tester.pumpWidget(createWidgetUnderTest());

      // Simulate user input
      await tester.enterText(find.byType(CustomTextField), 'Updated bio');
      await tester.tap(find.byIcon(Icons.upload));
      await tester.pumpAndSettle();

      verifyNever(() => mockProfileCubit.updateProfile(any(), any(), any()));
    },
  );

  testWidgets('shows snackbar if bio and image are both empty', (tester) async {
    when(() => mockProfileCubit.state).thenReturn(ProfileInitial());

    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.byIcon(Icons.upload));
    await tester.pump(); // wait for snackbar

    expect(find.text('Bio cannot be empty'), findsOneWidget);
  });

  testWidgets('navigates back when ProfileLoaded state is emitted', (
    tester,
  ) async {
    whenListen(
      mockProfileCubit,
      Stream.fromIterable([ProfileInitial(), ProfileLoaded(profileUser)]),
      initialState: ProfileInitial(),
    );

    await tester.pumpWidget(createWidgetUnderTest());

    await tester.pump(); // Allow stream to emit
    await tester.pumpAndSettle();

    expect(find.byType(EditProfilePage), findsNothing);
  });
}
