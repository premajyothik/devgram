import 'dart:io';

import 'package:devgram/features/post/presentation/pages/upload_post_page.dart';
import 'package:devgram/utils/imgBB_uploader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUploader extends Mock implements ImgBBUploader {}

void main() {
  late MockUploader mockUploader;

  setUp(() {
    mockUploader = MockUploader();
  });

  Widget createWidgetUnderTest(Function(String, String?) onPostCreated) {
    return MaterialApp(
      home: Scaffold(body: UploadPostPage(onPostCreated: onPostCreated)),
    );
  }

  testWidgets('displays input field and post button', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest((_, __) {}));

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Post'), findsOneWidget);
    expect(find.text('Add Image'), findsOneWidget);
  });

  testWidgets('shows error if submitting without message and image', (
    tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest((_, __) {}));

    await tester.tap(find.text('Post'));
    await tester.pump();

    expect(find.text("Please enter text or pick an image."), findsOneWidget);
  });

  testWidgets('calls onPostCreated with text only', (tester) async {
    String? postedText;
    String? postedImage;

    await tester.pumpWidget(
      createWidgetUnderTest((text, image) {
        postedText = text;
        postedImage = image;
      }),
    );

    await tester.enterText(find.byType(TextField), "Hello world");
    await tester.tap(find.text('Post'));
    await tester.pumpAndSettle(); // Let Navigator.pop() finish

    expect(postedText, "Hello world");
    expect(postedImage, isNull);
  });

  testWidgets('shows loading indicator when uploading', (tester) async {
    final uploadPostPageKey = GlobalKey<UploadPostPageState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UploadPostPage(
            key: uploadPostPageKey,
            onPostCreated: (_, __) {},
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), "Test message");

    // Access the widget's state using the GlobalKey
    uploadPostPageKey.currentState!.setState(() {
      uploadPostPageKey.currentState!.isUploading = true;
    });

    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  // For image testing, mocking FilePicker is recommended but optional here
}
