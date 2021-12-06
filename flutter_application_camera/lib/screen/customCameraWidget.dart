import 'package:flutter/material.dart';
import 'package:flutter_application_filter_camera/status/cameraItemStatus.dart';
import 'package:flutter_application_filter_camera/core/customCameraController.dart';

class CustomCameraPreview extends StatefulWidget {
  final CustomCameraController controller;
  final bool enableZoom;
  CustomCameraPreview({
    Key? key,
    required this.controller,
    required this.enableZoom,
  }) : super(key: key);

  @override
  _CustomCameraPreviewState createState() => _CustomCameraPreviewState();
}

class _CustomCameraPreviewState extends State<CustomCameraPreview> {
  @override
  void initState() {
    widget.controller.init();
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<CameraItemStatus>(
      valueListenable: widget.controller.statusNotifier,
      builder: (_, status, __) => status.when(
          success: (camera) => GestureDetector(
                // 제스처 감지 이벤트로 로직 실행
                onScaleUpdate: (details) {
                  //
                  widget.controller
                      .setZoomLevel(details.scale); // 줌 값 변화에 따른 버튼의 줌 정도 표시 변화
                },
                child: Stack(
                  children: [
                    Center(child: widget.controller.buildPreview()),
                    Positioned(
                      bottom: 0.0,
                      right: 0.0,
                      left: 0.0,
                      child: Container(
                        color: Colors.black.withOpacity(0.6),
                        height: 80,
                      ),
                    ),
                    if (widget.enableZoom) // 줌 가능 시에만 버튼 생성
                      Positioned(
                        bottom: 40,
                        left: 0.0,
                        right: 0.0,
                        child: IconButton(
                          icon: Center(
                            child: Text(
                              "${camera.zoom.toStringAsFixed(1)}x",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                          onPressed: () {
                            widget.controller.zoomChange();
                          },
                        ),
                      ),
                    if (widget.controller.flashModes.length >
                        1) // 플래시 존재 시에만 버튼 생성
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: IconButton(
                            onPressed: () {
                              widget.controller.changeFlashMode();
                            },
                            icon: Icon(
                              camera.flashModeIcon,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          onTap: () {
                            widget.controller.takePhoto();
                          },
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          failure: (message, _) => Container(
                color: Colors.black,
                child: Text(message),
              ),
          orElse: () => Container(
                color: Colors.black,
              )),
    );
  }
}
