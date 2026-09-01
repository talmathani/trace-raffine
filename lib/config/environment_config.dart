class EnvironmentConfig {
  // Appwrite
  static const String appwriteEndpoint = 'https://fra.cloud.appwrite.io/v1';
  static const String appwriteProjectId = 'trace-raffine';
  
  // Storage Provider - switch between 'appwrite' or 'cloudflareR2'
  static const String activeStorageProvider = 'appwrite';
  
  // Cloudflare R2 (future)
  static const String cloudflareAccountId = '';
  static const String cloudflareAccessKeyId = '';
  static const String cloudflareSecretAccessKey = '';
  static const String cloudflareBucketName = 'trace-raffine-files';
  static const String cloudflareCustomDomain = 'files.trace-raffine.com';
  
  // Environment
  static const bool isProduction = false;
  static const bool isDevelopment = true;
}
