import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'storage_provider.dart';

class CloudflareR2StorageProvider implements StorageProvider {
  final String accountId;
  final String accessKeyId;
  final String secretAccessKey;
  final String bucketName;
  final String customDomain;

  CloudflareR2StorageProvider({
    required this.accountId,
    required this.accessKeyId,
    required this.secretAccessKey,
    required this.bucketName,
    required this.customDomain,
  });

  @override
  Future<String> uploadFile({
    required Uint8List bytes,
    required String fileName,
    required String contentType,
    List<String>? permissions,
  }) async {
    final fileKey = fileName;
    return 'https://$customDomain/$fileKey';
  }

  @override
  String getFileView({required String fileId}) {
    return 'https://$customDomain/$fileId';
  }

  @override
  Future<void> deleteFile({required String fileId}) async {
    final url = 'https://$customDomain/$fileId';
    final response = await http.delete(Uri.parse(url));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete file: ${response.statusCode}');
    }
  }
}
