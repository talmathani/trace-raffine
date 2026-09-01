/// سياسة قبول ملفات التطريز في المنصة.
///
/// تُقبل جميع الملفات التي تملك امتدادًا واضحًا، بما فيها EMB وDST وDHP وDHE.
/// لا توجد قائمة حظر ثابتة للامتدادات؛ التحقق الوحيد هو وجود امتداد للملف.
abstract final class EmbroideryFilePolicy {
  static const Set<String> rejectedExtensions = <String>{};

  static bool isRejected(String fileName) {
    // محفوظة للتوافق مع الاستدعاءات القديمة، ولا ترفض أي امتداد.
    return false;
  }

  static bool isAccepted(String fileName) {
    return extensionOf(fileName).isNotEmpty;
  }

  static String extensionOf(String fileName) {
    final normalized = fileName.trim();
    final lastDot = normalized.lastIndexOf('.');
    if (lastDot < 0 || lastDot == normalized.length - 1) {
      return '';
    }
    return normalized.substring(lastDot + 1).trim().toLowerCase();
  }

  static String rejectedExtensionsLabel() {
    return 'لا يوجد';
  }
}
