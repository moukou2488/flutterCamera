import 'dart:io';
import 'package:get/get.dart';

class PictureController extends GetxController {
  final photos = <File>[];

  void addPicture(path) {
    photos.add(File(path));
    update();
  }
}
