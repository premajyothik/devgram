import 'package:bloc_test/bloc_test.dart';
import 'package:devgram/features/auth/domain/entities/app_user.dart';
import 'package:devgram/features/auth/domain/repository/auth_repo.dart';
import 'package:devgram/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:devgram/features/auth/presentation/cubits/auth_states.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// -------------------- Mocking --------------------
class MockAuthRepo extends Mock implements AuthRepo {}

void main() {
  late MockAuthRepo mockAuthRepo;
  late AuthCubit authCubit;

  final testUser = AppUser(
    uid: '123',
    name: 'Test User',
    email: 'test@example.com',
  );

  setUp(() {
    mockAuthRepo = MockAuthRepo();
    authCubit = AuthCubit(mockAuthRepo);
  });

  tearDown(() {
    authCubit.close();
  });

  group('AuthCubit', () {
    blocTest<AuthCubit, AuthStates>(
      'emits [Authenticated] when checkAuthentication returns user',
      build: () {
        when(
          () => mockAuthRepo.getCurrentUser(),
        ).thenAnswer((_) async => testUser);
        return authCubit;
      },
      act: (cubit) => cubit.checkAuthentication(),
      expect: () => [Authenticated(testUser)],
    );

    blocTest<AuthCubit, AuthStates>(
      'emits [Unauthenticated] when checkAuthentication returns null',
      build: () {
        when(() => mockAuthRepo.getCurrentUser()).thenAnswer((_) async => null);
        return authCubit;
      },
      act: (cubit) => cubit.checkAuthentication(),
      expect: () => [Unauthenticated()],
    );

    blocTest<AuthCubit, AuthStates>(
      'emits [AuthLoading, Authenticated] when login is successful',
      build: () {
        when(
          () => mockAuthRepo.logInWithEmailAndPassword(any(), any()),
        ).thenAnswer((_) async => testUser);
        return authCubit;
      },
      act: (cubit) => cubit.logIn('test@example.com', 'password'),
      expect: () => [AuthLoading(), Authenticated(testUser)],
    );

    blocTest<AuthCubit, AuthStates>(
      'emits [AuthLoading, Unauthenticated] when login returns null',
      build: () {
        when(
          () => mockAuthRepo.logInWithEmailAndPassword(any(), any()),
        ).thenAnswer((_) async => null);
        return authCubit;
      },
      act: (cubit) => cubit.logIn('test@example.com', 'password'),
      expect: () => [AuthLoading(), Unauthenticated()],
    );

    blocTest<AuthCubit, AuthStates>(
      'emits [AuthLoading, AuthError, Unauthenticated] when login throws',
      build: () {
        when(
          () => mockAuthRepo.logInWithEmailAndPassword(any(), any()),
        ).thenThrow(Exception('Login failed'));
        return authCubit;
      },
      act: (cubit) => cubit.logIn('test@example.com', 'wrong'),
      expect: () => [AuthLoading(), isA<AuthError>(), Unauthenticated()],
    );

    blocTest<AuthCubit, AuthStates>(
      'emits [AuthLoading, Authenticated] when signUp is successful',
      build: () {
        when(
          () => mockAuthRepo.signUpWithEmailAndPassword(any(), any(), any()),
        ).thenAnswer((_) async => testUser);
        return authCubit;
      },
      act: (cubit) => cubit.signUp('test@example.com', 'Test User', 'password'),
      expect: () => [AuthLoading(), Authenticated(testUser)],
    );

    blocTest<AuthCubit, AuthStates>(
      'emits [AuthLoading, AuthError, Unauthenticated] when signUp throws',
      build: () {
        when(
          () => mockAuthRepo.signUpWithEmailAndPassword(any(), any(), any()),
        ).thenThrow(Exception('Signup failed'));
        return authCubit;
      },
      act: (cubit) => cubit.signUp('test@example.com', 'Test User', 'password'),
      expect: () => [AuthLoading(), isA<AuthError>(), Unauthenticated()],
    );

    blocTest<AuthCubit, AuthStates>(
      'emits [Unauthenticated] on logout',
      build: () {
        when(() => mockAuthRepo.logout()).thenAnswer((_) async {});
        return authCubit;
      },
      act: (cubit) => cubit.logout(),
      expect: () => [Unauthenticated()],
    );
  });
}
