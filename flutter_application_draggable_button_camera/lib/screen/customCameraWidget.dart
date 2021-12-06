//@dart=2.8
import 'package:camera/camera.dart';
import 'package:draggable_floating_button/draggable_floating_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_filter_camera/screen/draggableButton.dart';
import 'package:flutter_application_filter_camera/status/cameraItemStatus.dart';
import 'package:flutter_application_filter_camera/core/customCameraController.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomCameraPreview extends StatefulWidget {
  final CustomCameraController controller;
  final bool enableZoom;
  CustomCameraPreview({
    Key key,
    this.controller,
    this.enableZoom,
  }) : super(key: key);

  @override
  _CustomCameraPreviewState createState() => _CustomCameraPreviewState();
}

class _CustomCameraPreviewState extends State<CustomCameraPreview> {
  List<IconData> icons = [Icons.zoom_in, Icons.camera_alt];

  @override
  void initState() {
    super.initState();
    widget.controller.init();
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  bool videoMode = false;

  IconData get cameraIcon {
    if (!videoMode)
      return Icons.camera_alt;
    else if (widget.controller.controller.value.isRecordingVideo)
      return Icons.stop;
    else
      return Icons.circle;
  }

  Function get takePictureAndVideo {
    if (!videoMode)
      return () => widget.controller.takePhoto();
    else if (widget.controller.controller.value.isRecordingVideo)
      return () {
        widget.controller.onStopButtonPressed();
        setState(() {});
      };
    else
      return () {
        widget.controller.onVideoRecordButtonPressed();
        setState(() {});
      };
  }

  void startVideo() {
    setState(() {
      videoMode = !videoMode;
    });
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
                    Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: widget.controller.buildPreview()),
                    Positioned(
                      bottom: 0.0,
                      right: 0.0,
                      left: 0.0,
                      child: Container(
                        color: Colors.black.withOpacity(0.6),
                        height: 120,
                      ),
                    ),
                    DraggableButtons(
                      icon: [Icons.plus_one, cameraIcon],
                      onPressed: [
                        () => widget.controller.zoomChange(),
                        takePictureAndVideo,
                      ],
                      onLongPressed: () => startVideo(),
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      bottomheight: 0.17,
                    ),

                    // if (widget.enableZoom) // 줌 가능 시에만 버튼 생성
                    //   Positioned(
                    //     bottom: 0.0,
                    //     right: 60.0,
                    //     child: Padding(
                    //       padding: const EdgeInsets.all(10.0),
                    //       child: IconButton(
                    //         icon: Center(
                    //           child: Text(
                    //             "${camera.zoom.toStringAsFixed(1)}x",
                    //             style: TextStyle(
                    //                 color: Colors.white, fontSize: 15),
                    //           ),
                    //         ),
                    //         onPressed: () => widget.controller.zoomChange(),
                    //       ),
                    //     ),
                    //   ),
                    // if (widget.controller.flashModes.length >
                    //     1) // 플래시 존재 시에만 버튼 생성
                    //   Align(
                    //     alignment: Alignment.bottomLeft,
                    //     child: Padding(
                    //       padding: const EdgeInsets.all(10.0),
                    //       child: IconButton(
                    //         onPressed: () =>
                    //             widget.controller.changeFlashMode(),
                    //         icon: Icon(
                    //           camera.flashModeIcon,
                    //           color: Colors.white,
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // Positioned(
                    //   top: 20.0,
                    //   left: 60.0,
                    //   child: widget.controller.controller.value.isRecordingVideo
                    //       ? IconButton(
                    //           onPressed: () {
                    //             widget.controller.onStopButtonPressed();
                    //             setState(() {});
                    //           },
                    //           icon: Icon(Icons.stop))
                    //       : IconButton(
                    //           onPressed: () {
                    //             widget.controller.onVideoRecordButtonPressed();
                    //             setState(() {});
                    //           },
                    //           icon: Icon(Icons.videocam)),
                    // ),
                    // DraggableFloatingActionButton(
                    //   key: _draggableButtonKey,
                    //   offset: Offset(_draggableButtonLocation.dx,
                    //       _draggableButtonLocation.dy),
                    //   backgroundColor: Colors.white,
                    //   onPressed: () {
                    //     widget.controller.takePhoto();
                    //     _setDraggableButtonPosition();
                    //   },
                    //   appContext: context,
                    //   mini: true,
                    // ),
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
