import 'package:bloc_test/bloc_test.dart';
import 'package:devgram/features/profile/domain/entities/profile_user.dart';
import 'package:devgram/features/profile/domain/repo/profile_repo.dart';
import 'package:devgram/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:devgram/features/profile/presentation/cubit/profile_state.dart';
import 'package:devgram/features/storage/domain/repo/storage_repo.dart';
import 'package:devgram/utils/imgBB_uploader.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// --- Mock classes ---
class MockProfileRepo extends Mock implements ProfileRepo {}

class MockStorageRepo extends Mock implements StorageRepo {}

class MockImgBBUploader extends Mock implements ImgBBUploader {}

// Subclass to override uploadImageToImgBB for testing
class TestProfileCubit extends ProfileCubit {
  final MockImgBBUploader imgBBUploader;

  TestProfileCubit(
    ProfileRepo profileRepo,
    StorageRepo storageRepo,
    this.imgBBUploader,
  ) : super(profileRepo, storageRepo);

  @override
  Future<String?> uploadImageToImgBB(String imagePath) async {
    return imgBBUploader.uploadImageFile(imagePath);
  }
}

void main() {
  late ProfileCubit profileCubit;
  late MockProfileRepo mockProfileRepo;
  late MockStorageRepo mockStorageRepo;
  late MockImgBBUploader mockImgBBUploader;

  // Sample ProfileUser for testing
  final testProfileUser = ProfileUser(
    uid: 'user123',
    name: 'Test User',
    email: 'test@example.com',
    bio: 'Test bio',
    profilePictureUrl: 'http://example.com/pic.jpg',
  );

  setUp(() {
    mockProfileRepo = MockProfileRepo();
    mockStorageRepo = MockStorageRepo();
    mockImgBBUploader = MockImgBBUploader();

    profileCubit = ProfileCubit(mockProfileRepo, mockStorageRepo);

    // Override the uploadImageToImgBB method to call the mock uploader
    // This needs a little trick because uploadImageToImgBB is an instance method
    // We'll create a subclass of ProfileCubit that overrides it for testing:
  });

  group('fetchUserProfile', () {
    blocTest<ProfileCubit, ProfileState>(
      'emits [ProfileLoading, ProfileLoaded] when fetchUserProfile succeeds',
      build: () {
        when(
          () => mockProfileRepo.fetchUserProfile('user123'),
        ).thenAnswer((_) async => testProfileUser);
        return profileCubit;
      },
      act: (cubit) => cubit.fetchUserProfile('user123'),
      expect: () => [ProfileLoading(), ProfileLoaded(testProfileUser)],
    );

    blocTest<ProfileCubit, ProfileState>(
      'emits [ProfileLoading, ProfileError] when fetchUserProfile returns null',
      build: () {
        when(
          () => mockProfileRepo.fetchUserProfile('user123'),
        ).thenAnswer((_) async => null);
        return profileCubit;
      },
      act: (cubit) => cubit.fetchUserProfile('user123'),
      expect: () => [ProfileLoading(), ProfileError("Profile not found")],
    );

    blocTest<ProfileCubit, ProfileState>(
      'emits [ProfileLoading, ProfileError] when fetchUserProfile throws',
      build: () {
        when(
          () => mockProfileRepo.fetchUserProfile('user123'),
        ).thenThrow(Exception('fetch error'));
        return profileCubit;
      },
      act: (cubit) => cubit.fetchUserProfile('user123'),
      expect: () => [ProfileLoading(), ProfileError('Exception: fetch error')],
    );
  });

  group('updateProfile', () {
    late TestProfileCubit testProfileCubit;

    setUp(() {
      testProfileCubit = TestProfileCubit(
        mockProfileRepo,
        mockStorageRepo,
        mockImgBBUploader,
      );
      registerFallbackValue(testProfileUser);
    });

    blocTest<TestProfileCubit, ProfileState>(
      'emits [ProfileLoading, ProfileLoaded] on successful updateProfile with image upload',
      build: () {
        when(
          () => mockProfileRepo.fetchUserProfile('user123'),
        ).thenAnswer((_) async => testProfileUser);

        when(
          () => mockImgBBUploader.uploadImageFile('path/to/image.png'),
        ).thenAnswer((_) async => 'http://image.url/uploaded.png');

        when(
          () => mockProfileRepo.updateProfile(any()),
        ).thenAnswer((_) async {});

        // After update, fetchUserProfile returns updated user
        final updatedUser = testProfileUser.copyWith(
          newBio: 'New bio',
          newProfilePictureUrl: 'http://image.url/uploaded.png',
        );
        when(
          () => mockProfileRepo.fetchUserProfile('user123'),
        ).thenAnswer((_) async => updatedUser);

        return testProfileCubit;
      },
      act: (cubit) =>
          cubit.updateProfile('user123', 'New bio', 'path/to/image.png'),
      expect: () => [
        ProfileLoading(),
        ProfileLoaded(
          testProfileUser.copyWith(
            newBio: 'New bio',
            newProfilePictureUrl: 'http://image.url/uploaded.png',
          ),
        ),
      ],
    );

    blocTest<TestProfileCubit, ProfileState>(
      'emits [ProfileLoading, ProfileError] when fetchUserProfile returns null during updateProfile',
      build: () {
        when(
          () => mockProfileRepo.fetchUserProfile('user123'),
        ).thenAnswer((_) async => null);
        return testProfileCubit;
      },
      act: (cubit) => cubit.updateProfile('user123', 'New bio', ''),
      expect: () => [
        ProfileLoading(),
        ProfileError("Failed to fetch user profile"),
      ],
    );

    blocTest<TestProfileCubit, ProfileState>(
      'emits [ProfileLoading, ProfileError] when updateProfile throws an exception',
      build: () {
        when(
          () => mockProfileRepo.fetchUserProfile('user123'),
        ).thenAnswer((_) async => testProfileUser);
        when(
          () => mockProfileRepo.updateProfile(any()),
        ).thenThrow(Exception('update error'));
        when(
          () => mockImgBBUploader.uploadImageFile(''),
        ).thenAnswer((_) async => '');

        return testProfileCubit;
      },
      act: (cubit) => cubit.updateProfile('user123', 'New bio', ''),
      expect: () => [ProfileLoading(), isA<ProfileError>()],
    );
  });
}
