import 'package:flutter/material.dart';
import 'data/mock_therapy_data.dart';
import 'presentation/screens/activity_complete_screen.dart';
import 'presentation/screens/activity_detail_screen.dart';
import 'presentation/screens/caregiver_therapy_dashboard_screen.dart';
import 'presentation/screens/cognitive_game_screen.dart';
import 'presentation/screens/memory_exercise_screen.dart';
import 'presentation/screens/patient_therapy_shell.dart';
import 'presentation/screens/progress_tracking_screen.dart';
import 'presentation/screens/recommendation_types_screen.dart';
import 'presentation/screens/relaxation_exercise_screen.dart';
import 'presentation/theme/therapy_colors.dart';

/// Self-contained Adaptive Therapy frontend (Module 3).
/// No Firebase / API calls — mock data only. Safe to extract and push separately.
class AdaptiveTherapyModule extends StatelessWidget {
  const AdaptiveTherapyModule({super.key});

  @override
  Widget build(BuildContext context) {
    return const TherapyPhoneFrame(
      child: _TherapyNavigator(),
    );
  }
}

class _TherapyNavigator extends StatelessWidget {
  const _TherapyNavigator();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: TherapyRouteNames.shell,
      onGenerateRoute: (settings) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (routeContext) => _pageFor(routeContext, settings.name),
        );
      },
    );
  }

  Widget _pageFor(BuildContext context, String? name) {
    void go(String route) => Navigator.of(context).pushNamed(route);

    switch (name) {
      case TherapyRouteNames.types:
        return RecommendationTypesScreen(onSelect: (item) => go(item.routeName));
      case TherapyRouteNames.activityDetail:
        return ActivityDetailScreen(onStart: () => go(TherapyRouteNames.relaxation));
      case TherapyRouteNames.relaxation:
        return RelaxationExerciseScreen(
          onComplete: () => go(TherapyRouteNames.activityComplete),
        );
      case TherapyRouteNames.cognitiveGame:
        return CognitiveGameScreen(
          onNext: () => go(TherapyRouteNames.activityComplete),
        );
      case TherapyRouteNames.memoryExercise:
        return MemoryExerciseScreen(
          onReady: () => go(TherapyRouteNames.activityComplete),
        );
      case TherapyRouteNames.activityComplete:
        return ActivityCompleteScreen(
          onViewNext: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
              TherapyRouteNames.types,
              (route) => route.isFirst,
            );
          },
          onBackHome: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        );
      case TherapyRouteNames.caregiver:
        return CaregiverTherapyDashboardScreen(
          onViewDetails: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const TherapyPageHost(
                  child: ProgressTrackingScreen(showBack: true),
                ),
              ),
            );
          },
        );
      case TherapyRouteNames.shell:
      default:
        return const PatientTherapyShell();
    }
  }
}

class TherapyPageHost extends StatelessWidget {
  const TherapyPageHost({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: TherapyColors.bgTop,
      child: child,
    );
  }
}

class TherapyPhoneFrame extends StatelessWidget {
  const TherapyPhoneFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final framed = size.width > 520;
    if (!framed) return child;

    return ColoredBox(
      color: const Color(0xFFD9E4EF),
      child: Center(
        child: Container(
          width: 420,
          height: size.height > 900 ? 860 : size.height - 24,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
      ),
    );
  }
}
