import crypto from "node:crypto";

import {
  S3Client,
  PutObjectCommand,
} from "@aws-sdk/client-s3";

import {
  getSignedUrl,
} from "@aws-sdk/s3-request-presigner";

const ACCOUNT_ID = (process.env.R2_ACCOUNT_ID ?? "").trim();
const ACCESS_KEY_ID = process.env.R2_ACCESS_KEY_ID;
const SECRET_ACCESS_KEY = process.env.R2_SECRET_ACCESS_KEY;
const BUCKET_NAME = process.env.R2_BUCKET_NAME;

const URL_EXPIRATION_SECONDS = 300;
const MAX_FILENAME_LENGTH = 180;

const ALLOWED_CONTENT_TYPES = new Set([
  "image/jpeg",
  "image/png",
  "image/webp",
  "image/gif",
  "video/mp4",
  "video/webm",
  "video/quicktime",
]);

const s3 = new S3Client({
  region: "auto",
  endpoint: `https://${ACCOUNT_ID}.r2.cloudflarestorage.com`,
  credentials: {
    accessKeyId: ACCESS_KEY_ID ?? "",
    secretAccessKey: SECRET_ACCESS_KEY ?? "",
  },
});

function sanitizeFilename(filename) {
  return filename
    .normalize("NFKC")
    .replace(/[^a-zA-Z0-9._-]/g, "_")
    .replace(/_+/g, "_")
    .replace(/^[_\.]+|[_\.]+$/g, "")
    .slice(0, MAX_FILENAME_LENGTH);
}

function extensionFromFilename(filename) {
  const index = filename.lastIndexOf(".");

  if (index === -1) {
    return "";
  }

  return filename
    .slice(index)
    .toLowerCase()
    .replace(/[^a-z0-9.]/g, "");
}

function generateObjectKey(filename, contentType) {
  const safeFilename = sanitizeFilename(filename);

  const extension =
    extensionFromFilename(safeFilename);

  const timestamp =
    new Date()
      .toISOString()
      .replace(/[-:.TZ]/g, "");

  const randomId =
    crypto.randomUUID();

  const prefix =
    contentType.startsWith("video/")
      ? "media/video"
      : "media/image";

  return `${prefix}/${timestamp}-${randomId}${extension}`;
}

function respond(res, statusCode, body) {
  return res.json(body, statusCode);
}

export default async ({ req, res, log, error }) => {
  try {
    if (req.method !== "POST") {
      return respond(res, 405, {
        success: false,
        error: "METHOD_NOT_ALLOWED",
      });
    }

    if (
      !ACCOUNT_ID ||
      !ACCESS_KEY_ID ||
      !SECRET_ACCESS_KEY ||
      !BUCKET_NAME
    ) {
      error(
        "R2 configuration is incomplete.",
      );

      return respond(res, 500, {
        success: false,
        error: "R2_CONFIGURATION_ERROR",
      });
    }

    let payload;

    try {
      payload = req.bodyJson;

      if (!payload && req.body) {
        if (typeof req.body === "string") {
          payload = JSON.parse(req.body);
        } else if (Buffer.isBuffer(req.body)) {
          payload = JSON.parse(req.body.toString("utf8"));
        } else if (typeof req.body === "object") {
          payload = req.body;
        }
      }

      if (!payload && req.rawBody) {
        payload = JSON.parse(req.rawBody.toString("utf8"));
      }

    } catch (_) {
      payload = null;
    }

    if (
      !payload ||
      typeof payload !== "object"
    ) {
      return respond(res, 400, {
        success: false,
        error: "INVALID_JSON",
      });
    }

    const filename =
      typeof payload.filename === "string"
        ? payload.filename.trim()
        : "";

    const contentType =
      typeof payload.contentType === "string"
        ? payload.contentType.trim().toLowerCase()
        : "";

    if (!filename) {
      return respond(res, 400, {
        success: false,
        error: "FILENAME_REQUIRED",
      });
    }

    if (!contentType) {
      return respond(res, 400, {
        success: false,
        error: "CONTENT_TYPE_REQUIRED",
      });
    }

    if (
      !ALLOWED_CONTENT_TYPES.has(
        contentType,
      )
    ) {
      return respond(res, 415, {
        success: false,
        error: "CONTENT_TYPE_NOT_ALLOWED",
      });
    }

    const fileKey =
      generateObjectKey(
        filename,
        contentType,
      );

    const command =
      new PutObjectCommand({
        Bucket: BUCKET_NAME,
        Key: fileKey,
        ContentType: contentType,
      });

    const uploadUrl =
      await getSignedUrl(
        s3,
        command,
        {
          expiresIn:
            URL_EXPIRATION_SECONDS,
        },
      );

    log(
      `Presigned R2 upload issued: ${fileKey}`,
    );

    return respond(res, 200, {
      success: true,
      uploadUrl,
      fileKey,
      expiresIn:
        URL_EXPIRATION_SECONDS,
      contentType,
    });
  } catch (exception) {
    error(
      `Presign failure: ${
        exception?.message ?? exception
      }`,
    );

    return respond(res, 500, {
      success: false,
      error: "PRESIGN_FAILED",
    });
  }
};
