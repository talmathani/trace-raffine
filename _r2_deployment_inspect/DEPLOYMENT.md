# TR R2 Presign Upload Function

## Runtime

Node.js / Appwrite Function

## Required Environment Variables

R2_ACCOUNT_ID
R2_ACCESS_KEY_ID
R2_SECRET_ACCESS_KEY
R2_BUCKET_NAME

## Security

- R2 credentials must exist only in Appwrite Function environment variables.
- Never place R2 credentials in Flutter/Dart.
- Never place R2 credentials in Git.
- Never place R2 credentials in the generated upload URL.
- Presigned URL lifetime: 300 seconds.
- Upload operation: S3 PutObject.
- Content-Type is restricted by an explicit allowlist.
- Object key is generated server-side.

## Upload Flow

Flutter
    |
    | request filename + contentType
    v
Appwrite Function
    |
    | generate presigned PUT URL
    v
Cloudflare R2
    |
    | direct PUT from client
    v
R2 Object

Only fileKey is subsequently stored in Appwrite Database.

## Required R2 Endpoint

https://<R2_ACCOUNT_ID>.r2.cloudflarestorage.com

## Important

The R2 access key must have only the minimum R2 bucket permissions required
for this Function.

The Function does not proxy file bytes.
