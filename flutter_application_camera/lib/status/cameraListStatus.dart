import 'package:camera/camera.dart';
import 'package:flutter_application_filter_camera/core/customCameraController.dart';

abstract class CameraListStatus {}

class CameraListStatusEmpty extends CameraListStatus {
  // 비어있는 상태
  CameraListStatusEmpty();
}

class CameraListStatusLoading extends CameraListStatus {
  // 카메라 로딩 중
  CameraListStatusLoading();
}

class CameraListStatusSuccess extends CameraListStatus {
  // 사용가능한 카메라 가져와서 담긴 상태
  List<CameraDescription> cameras; // 사용 가능 카메라 리스트
  CameraListStatusSuccess({
    required this.cameras,
  });
}

class CameraListStatusSelected extends CameraListStatus {
  // 사용가능한 카메라 리스트 중 하나 선택해서 담기 위해 index 설정
  List<CameraDescription> cameras;
  int indexSelected;
  CameraListStatusSelected({
    required this.cameras, // 사용 가능 카메라 리스트
    required this.indexSelected, // 선택할 카메라 index
  });

  CameraDescription get actual => cameras[indexSelected];
}

class CameraListStatusPreview extends CameraListStatus {
  // 사용가능 카메라 리스트와 커스텀 기능 controller로 들어간 상태
  CustomCameraController controller; // 화질, 플래시, 오디오 같은 커스텀 값이 담긴 controller
  List<CameraDescription> cameras; // 사용 가능 카메라 리스트
  int indexSelected; // 선택할 카메라 index

  CameraListStatusPreview({
    required this.controller,
    required this.cameras,
    required this.indexSelected,
  });
}

class CameraListStatusFailure extends CameraListStatus {
  // 카메라 연결 실패
  String message;
  CameraException exception;
  CameraListStatusFailure({
    required this.message,
    required this.exception,
  });
}

extension CameraListStatusExt on CameraListStatus {
  //상태에 따른 값 반환
  CameraListStatusFailure get failure => this as CameraListStatusFailure;
  CameraListStatusLoading get loading => this as CameraListStatusLoading;
  CameraListStatusSuccess get success => this as CameraListStatusSuccess;
  CameraListStatusSelected get selected => this as CameraListStatusSelected;
  CameraListStatusPreview get preview => this as CameraListStatusPreview;

  dynamic when({
    dynamic Function(String message, dynamic error)? failure,
    dynamic Function()? loading,
    required dynamic Function() orElse,
    dynamic Function(List<CameraDescription> cameras)? success,
    dynamic Function(CameraDescription camera)? selected,
    dynamic Function(CustomCameraController controller)? preview,
  }) {
    switch (this.runtimeType) {
      case CameraListStatusFailure:
        {
          if (failure != null) {
            return failure(this.failure.message, this.failure.exception);
          } else {
            return orElse();
          }
        }

      case CameraListStatusLoading:
        {
          if (loading != null) {
            return loading();
          } else {
            return orElse();
          }
        }

      case CameraListStatusSuccess:
        {
          if (success != null) {
            return success(this.success.cameras);
          } else {
            return orElse();
          }
        }

      case CameraListStatusSelected:
        {
          if (selected != null) {
            return selected(this.selected.actual);
          } else {
            return orElse();
          }
        }

      case CameraListStatusEmpty:
        {
          return orElse();
        }

      case CameraListStatusPreview:
        {
          if (preview != null) {
            return preview(this.preview.controller);
          } else {
            return orElse();
          }
        }

      default:
        throw "CAMERA INVALID STATUS";
    }
  }
}
