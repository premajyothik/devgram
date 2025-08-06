import 'package:devgram/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:devgram/features/auth/presentation/cubits/auth_states.dart';
import 'package:devgram/features/auth/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

// Mock the AuthCubit
class MockAuthCubit extends Mock implements AuthCubit {}

void main() {
  late AuthCubit authCubit;

  setUp(() {
    authCubit = MockAuthCubit();
    // Mock the stream of states and current state
    when(() => authCubit.stream).thenAnswer((_) => Stream.empty());
    when(() => authCubit.state).thenReturn(AuthInitial());

    // Stub the logIn method to return a completed future (do nothing async)
    when(() => authCubit.logIn(any(), any())).thenAnswer((_) async {});
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<AuthCubit>.value(
        value: authCubit,
        child: const LoginPage(),
      ),
    );
  }

  testWidgets('LoginPage renders all expected widgets', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Welcome back!'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2)); // Email & Password
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Not a member?'), findsOneWidget);
    expect(find.textContaining('Sign up now!'), findsOneWidget);
  });

  testWidgets('Shows error when email or password is empty', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.text('Login'));
    await tester.pump(); // Rebuilds to show snackbar

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Please fill email and password fields'), findsOneWidget);
    verifyNever(() => authCubit.logIn(any(), any()));
  });

  testWidgets('Calls AuthCubit.logIn when email and password are provided', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Enter email and password
    await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'password123');

    await tester.tap(find.text('Login'));
    await tester.pump(); // Rebuild after tap

    verify(() => authCubit.logIn('test@example.com', 'password123')).called(1);
  });
}
