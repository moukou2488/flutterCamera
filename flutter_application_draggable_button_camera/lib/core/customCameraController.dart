import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_application_filter_camera/entities/customResolution.dart';
import 'package:flutter_application_filter_camera/status/cameraItemStatus.dart';
import 'package:flutter_application_filter_camera/core/pictureController.dart';
import 'package:flutter_application_filter_camera/entities/customCameraOption.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';

class CustomCameraController {
  CustomResolution customResolution; // 화질

  CameraDescription cameraDescription; // 카메라방향

  List<FlashMode> flashModes; // 플래시

  bool enableAudio; // 비디오 소리 포함 유무

  late CameraController controller; // 커스텀 할 요소들을 받은 값으로 CameraController 세팅

  final statusNotifier = ValueNotifier<CameraItemStatus>(
      CameraItemEmpty()); // 카메라 상태에 따라 설정 값 화면에 적용하기 위함
  CameraItemStatus get status => statusNotifier.value;
  set status(CameraItemStatus status) => statusNotifier.value = status;

  CustomCameraController({
    required this.customResolution,
    required this.cameraDescription,
    required this.flashModes,
    this.enableAudio = true,
  }) {
    controller = CameraController(
        cameraDescription, customResolution.resolutionPreset,
        enableAudio: enableAudio);
  }
  void init() async {
    status = CameraItemLoading();
    try {
      await controller.initialize();
      final maxZoom = await controller.getMaxZoomLevel();
      final minZoom = await controller.getMinZoomLevel();
      final maxExposure = await controller.getMaxExposureOffset();
      final minExposure = await controller.getMinExposureOffset();
      try {
        await controller.setFlashMode(FlashMode.off);
      } catch (e) {}

      status = CameraItemSuccess(
          camera: CustomCameraOption(
              maxZoom: maxZoom,
              minZoom: minZoom,
              zoom: minZoom,
              maxExposure: maxExposure,
              minExposure: minExposure,
              flashMode: FlashMode.off));
    } on CameraException catch (e) {
      status = CameraItemFailure(message: e.description ?? "", exception: e);
    }
  }

  Widget buildPreview() => controller.buildPreview();

  void takePhoto() async {
    final file = await controller.takePicture();
    ImageGallerySaver.saveFile(file.path);
    final PictureController pictureController = Get.put(PictureController());
    pictureController.addPicture(file.path);
    // Get.toNamed('/picture');
  }

  void onVideoRecordButtonPressed() {
    startVideoRecording().then((_) {});
  }

  void onPauseButtonPressed() {
    pauseVideoRecording().then((_) {
      print('Video recording paused');
    });
  }

  void onStopButtonPressed() {
    stopVideoRecording().then((file) {
      if (file != null) {
        print('Video recorded to ${file.path}');
        ImageGallerySaver.saveFile(file.path);
        //_startVideoPlayer();
      }
    });
  }

  void onResumeButtonPressed() {
    resumeVideoRecording().then((_) {
      print('Video recording resumed');
    });
  }

  Future<void> startVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      print('Error: select a camera first.');
      return;
    }

    if (cameraController.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return;
    }

    try {
      await cameraController.startVideoRecording();
    } on CameraException catch (e) {
      print('Error: ${e.code}\n${e.description}');
      return;
    }
  }

  Future<XFile?> stopVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      return cameraController.stopVideoRecording();
    } on CameraException catch (e) {
      print('Error: ${e.code}\n${e.description}');
      return null;
    }
  }

  Future<void> pauseVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      await cameraController.pauseVideoRecording();
    } on CameraException catch (e) {
      print('Error: ${e.code}\n${e.description}');
      rethrow;
    }
  }

  Future<void> resumeVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      await cameraController.resumeVideoRecording();
    } on CameraException catch (e) {
      print('Error: ${e.code}\n${e.description}');
      rethrow;
    }
  }

  void setZoomLevel(double zoom) async {
    // 줌 설정
    if (zoom != 1) {
      var cameraZoom = double.parse(((zoom)).toStringAsFixed(1)); // 소수 아래 한 단위
      if (cameraZoom >= status.camera.minZoom &&
          cameraZoom <= status.camera.maxZoom) {
        final camera = status.camera.copyWith(zoom: cameraZoom);
        status = CameraItemSuccess(camera: camera);
        await controller.setZoomLevel(cameraZoom);
      }
    }
  }

  void zoomChange() async {
    // 줌 변경
    var zoom = status.camera.zoom;
    if (zoom + 0.5 <= status.camera.maxZoom) {
      zoom += 0.5;
    } else {
      // 최대 값까지 가면 다시 처음으로 변경
      zoom = 1.0;
    }
    final camera = status.camera.copyWith(zoom: zoom);
    status = CameraItemSuccess(camera: camera); // 바뀐 줌 정도의 카메라 옵션을 새로 넣어줌
    await controller.setZoomLevel(zoom);
  }

  void setFlashMode(FlashMode flashMode) async {
    // 플래시 설정
    final camera = status.camera.copyWith(flashMode: flashMode);

    status = CameraItemSuccess(camera: camera); // 바뀐 플래시 모드를 카메라 옵션을 새로 넣어줌
    controller.setFlashMode(flashMode);
  }

  void changeFlashMode() async {
    // 플래시 변경
    final flashMode = status.camera.flashMode;
    final list = flashModes;
    var index = list.indexWhere((e) => e == flashMode);

    index + 1 < list.length
        ? index++
        : index = 0; // 보유한 플래시 모드 제일 마지막까지 가면 처음으로 변경

    setFlashMode(list[index]);
  }

  Future<void> dispose() async {
    await controller.dispose();
    return;
  }
}
