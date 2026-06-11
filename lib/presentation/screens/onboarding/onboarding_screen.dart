import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/services/prefs.dart';
import '../../../core/services/startup.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../widgets/hadhrami_decor.dart';
import '../../widgets/lang_toggle.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _Slide {
  final IconData? icon;
  final bool skyline;
  final Gradient gradient;
  final String titleAr;
  final String titleEn;
  final String bodyAr;
  final String bodyEn;
  const _Slide({
    this.icon,
    this.skyline = false,
    required this.gradient,
    required this.titleAr,
    required this.titleEn,
    required this.bodyAr,
    required this.bodyEn,
  });
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pc = PageController();
  int _i = 0;

  static const List<_Slide> _slides = [
    _Slide(
      skyline: true,
      gradient: AppColors.sunsetGradient,
      titleAr: 'أهلاً بك في غاز فلو',
      titleEn: 'Welcome to GasFlow',
      bodyAr:
          'خدمة توصيل الغاز المنزلي بروح حضرمية عصرية، تصلك أينما كنت في وادي حضرموت.',
      bodyEn:
          'Home gas delivery with a modern Hadhrami spirit, reaching you anywhere in Wadi Hadhramaut.',
    ),
    _Slide(
      icon: Icons.location_on_rounded,
      gradient: AppColors.brandGradient,
      titleAr: 'أقرب موزّع على الخريطة',
      titleEn: 'Nearest distributor on the map',
      bodyAr:
          'شاهد الموزّعين القريبين منك على خريطة حقيقية، وحدّد موقعك بضغطة واحدة.',
      bodyEn:
          'See nearby distributors on a real map, and set your location with a single tap.',
    ),
    _Slide(
      icon: Icons.local_fire_department_rounded,
      gradient: AppColors.sunsetGradient,
      titleAr: 'اطلب وتتبّع بسهولة',
      titleEn: 'Order and track easily',
      bodyAr:
          'اطلب أسطوانة الغاز وتابع حالة طلبك لحظة بلحظة حتى تصل إلى بابك.',
      bodyEn:
          'Order your gas cylinder and follow its status in real time, until it reaches your door.',
    ),
  ];

  bool get _last => _i == _slides.length - 1;

  Future<void> _finish() async {
    await Prefs.setOnboardingSeen(true);
    if (!mounted) return;
    await goToStartDestination(context);
  }

  void _next() {
    if (_last) {
      _finish();
      return;
    }
    _pc.nextPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HadhramiBackground(
        patternOpacity: 0.05,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const LangToggle(dark: true),
                    TextButton(
                      onPressed: _finish,
                      child: Text(
                        L10n.isAr ? 'تخطّي' : 'Skip',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pc,
                  itemCount: _slides.length,
                  onPageChanged: (v) => setState(() => _i = v),
                  itemBuilder: (_, idx) => _SlideView(slide: _slides[idx]),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int d = 0; d < _slides.length; d++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOut,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: d == _i ? 26 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: d == _i
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primaryDark,
                      elevation: 6,
                    ),
                    onPressed: _next,
                    child: Text(
                      _last
                          ? (L10n.isAr ? 'ابدأ الآن' : 'Get started')
                          : (L10n.isAr ? 'التالي' : 'Next'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  final _Slide slide;
  const _SlideView({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Art(slide: slide),
          const SizedBox(height: 40),
          Text(
            L10n.isAr ? slide.titleAr : slide.titleEn,
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineLarge.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 14),
          Text(
            L10n.isAr ? slide.bodyAr : slide.bodyEn,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _Art extends StatelessWidget {
  final _Slide slide;
  const _Art({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        gradient: slide.gradient,
        borderRadius: BorderRadius.circular(44),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: HadhramiPatternPainter(
              color: Colors.white,
              opacity: 0.14,
              tile: 32,
            ),
          ),
          if (slide.skyline)
            Padding(
              padding: const EdgeInsets.only(top: 70, left: 10, right: 10),
              child: CustomPaint(
                painter: ShibamSkylinePainter(
                  color: AppColors.warmWhite.withValues(alpha: 0.92),
                  windowColor: AppColors.clayDark,
                ),
              ),
            )
          else
            Center(
              child: Icon(slide.icon, size: 96, color: Colors.white),
            ),
        ],
      ),
    );
  }
}
