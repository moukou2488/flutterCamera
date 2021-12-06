import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:flutter_application_filter_camera/screen/cameraScreen.dart';
import 'package:flutter_application_filter_camera/screen/pictureScreen.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final photos = <File>[];

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'camera',
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => CameraScreen()),
        GetPage(name: '/picture', page: () => DisplayPictureScreen())
      ],
    );
  }
}
