import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/repositories/auth_repository.dart';
import 'domain/usecases/create_designer_design.dart';

class DesignerUploadScreen extends StatefulWidget {
  const DesignerUploadScreen({super.key});

  @override
  State<DesignerUploadScreen> createState() => _DesignerUploadScreenState();
}

class _DesignerUploadScreenState extends State<DesignerUploadScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  final _stitchDetailsController = TextEditingController();
  final _beadDetailsController = TextEditingController();
  final _sequinDetailsController = TextEditingController();
  final _materialDetailsController = TextEditingController();
  final _colorDetailsController = TextEditingController();
  final _productionNotesController = TextEditingController();
  final _additionalDetailsController = TextEditingController();

  String _selectedCategory = 'فساتين السهرة والهوت كوتور';

  PlatformFile? _designImage;
  PlatformFile? _embroideryFile;

  bool _isSubmitting = false;

  late CreateDesignerDesign _createDesignerDesign;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _createDesignerDesign = context.read<CreateDesignerDesign>();
  }

  static const List<String> _categories = [
    'فساتين السهرة والهوت كوتور',
    'تصاميم الساري الهندي',
    'العبايات والبالطوهات',
    'الجلابيات والمخاور',
    'تصاميم موزعة',
    'تصاميم الحواشي',
    'الشعارات واللوغوهات',
    'جديد الأسبوع',
  ];

  static const List<String> _embroideryExtensions = [
    'dst',
    'emb',
    'dhp',
    'pes',
    'jef',
    'exp',
    'vp3',
    'hus',
    'xxx',
    'tap',
    'sew',
    'pcs',
    'kwk',
    'art',
    'pes',
    'dsb',
    'dat',
    'tbf',
    'shv',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stitchDetailsController.dispose();
    _beadDetailsController.dispose();
    _sequinDetailsController.dispose();
    _materialDetailsController.dispose();
    _colorDetailsController.dispose();
    _productionNotesController.dispose();
    _additionalDetailsController.dispose();
    super.dispose();
  }

  Future<void> _pickDesignImage() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result == null || result.files.isEmpty || !mounted) {
      return;
    }

    setState(() {
      _designImage = result.files.single;
    });
  }

  Future<void> _pickEmbroideryFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: _embroideryExtensions,
      allowMultiple: false,
      withData: true,
    );

    if (result == null || result.files.isEmpty || !mounted) {
      return;
    }

    setState(() {
      _embroideryFile = result.files.single;
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    debugPrint('=== DESIGN FORM INPUT DIAGNOSTIC ===');
    debugPrint('TITLE CONTROLLER: ""');
    debugPrint('DESCRIPTION CONTROLLER: ""');
    debugPrint('PRICE CONTROLLER: ""');
    debugPrint('CATEGORY: ""');
    debugPrint('====================================');
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_designImage == null) {
      _showMessage('يرجى اختيار صورة التصميم.');
      return;
    }

    if (_embroideryFile == null) {
      _showMessage('يرجى اختيار ملف التطريز الرقمي.');
      return;
    }

    final currentUser = context.read<AuthRepository>().currentUser;

    if (currentUser == null) {
      _showMessage('يجب تسجيل الدخول كمصمم قبل رفع التصميم.');
      return;
    }

    final designImageBytes = _designImage!.bytes;
    final embroideryFileBytes = _embroideryFile!.bytes;

    if (designImageBytes == null || designImageBytes.isEmpty) {
      _showMessage('تعذر قراءة بيانات صورة التصميم.');
      return;
    }

    if (embroideryFileBytes == null || embroideryFileBytes.isEmpty) {
      _showMessage('تعذر قراءة ملف التطريز الرقمي.');
      return;
    }

    final price = double.tryParse(
      _priceController.text.trim().replaceAll(',', '.'),
    );

    if (price == null || price < 0) {
      _showMessage('يرجى إدخال سعر صحيح.');
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final designId = await _createDesignerDesign(
        designerId: currentUser.id,
        title: _titleController.text.trim(),
        category: _selectedCategory,
        description: _descriptionController.text.trim(),
        price: price,
        fileExtension: _extensionOf(_embroideryFile!.name),
        designImageBytes: designImageBytes,
        designImageName: _designImage!.name,
        embroideryFileBytes: embroideryFileBytes,
        embroideryFileName: _embroideryFile!.name,
        stitchDetails: _stitchDetailsController.text.trim(),
        beadDetails: _beadDetailsController.text.trim(),
        sequinDetails: _sequinDetailsController.text.trim(),
        additionalDetails: _additionalDetailsController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
      });

      _showMessage('تم إرسال التصميم للمراجعة بنجاح. رقم التصميم: $designId');
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
      });

      _showMessage('تعذر إرسال التصميم. يرجى المحاولة مرة أخرى.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(fontFamily: 'Cairo')),
        ),
      );
  }

  String _extensionOf(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'غير معروف';
    }

    final parts = name.split('.');
    if (parts.length < 2) {
      return 'غير معروف';
    }

    return parts.last.toUpperCase();
  }

  String _fileSizeLabel(int? bytes) {
    if (bytes == null || bytes <= 0) {
      return 'الحجم غير متاح';
    }

    if (bytes < 1024) {
      return '$bytes B';
    }

    final kb = bytes / 1024;

    if (kb < 1024) {
      return '${kb.toStringAsFixed(1)} KB';
    }

    final mb = kb / 1024;

    if (mb < 1024) {
      return '${mb.toStringAsFixed(1)} MB';
    }

    final gb = mb / 1024;
    return '${gb.toStringAsFixed(2)} GB';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('رفع تصميم جديد')),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildUploadHeader(),
              const SizedBox(height: 24),

              _buildSectionTitle(
                icon: Icons.info_outline_rounded,
                title: 'بيانات التصميم',
                subtitle: 'المعلومات الأساسية التي ستظهر للعميل.',
              ),

              const SizedBox(height: 14),

              _buildTextField(
                controller: _titleController,
                label: 'اسم التصميم',
                hint: 'أدخل اسم التصميم',
                icon: Icons.title_rounded,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'يرجى إدخال اسم التصميم';
                  }

                  if (value.trim().length < 3) {
                    return 'اسم التصميم قصير جدًا';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _descriptionController,
                label: 'وصف التصميم',
                hint: 'اكتب وصفًا واضحًا للتصميم ومميزاته',
                icon: Icons.description_outlined,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'يرجى إدخال وصف التصميم';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'القسم',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: _categories
                    .map(
                      (category) => DropdownMenuItem<String>(
                        value: category,
                        child: Text(category, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _priceController,
                label: 'السعر',
                hint: 'أدخل سعر التصميم',
                icon: Icons.payments_outlined,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'يرجى إدخال السعر';
                  }

                  final price = double.tryParse(value.trim());

                  if (price == null || price < 0) {
                    return 'أدخل سعرًا صحيحًا';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 28),

              _buildSectionTitle(
                icon: Icons.attach_file_rounded,
                title: 'ملفات التصميم',
                subtitle: 'ارفع صورة العرض وملف التطريز الأصلي.',
              ),

              const SizedBox(height: 14),

              _buildFilePicker(
                icon: Icons.image_outlined,
                title: 'صورة التصميم',
                subtitle: _designImage == null
                    ? 'JPG, JPEG, PNG أو WEBP'
                    : '${_designImage!.name} · ${_fileSizeLabel(_designImage!.size)}',
                buttonText: _designImage == null
                    ? 'اختيار الصورة'
                    : 'تغيير الصورة',
                onPressed: _pickDesignImage,
                selected: _designImage != null,
                extension: _designImage == null
                    ? null
                    : _extensionOf(_designImage!.name),
              ),

              const SizedBox(height: 12),

              _buildFilePicker(
                icon: Icons.insert_drive_file_outlined,
                title: 'ملف التطريز الرقمي',
                subtitle: _embroideryFile == null
                    ? 'DST, EMB, DHP, PES, JEF, EXP, VP3, HUS وغيرها'
                    : '${_embroideryFile!.name} · ${_fileSizeLabel(_embroideryFile!.size)}',
                buttonText: _embroideryFile == null
                    ? 'اختيار الملف'
                    : 'تغيير الملف',
                onPressed: _pickEmbroideryFile,
                selected: _embroideryFile != null,
                extension: _embroideryFile == null
                    ? null
                    : _extensionOf(_embroideryFile!.name),
              ),

              const SizedBox(height: 28),

              _buildNotesSection(),

              const SizedBox(height: 28),

              _buildReviewNotice(),

              const SizedBox(height: 24),

              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submit,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 19,
                          height: 19,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded),
                  label: Text(
                    _isSubmitting
                        ? 'جاري تجهيز التصميم...'
                        : 'إرسال التصميم للمراجعة',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadHeader() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppTheme.deepBurgundy, AppTheme.burgundyBlack],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.divider),
      ),
      child: const Row(
        children: [
          Icon(Icons.cloud_upload_rounded, color: AppTheme.softRose, size: 34),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إضافة تصميم جديد',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.warmIvory,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'أدخل بيانات التصميم وارفع ملفاته ليتم إرسالها إلى فريق المراجعة.',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: AppTheme.mutedIvory,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppTheme.deepBurgundy,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: AppTheme.divider),
          ),
          child: Icon(icon, color: AppTheme.softRose, size: 21),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.warmIvory,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  color: AppTheme.mutedText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
      ),
    );
  }

  Widget _buildFilePicker({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onPressed,
    required bool selected,
    required String? extension,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.burgundyBlack,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected
              ? AppTheme.softRose.withValues(alpha: 0.55)
              : AppTheme.divider,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.deepBurgundy,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppTheme.softRose),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.warmIvory,
                        ),
                      ),
                    ),
                    if (extension != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.deepBurgundy,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          extension,
                          style: const TextStyle(
                            fontFamily: 'CormorantGaramond',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.softRose,
                            letterSpacing: 0.7,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    color: AppTheme.mutedText,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: onPressed,
                  icon: const Icon(Icons.folder_open_rounded, size: 17),
                  label: Text(
                    buttonText,
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.burgundyBlack,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.notes_rounded, color: AppTheme.softRose),
              SizedBox(width: 10),
              Text(
                'ملاحظات وتعليمات',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.warmIvory,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'أضف أي ملاحظات أو تعليمات تريد إرفاقها مع التصميم.',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              color: AppTheme.mutedText,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          _buildTextField(
            controller: _additionalDetailsController,
            label: 'الملاحظات والتعليمات',
            hint: 'اكتب الملاحظات أو تعليمات التنفيذ هنا',
            icon: Icons.edit_note_rounded,
            maxLines: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewNotice() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.deepBurgundy,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.softRose.withValues(alpha: 0.28)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.fact_check_outlined, color: AppTheme.softRose, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مراجعة الإدارة',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.warmIvory,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'بعد الإرسال سيظهر التصميم لديك بحالة «قيد المراجعة» إلى أن يتم اعتماده أو رفضه من فريق الإدارة.',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    color: AppTheme.mutedIvory,
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
