import 'dart:io';
import 'package:get/get.dart';

class PictureController {
  final photos = <File>[].obs;

  void addPicture(path) {
    photos.add(File(path));
  }
}
