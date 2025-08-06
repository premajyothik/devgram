import 'package:devgram/features/auth/presentation/components/custom_textfiled.dart';
import 'package:devgram/features/auth/presentation/cubits/auth_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:devgram/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:devgram/features/auth/presentation/pages/signup_page.dart';

// Mock AuthCubit
class MockAuthCubit extends Mock implements AuthCubit {}

void main() {
  late MockAuthCubit mockAuthCubit;

  setUp(() {
    mockAuthCubit = MockAuthCubit();

    // Stub stream and state so BlocProvider works properly
    when(() => mockAuthCubit.stream).thenAnswer((_) => Stream.empty());
    when(() => mockAuthCubit.state).thenReturn(AuthInitial());

    // Stub signUp to return a Future<void>
    when(
      () => mockAuthCubit.signUp(any(), any(), any()),
    ).thenAnswer((_) async {});
  });

  Future<void> pumpSignupPage(
    WidgetTester tester, {
    VoidCallback? togglePage,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthCubit>.value(
          value: mockAuthCubit,
          child: SignupPage(togglePage: togglePage),
        ),
      ),
    );
  }

  testWidgets('SignupPage renders all expected widgets', (tester) async {
    await pumpSignupPage(tester);

    expect(find.text("Let's create your account! "), findsOneWidget);
    expect(find.byType(CustomTextField), findsNWidgets(4));
    expect(find.text('Sign up'), findsOneWidget);
    expect(find.text('Already a member?'), findsOneWidget);
    expect(find.text(' Login now!'), findsOneWidget);
  });

  testWidgets('Calls signUp when all fields are filled and passwords match', (
    tester,
  ) async {
    await pumpSignupPage(tester);

    await tester.enterText(
      find.byWidgetPredicate(
        (w) => w is CustomTextField && w.hintText == "Name",
      ),
      'John Doe',
    );
    await tester.enterText(
      find.byWidgetPredicate(
        (w) => w is CustomTextField && w.hintText == "Email",
      ),
      'john@example.com',
    );
    await tester.enterText(
      find.byWidgetPredicate(
        (w) => w is CustomTextField && w.hintText == "Password",
      ),
      'password123',
    );
    await tester.enterText(
      find.byWidgetPredicate(
        (w) => w is CustomTextField && w.hintText == "Confirm Password",
      ),
      'password123',
    );

    await tester.tap(find.text('Sign up'));
    await tester.pump();

    verify(
      () => mockAuthCubit.signUp('john@example.com', 'John Doe', 'password123'),
    ).called(1);
  });

  testWidgets('Shows error SnackBar if fields are empty', (tester) async {
    await pumpSignupPage(tester);

    await tester.tap(find.text('Sign up'));
    await tester.pump(); // start frame to show snackbar
    await tester.pump(const Duration(seconds: 1)); // let snackbar appear

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Please fill all fields'), findsOneWidget);
  });

  testWidgets('Shows error SnackBar if passwords do not match', (tester) async {
    await pumpSignupPage(tester);

    await tester.enterText(
      find.byWidgetPredicate(
        (w) => w is CustomTextField && w.hintText == "Name",
      ),
      'John Doe',
    );
    await tester.enterText(
      find.byWidgetPredicate(
        (w) => w is CustomTextField && w.hintText == "Email",
      ),
      'john@example.com',
    );
    await tester.enterText(
      find.byWidgetPredicate(
        (w) => w is CustomTextField && w.hintText == "Password",
      ),
      'password123',
    );
    await tester.enterText(
      find.byWidgetPredicate(
        (w) => w is CustomTextField && w.hintText == "Confirm Password",
      ),
      'different',
    );

    await tester.tap(find.text('Sign up'));
    await tester.pump(); // start frame to show snackbar
    await tester.pump(const Duration(seconds: 1)); // let snackbar appear

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets('Calls togglePage when Login now! text is tapped', (
    tester,
  ) async {
    var toggled = false;

    await pumpSignupPage(
      tester,
      togglePage: () {
        toggled = true;
      },
    );

    await tester.tap(find.text(' Login now!'));
    expect(toggled, true);
  });
}
