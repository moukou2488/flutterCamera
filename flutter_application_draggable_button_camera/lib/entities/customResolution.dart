import 'package:camera/camera.dart';

enum CustomResolution { high, medium, low }

extension CustomResolutionExt on CustomResolution {
  ResolutionPreset get resolutionPreset {
    switch (this) {
      case CustomResolution.high:
        return ResolutionPreset.max;

      case CustomResolution.medium:
        return ResolutionPreset.veryHigh;

      case CustomResolution.low:
        return ResolutionPreset.medium;
    }
  }
}
