import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../appwrite/appwrite_config.dart';
import '../appwrite/appwrite_service.dart';
import '../theme/app_theme.dart';

/// مكون مخصص لعرض صور Appwrite Storage بدقة وسرعة وبدون مشاكل CORS أو الصلاحيات
class AppwriteImage extends StatefulWidget {
  const AppwriteImage({
    super.key,
    required this.imageSource,
    this.bucketId,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  /// يمكن أن يكون File ID (مثل: 6a8e14bec3cd046b0294) أو رابط كامل
  final String? imageSource;
  final String? bucketId;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  static final Map<String, Uint8List> _imageCache = <String, Uint8List>{};
  static final Map<String, Future<Uint8List>> _pendingRequests =
      <String, Future<Uint8List>>{};

  static void clearCache() {
    _imageCache.clear();
    _pendingRequests.clear();
  }

  @override
  State<AppwriteImage> createState() => _AppwriteImageState();
}

class _AppwriteImageState extends State<AppwriteImage> {
  Uint8List? _bytes;
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(covariant AppwriteImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageSource != widget.imageSource ||
        oldWidget.bucketId != widget.bucketId) {
      _loadImage();
    }
  }

  String? _extractFileId(String? source) {
    if (source == null || source.trim().isEmpty) return null;
    final trimmed = source.trim();

    // إذا كان رابط Appwrite كامل
    if (trimmed.contains('/files/') && trimmed.contains('/view')) {
      final parts = trimmed.split('/files/');
      if (parts.length > 1) {
        final after = parts[1].split('/view')[0];
        return after.split('?')[0];
      }
    }

    if (trimmed.contains('/files/') && trimmed.contains('/preview')) {
      final parts = trimmed.split('/files/');
      if (parts.length > 1) {
        final after = parts[1].split('/preview')[0];
        return after.split('?')[0];
      }
    }

    // إذا كان File ID مباشر
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      return trimmed;
    }

    return null;
  }

  Future<void> _loadImage() async {
    final source = widget.imageSource?.trim();
    if (source == null || source.isEmpty) {
      if (mounted) setState(() => _hasError = true);
      return;
    }

    final fileId = _extractFileId(source);

    // إذا لم يكن من Appwrite (رابط خارجي عادي)
    if (fileId == null) {
      return;
    }

    final effectiveBucketId =
        widget.bucketId ?? AppwriteConfig.designFilesBucketId;
    final cacheKey = '$effectiveBucketId:$fileId';

    // فحص الكاش المحلي
    if (AppwriteImage._imageCache.containsKey(cacheKey)) {
      if (mounted) {
        setState(() {
          _bytes = AppwriteImage._imageCache[cacheKey];
          _isLoading = false;
          _hasError = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    }

    try {
      final request = AppwriteImage._pendingRequests.putIfAbsent(cacheKey, () {
        return AppwriteService.storage.getFileView(
          bucketId: effectiveBucketId,
          fileId: fileId,
        );
      });

      final resultBytes = await request;
      AppwriteImage._imageCache[cacheKey] = resultBytes;
      AppwriteImage._pendingRequests.remove(cacheKey);

      if (mounted) {
        setState(() {
          _bytes = resultBytes;
          _isLoading = false;
          _hasError = false;
        });
      }
    } catch (error) {
      AppwriteImage._pendingRequests.remove(cacheKey);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(12);

    final fileId = _extractFileId(widget.imageSource);

    // إذا كان رابط إنترنت عادي وليس Appwrite File
    if (fileId == null &&
        widget.imageSource != null &&
        (widget.imageSource!.startsWith('http://') ||
            widget.imageSource!.startsWith('https://'))) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: Image.network(
          widget.imageSource!,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          errorBuilder: (_, _, _) => _buildError(borderRadius),
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return _buildLoading(borderRadius);
          },
        ),
      );
    }

    if (_hasError) {
      return _buildError(borderRadius);
    }

    if (_isLoading || _bytes == null) {
      return _buildLoading(borderRadius);
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: Image.memory(
        _bytes!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => _buildError(borderRadius),
      ),
    );
  }

  Widget _buildLoading(BorderRadius radius) {
    if (widget.placeholder != null) return widget.placeholder!;
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: AppTheme.deepBurgundy,
        borderRadius: radius,
      ),
      child: const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppTheme.primaryBurgundy,
          ),
        ),
      ),
    );
  }

  Widget _buildError(BorderRadius radius) {
    if (widget.errorWidget != null) return widget.errorWidget!;
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: AppTheme.deepBurgundy,
        borderRadius: radius,
      ),
      child: const Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: AppTheme.softRose,
          size: 26,
        ),
      ),
    );
  }
}
