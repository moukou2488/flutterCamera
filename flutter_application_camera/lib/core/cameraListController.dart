import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_application_filter_camera/status/cameraListStatus.dart';
import 'package:flutter_application_filter_camera/core/customCameraController.dart';

import 'package:rxdart/subjects.dart';

class CameraListController {
  CameraLensDirection? cameraLensDirection; // 카메라방향

  List<FlashMode> flashModes; // 플래시

  bool enableAudio; // 비디오 소리 포함 유무

  CustomCameraController? customCameraController; // 커스텀값 포함 카메라 컨트롤러

  CameraListController({
    required this.cameraLensDirection,
    required this.flashModes,
    this.enableAudio = false,
  });

  //카메라 상태값
  final statusStream =
      BehaviorSubject<CameraListStatus>.seeded(CameraListStatusEmpty());
  CameraListStatus get status => statusStream.value;
  set status(CameraListStatus status) => statusStream.sink.add(status);

  void init() async {
    status = CameraListStatusLoading();
    try {
      WidgetsFlutterBinding.ensureInitialized();
      // 디바이스에서 사용가능한 카메라 가져오기
      final cameras = await availableCameras();
      status = CameraListStatusSuccess(cameras: cameras);
    } on CameraException catch (e) {
      status =
          CameraListStatusFailure(message: e.description ?? "", exception: e);
    }

    status.when(orElse: () {}, success: (_) => changeCamera());
  }

  void changeCamera([int? specificIndex]) {
    if (status is CameraListStatusSuccess) {
      print('1234');
      // 최초 카메라 리스트 가져 온 후 카메라 선택 시
      final cameras = status.success.cameras;
      status = CameraListStatusSelected(
          cameras: cameras, indexSelected: 0); // 첫 번째 전면 카메라
    } else if (status is CameraListStatusPreview) {
      // 카메라 띄운 후 전후면 전환 시
      final cameras = status.preview.cameras;
      final index = status.preview.indexSelected;
      var indexSelected = 0;
      if (index + 1 < cameras.length) {
        // 전환 카메라 만큼 다음으로 돌린고 마지막 카메라 일 시 제일 처음 카메라로 이동
        indexSelected = index + 1;
      }
      status = CameraListStatusSelected(
          cameras: cameras, indexSelected: specificIndex ?? indexSelected);
    } else {
      throw "CAMERA_CAMERA ERROR: Invalid changeCamera";
    }
  }

  void startPreview(
    ResolutionPreset resolutionPreset,
  ) async {
    try {
      await customCameraController?.dispose();
    } on Exception catch (e) {
      print(e);
    }

    final cameras = status.selected.cameras;
    final indexSelected = status.selected.indexSelected;
    customCameraController = CustomCameraController(
      cameraDescription: cameras[indexSelected],
      resolutionPreset: resolutionPreset,
      flashModes: flashModes,
      enableAudio: enableAudio,
    );
    status = CameraListStatusPreview(
        controller: customCameraController!,
        cameras: cameras,
        indexSelected: indexSelected);
  }

  void dispose() {
    statusStream.close();
  }
}
