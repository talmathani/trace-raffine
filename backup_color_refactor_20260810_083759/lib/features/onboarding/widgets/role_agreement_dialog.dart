import 'package:flutter/material.dart';

import '../../auth/login_screen.dart';
import '../../../core/theme/app_theme.dart';

class RoleAgreementDialog extends StatelessWidget {
  const RoleAgreementDialog({
    super.key,
    required this.role,
    required this.onAccepted,
  });

  final UserRole role;
  final VoidCallback onAccepted;

  String get _title {
    switch (role) {
      case UserRole.customer:
        return 'أهلاً بك في عالم TRACÉ RAFINÉ';
      case UserRole.designer:
        return 'اتفاقية انضمام المصممين | TRACÉ RAFINÉ';
      case UserRole.administration:
        return 'اتفاقية الاستخدام الإداري | TRACÉ RAFINÉ';
    }
  }

  String get _introduction {
    switch (role) {
      case UserRole.customer:
        return 'عزيزنا العميل، مرحباً بك في «المسار الراقي». '
            'يسعدنا انضمامك إلى مجتمع يجمع بين أصالة التطريز '
            'وأعلى مستويات الفخامة الرقمية. نعدك بتجربة استثنائية '
            'واقتناء تصاميم صُممت بكل دقة لتلبي تطلعاتك.';
      case UserRole.designer:
        return 'أهلاً بك كشريك إبداعي في «المسار الراقي». '
            'لنضمن الحفاظ على اسم المنصة وتقديم أعلى معايير الجودة '
            'لعملائنا، يُرجى الاطلاع والموافقة على الشروط والأحكام '
            'التالية قبل البدء بنشر تصاميمك.';
      case UserRole.administration:
        return 'مرحباً بك في مساحة الإدارة الخاصة بمنصة TRACÉ RAFINÉ. '
            'هذه المساحة مخصصة لإدارة المنصة ومراجعة العمليات '
            'وفق أعلى معايير الدقة والأمان والسرية.';
    }
  }

  List<Widget> get _sections {
    switch (role) {
      case UserRole.customer:
        return const [
          _AgreementSection(
            number: '1',
            title: 'نظام الحماية والأمان',
            body:
                'تخضع المحتويات الرقمية لوسائل حماية تقنية مناسبة '
                'لمنع الاستخدام غير المصرح به أو إعادة توزيع الملفات. '
                'قد تؤدي محاولات التحايل على أنظمة الحماية إلى تقييد '
                'الوصول إلى الحساب وفق سياسات المنصة.',
          ),
          _AgreementSection(
            number: '2',
            title: 'سياسة المنتجات الرقمية',
            body:
                'جميع التصاميم والملفات المتاحة على المنصة هي منتجات '
                'رقمية. وبمجرد إتمام عملية الشراء وتسليم المحتوى الرقمي، '
                'تُعامل العملية وفق سياسة المنتجات الرقمية المعتمدة '
                'على المنصة، مع مراعاة الحالات التي يفرض فيها القانون '
                'المعمول به خلاف ذلك.',
          ),
        ];

      case UserRole.designer:
        return const [
          _AgreementSection(
            number: '1',
            title: 'بوابة الجودة الصارمة',
            body:
                'تخضع جميع الملفات المرفوعة للمراجعة الفنية والبرمجية '
                'قبل النشر. يجب أن تكون الملفات خالية من الأخطاء '
                'الميكانيكية ومهيأة وفق معايير الرقمنة المعتمدة. '
                'أي ملف لا يستوفي المعايير قد يتم رفضه مع توضيح '
                'الأسباب التقنية اللازمة للتعديل.',
          ),
          _AgreementSection(
            number: '2',
            title: 'الأرباح والعمولات',
            body:
                'تقتطع المنصة نسبة 20% من قيمة كل عملية بيع للتصميم، '
                'ويحصل المصمم على 80% وفق آلية التسوية والسحب '
                'المعتمدة في لوحة التحكم.',
          ),
          _AgreementSection(
            number: '3',
            title: 'الملكية الفكرية',
            body:
                'يتعهد المصمم بامتلاكه الحقوق اللازمة للرقمنة والتصميم '
                'المرفوع، ويتحمل مسؤولية أي انتهاك لحقوق الملكية الفكرية '
                'أو حقوق الغير ناتج عن المحتوى الذي يقوم برفعه.',
          ),
        ];

      case UserRole.administration:
        return const [
          _AgreementSection(
            number: '1',
            title: 'صلاحيات الإدارة',
            body:
                'تستخدم صلاحيات الإدارة حصراً لأغراض تشغيل المنصة '
                'ومراجعة المحتوى والطلبات والحسابات وفق الصلاحيات '
                'الممنوحة لكل مسؤول.',
          ),
          _AgreementSection(
            number: '2',
            title: 'السرية والأمان',
            body:
                'يلتزم المسؤول بالحفاظ على سرية بيانات المنصة '
                'والمستخدمين وعدم مشاركة معلومات الدخول أو البيانات '
                'الإدارية مع أي طرف غير مخول.',
          ),
          _AgreementSection(
            number: '3',
            title: 'المساءلة',
            body:
                'تسجل العمليات الإدارية المهمة لأغراض الأمان والتدقيق، '
                'ويتحمل كل مستخدم مسؤولية استخدام الصلاحيات الممنوحة '
                'له ضمن نطاق عمله.',
          ),
        ];
    }
  }

  String get _buttonText {
    switch (role) {
      case UserRole.customer:
        return 'أوافق وأبدأ التصفح';
      case UserRole.designer:
        return 'أوافق وألتزم بالشروط والمعايير';
      case UserRole.administration:
        return 'أوافق وأدخل إلى مساحة الإدارة';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.burgundyBlack,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: AppTheme.softRose.withValues(alpha: 0.35),
              ),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 40,
                  spreadRadius: 4,
                  offset: Offset(0, 18),
                  color: Colors.black54,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 18),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Text(
                            _introduction,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                              color: AppTheme.mutedIvory,
                              height: 1.9,
                            ),
                          ),
                          const SizedBox(height: 22),
                          ..._sections,
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.obsidian.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      'بالضغط على زر الموافقة، فأنت تقر باطلاعك على '
                      'السياسات والشروط الخاصة بدورك داخل المنصة '
                      'وموافقتك عليها.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11.5,
                        color: AppTheme.mutedText,
                        height: 1.7,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: onAccepted,
                      child: Text(
                        _buttonText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Text(
          'TRACÉ RAFINÉ',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'CormorantGaramond',
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: AppTheme.warmIvory,
            letterSpacing: 3.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(width: 58, height: 1, color: AppTheme.softRose),
        const SizedBox(height: 16),
        Text(
          _title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: AppTheme.warmIvory,
          ),
        ),
      ],
    );
  }
}

class _AgreementSection extends StatelessWidget {
  const _AgreementSection({
    required this.number,
    required this.title,
    required this.body,
  });

  final String number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.obsidian.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.softRose.withValues(alpha: 0.55),
              ),
            ),
            child: Text(
              number,
              style: const TextStyle(
                fontFamily: 'CormorantGaramond',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.softRose,
              ),
            ),
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
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.warmIvory,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  body,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.5,
                    color: AppTheme.mutedText,
                    height: 1.75,
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
