import 'package:flutter/widgets.dart';
import 'package:appwrite/appwrite.dart';

import 'core/appwrite/appwrite_service.dart';
import 'core/appwrite/appwrite_storage_constants.dart';

@pragma('vm:entry-point')
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('=== TR APPWRITE STORAGE AUTHENTICATED TEST ===');

  try {
    AppwriteService.initialize();

    print('[1] Checking authenticated session...');

    try {
      final user = await AppwriteService.account.get();

      print('SESSION EXISTS');
      print('USER ID: ${user.$id}');
      print('USER EMAIL: ${user.email}');
      print('EMAIL VERIFIED: ${user.emailVerification}');
    } on AppwriteException catch (error) {
      if (error.code == 401) {
        print('NO AUTHENTICATED SESSION');
        print('STORAGE UPLOAD TEST NOT EXECUTED');
        print('EXPECTED: LOGIN REQUIRED');
        return;
      }

      rethrow;
    }

    print('[2] Testing authenticated upload...');

    final bytes = <int>[
      84,
      82,
      95,
      83,
      84,
      79,
      82,
      65,
      71,
      69,
      95,
      84,
      69,
      83,
      84,
    ];

    final file = await AppwriteService.storage.createFile(
      bucketId: AppwriteStorageConstants.designsBucketId,
      fileId: ID.unique(),
      file: InputFile.fromBytes(
        bytes: bytes,
        filename: 'tr_storage_test.dst',
        contentType: 'application/octet-stream',
      ),
    );

    print('UPLOAD SUCCESS');
    print('FILE ID: ${file.$id}');
    print('FILE PERMISSIONS: ${file.$permissions}');

    print('[3] Deleting test file...');

    await AppwriteService.storage.deleteFile(
      bucketId: AppwriteStorageConstants.designsBucketId,
      fileId: file.$id,
    );

    print('DELETE SUCCESS');
    print('=== AUTHENTICATED STORAGE TEST PASSED ===');
  } on AppwriteException catch (error, stackTrace) {
    print('=== APPWRITE ERROR ===');
    print('CODE: ${error.code}');
    print('TYPE: ${error.type}');
    print('MESSAGE: ${error.message}');
    print('RESPONSE: ${error.response}');
    print(stackTrace);
  } catch (error, stackTrace) {
    print('=== UNKNOWN ERROR ===');
    print('ERROR: $error');
    print(stackTrace);
  }
}
