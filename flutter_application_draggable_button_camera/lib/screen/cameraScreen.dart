//@dart=2.8
import 'dart:async';
import 'dart:io';

import 'package:draggable_floating_button/draggable_floating_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_filter_camera/core/cameraListController.dart';
import 'package:flutter_application_filter_camera/entities/customResolution.dart';
import 'package:flutter_application_filter_camera/status/cameraListStatus.dart';
import 'package:camera/camera.dart';
import 'package:flutter_application_filter_camera/screen/customCameraWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CameraScreen extends StatefulWidget {
  final CustomResolution
      customResolution; // 해상도 (low,medium,high,veryHigh,ultraHigh,max)

  final List<FlashMode> flashModes; // 플래쉬

  final bool enableZoom; // 줌

  final bool enableAudio; // 소리 포함

  final CameraLensDirection cameraLensDirection; //카메라 방향

  const CameraScreen({
    Key key,
    this.customResolution = CustomResolution.high,
    this.cameraLensDirection = CameraLensDirection.front,
    this.flashModes = FlashMode.values,
    this.enableZoom = true,
    this.enableAudio = false,
  }) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraListController cameraListController;
  StreamSubscription _subscription;

  GlobalKey _draggableButtonKey = GlobalKey();
  Offset _draggableButtonLocation;

  @override
  void initState() {
    super.initState();

    cameraListController = CameraListController(
        customResolution: widget.customResolution,
        flashModes: widget.flashModes,
        cameraLensDirection: widget.cameraLensDirection,
        enableAudio: widget.enableAudio);
    cameraListController.init();
    _subscription = cameraListController.statusStream.listen((state) {
      return state.when(
          orElse: () {},
          selected: (camera, resolution) async {
            cameraListController.startPreview(resolution);
          });
    });

    _loadDraggableButtonPosition();
  }

  @override
  void dispose() {
    cameraListController.dispose(); //사용하지 않는 자원 반환
    _subscription.cancel();
    super.dispose();
  }

  // 최초 화면전환 버튼 위치 세팅
  void _loadDraggableButtonPosition() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getDouble('draggableButtonLocationX') != null) {
      setState(() {
        _draggableButtonLocation = Offset(
            prefs.getDouble('draggableButtonLocationX'),
            prefs.getDouble('draggableButtonLocationY'));
      });
    }
  }

  //이동된 화면전환 버튼 위치 세팅
  void _setDraggableButtonPosition() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //위젯 key로 RenderBox를 정의한다.
    RenderBox _draggableButtonBox =
        _draggableButtonKey.currentContext.findRenderObject();

    //위젯의 좌표를 반환받는다
    _draggableButtonLocation = _draggableButtonBox.localToGlobal(Offset.zero);

    setState(() {
      prefs.setDouble('draggableButtonLocationX', _draggableButtonLocation.dx);
      prefs.setDouble('draggableButtonLocationY', _draggableButtonLocation.dy);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_draggableButtonLocation == null) {
      _draggableButtonLocation = Offset(
          MediaQuery.of(context).size.width / 2 + 95,
          MediaQuery.of(context).size.height - 115);
    }
    return Material(
      color: Colors.black,
      child: StreamBuilder<CameraListStatus>(
        stream: cameraListController.statusStream,
        initialData: CameraListStatusEmpty(),
        builder: (_, snapshot) => snapshot.data.when(
            preview: (controller) => Stack(
                  children: [
                    CustomCameraPreview(
                      enableZoom: widget.enableZoom,
                      key: UniqueKey(),
                      controller: controller,
                    ),
                    if (cameraListController.status.preview.cameras.length > 1)
                      DraggableFloatingActionButton(
                        key: _draggableButtonKey,
                        offset: Offset(_draggableButtonLocation.dx,
                            _draggableButtonLocation.dy),
                        backgroundColor: Colors.white,
                        child: Icon(
                          Platform.isAndroid
                              ? Icons.flip_camera_android
                              : Icons.flip_camera_ios,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          cameraListController.changeCamera();
                          //_setDraggableButtonPosition();
                        },
                        appContext: context,
                      ),
                    // if (cameraListController.status.preview.cameras.length >
                    //     1) //디바이스 카메라 모드가 2개 이상 시 전환 가능 버튼
                    //   Align(
                    //     alignment: Alignment.bottomRight,
                    //     child: Padding(
                    //       padding: const EdgeInsets.all(10.0),
                    //       child: IconButton(
                    //         onPressed: () {
                    //           cameraListController.changeCamera();
                    //         },
                    //         icon: Icon(
                    //           Platform.isAndroid
                    //               ? Icons.flip_camera_android
                    //               : Icons.flip_camera_ios,
                    //           color: Colors.white,
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // Positioned(
                    //   bottom: 0.0,
                    //   left: 60.0,
                    //   child: Padding(
                    //     padding: const EdgeInsets.all(10.0),
                    //     child: IconButton(
                    //         onPressed: () {
                    //           cameraListController.changeResolutionPreset();
                    //         },
                    //         icon: Center(
                    //           child: Text(
                    //             cameraListController.customResolutionIcon,
                    //             style: TextStyle(
                    //                 color: Colors.white, fontSize: 15),
                    //           ),
                    //         )),
                    //   ),
                    // )
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
