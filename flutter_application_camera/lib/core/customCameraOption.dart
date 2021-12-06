import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CustomCameraOption {
  final double maxZoom;
  final double minZoom;
  final double? maxExposure;
  final double? minExposure;
  final double? exposureOffset;
  final double zoom;
  final FlashMode? flashMode;
  final ExposureMode? exposureMode;
  final Offset? focusPoint;
  final Offset? exposurePoint;
  CustomCameraOption({
    required this.maxZoom,
    required this.minZoom,
    this.maxExposure,
    this.minExposure,
    this.exposureOffset,
    required this.zoom,
    this.flashMode,
    this.exposureMode,
    this.focusPoint,
    this.exposurePoint,
  });

  CustomCameraOption copyWith({
    //copyWith을 통해 넘겨받은 카메라 옵션 특정 값만 변경 바뀌지 않은 값은 원래 가진 값 사용
    double? maxZoom,
    double? minZoom,
    double? maxExposure,
    double? minExposure,
    double? exposureOffset,
    double? zoom,
    FlashMode? flashMode,
    ExposureMode? exposureMode,
    Offset? focusPoint,
    Offset? exposurePoint,
  }) {
    return CustomCameraOption(
      maxZoom: maxZoom ?? this.maxZoom,
      minZoom: minZoom ?? this.minZoom,
      maxExposure: maxExposure ?? this.maxExposure,
      minExposure: minExposure ?? this.minExposure,
      exposureOffset: exposureOffset ?? this.exposureOffset,
      zoom: zoom ?? this.zoom,
      flashMode: flashMode ?? this.flashMode,
      exposureMode: exposureMode ?? this.exposureMode,
      focusPoint: focusPoint ?? this.focusPoint,
      exposurePoint: exposurePoint ?? this.exposurePoint,
    );
  }

  IconData get flashModeIcon {
    // 플래시 모드 별 해당 아이콘 설정
    switch (flashMode) {
      case FlashMode.always:
        {
          return Icons.flash_on;
        }

      case FlashMode.auto:
        {
          return Icons.flash_auto;
        }

      case FlashMode.off:
        {
          return Icons.flash_off;
        }

      case FlashMode.torch:
        {
          return Icons.home;
        }

      default:
        throw "INVALID FLASH MODE";
    }
  }
}
