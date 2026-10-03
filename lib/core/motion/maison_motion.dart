import 'package:flutter/animation.dart';

/// Shared motion language for TRACÉ RAFFINÉ.
///
/// These tokens represent verified semantic motion patterns already present
/// across multiple active screens. Page-specific choreography, intervals,
/// component-specific durations, and local animation details remain local.
abstract final class MaisonMotion {
  MaisonMotion._();

  /// Shared duration for staged page entrance animations.
  static const Duration pageEntrance = Duration(milliseconds: 1400);

  /// Shared duration for editorial hover and interaction transitions.
  static const Duration editorialInteraction = Duration(milliseconds: 280);

  /// Shared forward duration for page route transitions.
  static const Duration pageTransition = Duration(milliseconds: 720);

  /// Shared reverse duration for page route transitions.
  static const Duration pageReverseTransition = Duration(milliseconds: 460);

  /// Shared duration for Silk Sweep reveal choreography.
  static const Duration silkSweep = Duration(milliseconds: 520);

  /// Canonical forward curve for the Maison motion language.
  static const Curve easeOut = Curves.easeOutCubic;

  /// Canonical reverse curve for the Maison motion language.
  static const Curve easeIn = Curves.easeInCubic;
}
