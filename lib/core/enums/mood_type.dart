import 'package:flutter/material.dart';
import '../constants/color_constants.dart';

enum MoodType {
  happy,
  stress,
  tired,
  bored,
  neutral;

  String get displayName {
    switch (this) {
      case MoodType.happy:
        return 'Senang';
      case MoodType.stress:
        return 'Stress';
      case MoodType.tired:
        return 'Lelah';
      case MoodType.bored:
        return 'Bosan';
      case MoodType.neutral:
        return 'Netral';
    }
  }

  String get emoji {
    switch (this) {
      case MoodType.happy:
        return '😊';
      case MoodType.stress:
        return '😰';
      case MoodType.tired:
        return '😴';
      case MoodType.bored:
        return '😐';
      case MoodType.neutral:
        return '😌';
    }
  }

  Color get color {
    switch (this) {
      case MoodType.happy:
        return AppColors.moodHappy;
      case MoodType.stress:
        return AppColors.moodStress;
      case MoodType.tired:
        return AppColors.moodTired;
      case MoodType.bored:
        return AppColors.moodBored;
      case MoodType.neutral:
        return AppColors.moodNeutral;
    }
  }
}
