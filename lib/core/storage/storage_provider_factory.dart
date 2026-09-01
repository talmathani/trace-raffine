import '../../config/environment_config.dart';
import 'providers/appwrite_storage_provider.dart';
import 'providers/cloudflare_r2_storage_provider.dart';
import 'providers/storage_provider.dart';

enum StorageProviderType {
  appwrite,
  cloudflareR2,
}

class StorageProviderFactory {
  static StorageProvider create(StorageProviderType type) {
    switch (type) {
      case StorageProviderType.appwrite:
        return AppwriteStorageProvider();
      case StorageProviderType.cloudflareR2:
        return CloudflareR2StorageProvider(
          accountId: EnvironmentConfig.cloudflareAccountId,
          accessKeyId: EnvironmentConfig.cloudflareAccessKeyId,
          secretAccessKey: EnvironmentConfig.cloudflareSecretAccessKey,
          bucketName: EnvironmentConfig.cloudflareBucketName,
          customDomain: EnvironmentConfig.cloudflareCustomDomain,
        );
    }
  }
}
