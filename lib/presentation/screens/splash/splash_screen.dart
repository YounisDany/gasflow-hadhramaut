import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/prefs.dart';
import '../../../core/services/startup.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/hadhrami_decor.dart';
import '../../widgets/lang_toggle.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
        ..forward();

  late final Animation<double> _logoFade = _in(0.0, 0.45);
  late final Animation<double> _logoScale = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
  );
  late final Animation<double> _titleFade = _in(0.35, 0.75);
  late final Animation<double> _taglineFade = _in(0.5, 0.9);
  late final Animation<double> _tailFade = _in(0.7, 1.0);

  Animation<double> _in(double begin, double end) => CurvedAnimation(
        parent: _c,
        curve: Interval(begin, end, curve: Curves.easeOut),
      );

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future<void>.delayed(const Duration(milliseconds: 1900));
    if (!mounted) return;
    if (!Prefs.onboardingSeen) {
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      return;
    }
    await goToStartDestination(context);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HadhramiBackground(
        showSkyline: true,
        patternOpacity: 0.05,
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 12,
                right: 12,
                child: FadeTransition(
                  opacity: _tailFade,
                  child: const LangToggle(dark: true),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ScaleTransition(
                      scale: _logoScale,
                      child: FadeTransition(
                        opacity: _logoFade,
                        child: const AppLogo(showText: false, size: 112),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FadeTransition(
                      opacity: _titleFade,
                      child: _slideUp(
                        _titleFade,
                        Text(
                          S.appName,
                          style: AppTextStyles.displayLarge
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeTransition(
                      opacity: _taglineFade,
                      child: _slideUp(
                        _taglineFade,
                        Text(
                          S.tagline,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: Colors.white.withValues(alpha: 0.8)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _tailFade,
                  child: const Center(
                    child: SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.2,
                      ),
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

  Widget _slideUp(Animation<double> a, Widget child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.4),
          end: Offset.zero,
        ).animate(a),
        child: child,
      );
}
