import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_filter_camera/core/cameraListController.dart';
import 'package:flutter_application_filter_camera/status/cameraListStatus.dart';
import 'package:camera/camera.dart';
import 'package:flutter_application_filter_camera/screen/customCameraWidget.dart';

class CameraScreen extends StatefulWidget {
  final ResolutionPreset
      resolutionPreset; // 해상도 (low,medium,high,veryHigh,ultraHigh,max)

  final List<FlashMode> flashModes; // 플래쉬

  final bool enableZoom; // 줌

  final bool enableAudio; // 소리 포함

  final CameraLensDirection cameraLensDirection; //카메라 방향

  const CameraScreen({
    Key? key,
    this.resolutionPreset = ResolutionPreset.ultraHigh,
    this.cameraLensDirection = CameraLensDirection.front,
    this.flashModes = FlashMode.values,
    this.enableZoom = true,
    this.enableAudio = false,
  }) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraListController cameraListController;
  late StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();

    cameraListController = CameraListController(
        flashModes: widget.flashModes,
        cameraLensDirection: widget.cameraLensDirection,
        enableAudio: widget.enableAudio);
    cameraListController.init();
    _subscription = cameraListController.statusStream.listen((state) {
      return state.when(
          orElse: () {},
          selected: (camera) async {
            cameraListController.startPreview(widget.resolutionPreset);
          });
    });
  }

  @override
  void dispose() {
    cameraListController.dispose(); //사용하지 않는 자원 반환
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: StreamBuilder<CameraListStatus>(
        stream: cameraListController.statusStream,
        initialData: CameraListStatusEmpty(),
        builder: (_, snapshot) => snapshot.data!.when(
            preview: (controller) => Stack(
                  children: [
                    CustomCameraPreview(
                      enableZoom: widget.enableZoom,
                      key: UniqueKey(),
                      controller: controller,
                    ),
                    if (cameraListController.status.preview.cameras.length >
                        1) //디바이스 카메라 모드가 2개 이상 시 전환 가능 버튼
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: InkWell(
                            onTap: () {
                              cameraListController.changeCamera();
                            },
                            child: Icon(
                              Platform.isAndroid
                                  ? Icons.flip_camera_android
                                  : Icons.flip_camera_ios,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                  ],
                ),
            failure: (message, _) => Container(
                  color: Colors.black,
                  child: Text(message),
                ),
            orElse: () => Container(
                  color: Colors.black,
                )),
      ),
    );
  }
}
