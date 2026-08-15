import 'package:appwrite/appwrite.dart';
import 'core/appwrite/appwrite_service.dart';
import 'core/appwrite/appwrite_storage_constants.dart';

@pragma('vm:entry-point')
Future<void> main() async {
  print('=== TR APPWRITE STORAGE LIVE TEST ===');

  try {
    AppwriteService.initialize();

    print('[1] Checking session...');
    await AppwriteService.account.get();
    print('USER ID: ');
    print('USER EMAIL: ');
    print('EMAIL VERIFIED: ');

    print('[2] Testing upload...');
    final bytes = [84, 82, 95, 84, 69, 83, 84];

    final file = await AppwriteService.storage.createFile(
      bucketId: AppwriteStorageConstants.designsBucketId,
      fileId: ID.unique(),
      file: InputFile.fromBytes(
        bytes: bytes,
        filename: 'tr_storage_test.txt',
        contentType: 'text/plain',
      ),
    );

    print('UPLOAD SUCCESS');
    print('FILE ID: ');

    print('[3] Deleting test file...');
    await AppwriteService.storage.deleteFile(
      bucketId: AppwriteStorageConstants.designsBucketId,
      fileId: file.$id,
    );

    print('DELETE SUCCESS');
    print('=== STORAGE TEST PASSED ===');
  } on AppwriteException catch (error, stackTrace) {
    print('=== APPWRITE ERROR ===');
    print('CODE: ');
    print('TYPE: ');
    print('MESSAGE: ');
    print('RESPONSE: ');
    print(stackTrace);
  } catch (error, stackTrace) {
    print('=== UNKNOWN ERROR ===');
    print('ERROR: ');
    print(stackTrace);
  }
}


