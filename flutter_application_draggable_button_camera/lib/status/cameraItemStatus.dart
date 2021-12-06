import 'package:camera/camera.dart';
import 'package:flutter_application_filter_camera/entities/customCameraOption.dart';

abstract class CameraItemStatus {}

class CameraItemEmpty extends CameraItemStatus {
  CameraItemEmpty();
}

class CameraItemLoading extends CameraItemStatus {
  CameraItemLoading();
}

class CameraItemFailure extends CameraItemStatus {
  String message;
  CameraException exception;
  CameraItemFailure({
    required this.message,
    required this.exception,
  });
}

class CameraItemSuccess extends CameraItemStatus {
  CustomCameraOption camera;
  CameraItemSuccess({
    required this.camera,
  });
}

extension CameraItemStatusExt on CameraItemStatus {
  CustomCameraOption get camera =>
      (this as CameraItemSuccess).camera; // 카메라 옵션들
  CameraItemFailure get failure => this as CameraItemFailure; // 카메라 로딩 중
  CameraItemLoading get loading => this as CameraItemLoading; // 카메라 연결 실패
  CameraItemSuccess get success => this as CameraItemSuccess; // 카메라 연결 성공
  dynamic when({
    // 카메라 연결 상태에 따른 반환값 설정
    Function(String message, dynamic exception)? failure,
    Function()? loading,
    required Function() orElse,
    Function(CustomCameraOption camera)? success,
  }) {
    switch (this.runtimeType) {
      case CameraItemFailure:
        {
          if (failure != null) {
            return failure(this.failure.message, this.failure.exception);
          } else {
            return orElse();
          }
        }

      case CameraItemLoading:
        {
          if (loading != null) {
            return loading();
          } else {
            return orElse();
          }
        }

      case CameraItemSuccess:
        {
          if (success != null) {
            return success(this.success.camera);
          } else {
            return orElse();
          }
        }

      default:
        throw "CAMERA CAMERA (UI) INVALID STATUS";
    }
  }
}
