import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as image_processing;
import 'package:flutter/material.dart';
import 'package:trace_raffine/core/responsive/app_breakpoints.dart';
import 'package:trace_raffine/core/theme/app_theme.dart';
import 'package:trace_raffine/core/ui/maison_surface.dart';
import 'package:trace_raffine/core/ui/maison_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_raffine/core/ui/editorial_button.dart';

import '../auth/domain/repositories/auth_repository.dart';
import 'domain/usecases/create_designer_design.dart';

class DesignerUploadScreen extends StatefulWidget {
  const DesignerUploadScreen({super.key});

  @override
  State<DesignerUploadScreen> createState() => _DesignerUploadScreenState();
}

class _DesignerUploadScreenState extends State<DesignerUploadScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  String? _selectedCategoryId;
  static const _categories = <Map<String, String>>[
    {'id': 'evening_couture', 'name': 'فساتين السهرة والهوت كوتور'},
    {'id': 'saree', 'name': 'تصاميم الساري الهندي'},
    {'id': 'abayas', 'name': 'العبايات والبالطوهات'},
    {'id': 'jalabiyas', 'name': 'الجلابيات والمخاور'},
    {'id': 'distributed', 'name': 'تصاميم موزعة'},
    {'id': 'borders', 'name': 'تصاميم الحواشي'},
    {'id': 'logos', 'name': 'الشعارات واللوغوهات'},
    {'id': 'new_week', 'name': 'جديد الأسبوع'},
  ];
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stitchDetailsController = TextEditingController();
  final _beadDetailsController = TextEditingController();
  final _sequinDetailsController = TextEditingController();
  final _additionalDetailsController = TextEditingController();

  Uint8List? _designImageBytes;
  String? _designImageName;

  Uint8List? _embroideryFileBytes;
  String? _embroideryFileName;

  bool _isSubmitting = false;
  bool _isCompressingPreview = false;

  static const int _previewCompressionThresholdBytes = 2 * 1024 * 1024;

  @override
  void dispose() {
    _titleController.dispose();

    _descriptionController.dispose();
    _priceController.dispose();
    _stitchDetailsController.dispose();
    _beadDetailsController.dispose();
    _sequinDetailsController.dispose();
    _additionalDetailsController.dispose();
    super.dispose();
  }

  Future<void> _pickDesignImage() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: <String>['jpg', 'jpeg', 'png', 'webp'],
      withData: true,
    );

    if (!mounted || result == null || result.files.isEmpty) {
      return;
    }

    final file = result.files.single;

    if (file.bytes == null || file.bytes!.isEmpty) {
      _showMessage('تعذر قراءة ملف الصورة.');
      return;
    }

    final originalBytes = file.bytes!;
    final compressionStopwatch = Stopwatch()..start();

    if (mounted) {
      setState(() {
        _isCompressingPreview = true;
      });
    }

    // Give the browser one frame before any CPU-heavy image work.
    await Future<void>.delayed(Duration.zero);
    final preparation = _preparePreviewImage(
      bytes: originalBytes,
      originalName: file.name,
    );
    compressionStopwatch.stop();

    debugPrint(
      'DESIGN PERFORMANCE: preview compression '
      'originalBytes=${originalBytes.length} '
      'compressedBytes=${preparation.bytes.length} '
      'compressed=${preparation.wasCompressed} '
      'elapsedMs=${compressionStopwatch.elapsedMilliseconds}',
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _designImageBytes = preparation.bytes;
      _designImageName = preparation.fileName;
      _isCompressingPreview = false;
    });
  }

  _PreviewImagePreparation _preparePreviewImage({
    required Uint8List bytes,
    required String originalName,
  }) {
    // Avoid decoding ordinary sub-2 MB previews on the UI thread. This is
    // the common case and keeps Flutter Web responsive immediately after pick.
    if (bytes.length <= _previewCompressionThresholdBytes) {
      return _PreviewImagePreparation(
        bytes: bytes,
        fileName: originalName,
        wasCompressed: false,
      );
    }

    try {
      final decoded = image_processing.decodeImage(bytes);
      if (decoded == null) {
        return _PreviewImagePreparation(
          bytes: bytes,
          fileName: originalName,
          wasCompressed: false,
        );
      }

      final resized = decoded.width > 1600
          ? image_processing.copyResize(decoded, width: 1600)
          : decoded;
      final encoded = image_processing.encodeJpg(resized, quality: 82);
      return _PreviewImagePreparation(
        bytes: Uint8List.fromList(encoded),
        fileName: 'preview.jpg',
        wasCompressed: true,
      );
    } catch (error) {
      debugPrint('DESIGN PERFORMANCE: preview compression FAILED error=$error');
      return _PreviewImagePreparation(
        bytes: bytes,
        fileName: originalName,
        wasCompressed: false,
      );
    }
  }

  Future<void> _pickEmbroideryFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.any,
      withData: true,
    );

    if (!mounted || result == null || result.files.isEmpty) {
      return;
    }

    final file = result.files.single;

    if (file.bytes == null || file.bytes!.isEmpty) {
      _showMessage('تعذر قراءة ملف التطريز.');
      return;
    }

    setState(() {
      _embroideryFileBytes = file.bytes;
      _embroideryFileName = file.name;
    });
  }

  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }

    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final imageBytes = _designImageBytes;
    final imageName = _designImageName;
    final embroideryBytes = _embroideryFileBytes;
    final embroideryName = _embroideryFileName;

    if (imageBytes == null || imageName == null) {
      _showMessage('يرجى اختيار صورة التصميم.');
      return;
    }

    if (embroideryBytes == null || embroideryName == null) {
      _showMessage('يرجى اختيار ملف التطريز.');
      return;
    }

    final authRepository = context.read<AuthRepository>();
    final currentUser = authRepository.currentUser;

    if (currentUser == null) {
      _showMessage('يجب تسجيل الدخول قبل رفع التصميم.');
      return;
    }

    final price = double.tryParse(
      _priceController.text.trim().replaceAll(',', '.'),
    );

    if (price == null || price < 0) {
      _showMessage('يرجى إدخال سعر صحيح.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final createDesignerDesign = context.read<CreateDesignerDesign>();

      await createDesignerDesign(
        designerId: currentUser.id,
        title: _titleController.text.trim(),
        category: _selectedCategoryId!,
        description: _descriptionController.text.trim(),
        price: price,
        fileExtension: _extensionOf(embroideryName),
        designImageBytes: imageBytes,
        designImageName: imageName,
        embroideryFileBytes: embroideryBytes,
        embroideryFileName: embroideryName,
        stitchDetails: _optionalValue(_stitchDetailsController.text),
        beadDetails: _optionalValue(_beadDetailsController.text),
        sequinDetails: _optionalValue(_sequinDetailsController.text),
        additionalDetails: _optionalValue(_additionalDetailsController.text),
      );

      if (!mounted) {
        return;
      }

      _resetForm();

      _showMessage('تم إرسال التصميم للمراجعة بنجاح.', success: true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage('تعذر رفع التصميم: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();

    _titleController.clear();
    _selectedCategoryId = null;
    _descriptionController.clear();
    _priceController.clear();
    _stitchDetailsController.clear();
    _beadDetailsController.clear();
    _sequinDetailsController.clear();
    _additionalDetailsController.clear();

    setState(() {
      _designImageBytes = null;
      _designImageName = null;
      _embroideryFileBytes = null;
      _embroideryFileName = null;
    });
  }

  String? _optionalValue(String value) {
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }

  String _extensionOf(String fileName) {
    final normalized = fileName.trim();

    if (!normalized.contains('.')) {
      return 'bin';
    }

    final parts = normalized.split('.');
    final extension = parts.last.trim().toLowerCase();

    return extension.isEmpty ? 'bin' : extension;
  }

  void _showMessage(String message, {bool success = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: success
              ? AppTheme.statusSuccess
              : AppTheme.statusRejected,
        ),
      );
  }

  InputDecoration _decoration(String label, {String? hint, IconData? icon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon == null ? null : Icon(icon),
      filled: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 2, vertical: 13),
      border: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppTheme.divider),
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppTheme.divider),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppTheme.roseBurgundy, width: 1.4),
      ),
      errorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppTheme.statusRejected),
      ),
      focusedErrorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppTheme.statusRejected, width: 1.4),
      ),
    );
  }

  Widget _buildFileCard({
    required String title,
    required String description,
    required IconData icon,
    required String? fileName,
    required VoidCallback? onPressed,
  }) {
    final hasFile = fileName != null && fileName.trim().isNotEmpty;

    return MaisonSurface(
      radius: AppTheme.editorialListRadius,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, size: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasFile ? fileName : description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            EditorialButton(
              onPressed: _isSubmitting ? null : onPressed,
              icon: Icon(hasFile ? Icons.refresh : Icons.upload_file),
              label: hasFile ? 'تغيير الملف' : 'اختيار الملف',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    final bytes = _designImageBytes;

    if (bytes == null || bytes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.memory(
            bytes,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) {
              return const Center(child: Text('تعذر عرض معاينة الصورة.'));
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MaisonAppBar(title: 'رفع تصميم جديد'),
      body: Form(
        key: _formKey,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: context.responsiveContentMaxWidth,
            ),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                context.responsiveHorizontalPadding,
                context.isCompact ? 16 : 24,
                context.responsiveHorizontalPadding,
                40,
              ),
              children: [
                Text(
                  'بيانات التصميم',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'أدخل بيانات التصميم وارفع الملفات الأصلية لإرسالها للمراجعة.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _titleController,
                  enabled: !_isSubmitting,
                  textInputAction: TextInputAction.next,
                  decoration: _decoration(
                    'اسم التصميم',
                    hint: 'مثال: Floral Elegance',
                    icon: Icons.title,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'اسم التصميم مطلوب.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategoryId,
                  decoration: _decoration(
                    'القسم',
                    hint: 'اختر القسم المناسب للتصميم',
                    icon: Icons.category_outlined,
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category['id'],
                      child: Text(category['name']!),
                    );
                  }).toList(),
                  onChanged: _isSubmitting
                      ? null
                      : (value) {
                          setState(() {
                            _selectedCategoryId = value;
                          });
                        },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى اختيار قسم التصميم.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _descriptionController,
                  enabled: !_isSubmitting,
                  minLines: 3,
                  maxLines: 6,
                  decoration: _decoration(
                    'الوصف',
                    hint: 'وصف مختصر للتصميم.',
                    icon: Icons.description_outlined,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'الوصف مطلوب.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _priceController,
                  enabled: !_isSubmitting,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.done,
                  decoration: _decoration(
                    'السعر',
                    hint: '0.00',
                    icon: Icons.payments_outlined,
                  ),
                  validator: (value) {
                    final normalized = value?.trim() ?? '';

                    if (normalized.isEmpty) {
                      return 'السعر مطلوب.';
                    }

                    final price = double.tryParse(
                      normalized.replaceAll(',', '.'),
                    );

                    if (price == null || price < 0) {
                      return 'أدخل سعرًا صحيحًا.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildFileCard(
                  title: 'صورة التصميم',
                  description: 'JPG / JPEG / PNG / WEBP',
                  icon: Icons.image_outlined,
                  fileName: _designImageName,
                  onPressed: (_isSubmitting || _isCompressingPreview)
                      ? null
                      : () {
                          _pickDesignImage();
                        },
                ),
                _buildImagePreview(),
                const SizedBox(height: 12),
                _buildFileCard(
                  title: 'ملف التطريز',
                  description: 'ملف التطريز الأصلي بأي امتداد مدعوم.',
                  icon: Icons.file_present_outlined,
                  fileName: _embroideryFileName,
                  onPressed: _isSubmitting
                      ? null
                      : () {
                          _pickEmbroideryFile();
                        },
                ),
                const SizedBox(height: 20),
                ExpansionTile(
                  title: const Text('تفاصيل إضافية'),
                  childrenPadding: const EdgeInsets.only(bottom: 8),
                  children: [
                    TextFormField(
                      controller: _stitchDetailsController,
                      enabled: !_isSubmitting,
                      decoration: _decoration(
                        'تفاصيل الغرز',
                        icon: Icons.timeline_outlined,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _beadDetailsController,
                      enabled: !_isSubmitting,
                      decoration: _decoration(
                        'تفاصيل الخرز',
                        icon: Icons.circle_outlined,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _sequinDetailsController,
                      enabled: !_isSubmitting,
                      decoration: _decoration(
                        'تفاصيل الترتر',
                        icon: Icons.auto_awesome_outlined,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _additionalDetailsController,
                      enabled: !_isSubmitting,
                      minLines: 2,
                      maxLines: 4,
                      decoration: _decoration(
                        'تفاصيل إضافية',
                        icon: Icons.notes_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 56,
                  child: EditorialButton(
                    onPressed: _isSubmitting ? null : _submit,
                    icon: const Icon(Icons.cloud_upload_outlined),
                    label: _isSubmitting
                        ? 'جارٍ رفع التصميم...'
                        : 'إرسال التصميم للمراجعة',
                    loading: _isSubmitting,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'سيتم حفظ التصميم بحالة "قيد المراجعة" بعد نجاح الرفع.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewImagePreparation {
  final Uint8List bytes;
  final String fileName;
  final bool wasCompressed;

  const _PreviewImagePreparation({
    required this.bytes,
    required this.fileName,
    required this.wasCompressed,
  });
}
