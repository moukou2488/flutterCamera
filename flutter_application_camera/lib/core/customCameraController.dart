import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_application_filter_camera/status/cameraItemStatus.dart';
import 'package:flutter_application_filter_camera/core/pictureController.dart';
import 'package:flutter_application_filter_camera/core/customCameraOption.dart';
import 'package:get/get.dart';

class CustomCameraController {
  ResolutionPreset resolutionPreset; // 화질

  CameraDescription cameraDescription; // 카메라방향

  List<FlashMode> flashModes; // 플래시

  bool enableAudio; // 비디오 소리 포함 유무

  late CameraController _controller; // 커스텀 할 요소들을 받은 값으로 CameraController 세팅

  final statusNotifier = ValueNotifier<CameraItemStatus>(
      CameraItemEmpty()); // 카메라 상태에 따라 설정 값 화면에 적용하기 위함
  CameraItemStatus get status => statusNotifier.value;
  set status(CameraItemStatus status) => statusNotifier.value = status;

  CustomCameraController({
    required this.resolutionPreset,
    required this.cameraDescription,
    required this.flashModes,
    this.enableAudio = true,
  }) {
    _controller = CameraController(cameraDescription, resolutionPreset,
        enableAudio: enableAudio);
  }
  void init() async {
    status = CameraItemLoading();
    try {
      await _controller.initialize();
      final maxZoom = await _controller.getMaxZoomLevel();
      final minZoom = await _controller.getMinZoomLevel();
      final maxExposure = await _controller.getMaxExposureOffset();
      final minExposure = await _controller.getMinExposureOffset();
      try {
        await _controller.setFlashMode(FlashMode.off);
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

  Widget buildPreview() => _controller.buildPreview();

  void takePhoto() async {
    final file = await _controller.takePicture();
    final PictureController pictureController = Get.put(PictureController());
    pictureController.addPicture(file.path);
    Get.toNamed('/picture');
  }

  void setZoomLevel(double zoom) async {
    // 줌 설정
    if (zoom != 1) {
      var cameraZoom = double.parse(((zoom)).toStringAsFixed(1)); // 소수 아래 한 단위
      if (cameraZoom >= status.camera.minZoom &&
          cameraZoom <= status.camera.maxZoom) {
        final camera = status.camera.copyWith(zoom: cameraZoom);
        status = CameraItemSuccess(camera: camera);
        await _controller.setZoomLevel(cameraZoom);
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
    await _controller.setZoomLevel(zoom);
  }

  void setFlashMode(FlashMode flashMode) async {
    // 플래시 설정
    final camera = status.camera.copyWith(flashMode: flashMode);
    status = CameraItemSuccess(camera: camera); // 바뀐 플래시 모드를 카메라 옵션을 새로 넣어줌
    _controller.setFlashMode(flashMode);
  }

  void changeFlashMode() async {
    // 플래시 변경
    final flashMode = status.camera.flashMode;
    final list = flashModes;
    var index = list.indexWhere((e) => e == flashMode);
    if (index + 1 < list.length) {
      index++;
    } else {
      // 보유한 플래시 모드 제일 마지막까지 가면 처음으로 변경
      index = 0;
    }
    setFlashMode(list[index]);
  }

  Future<void> dispose() async {
    await _controller.dispose();
    return;
  }
}
