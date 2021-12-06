import 'package:flutter/material.dart';
import 'package:flutter_application_filter_camera/core/pictureController.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';

class DisplayPictureScreen extends StatelessWidget {
  final PictureController pictureController = Get.put(PictureController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Stack(children: [
          GridView.builder(
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
            itemBuilder: (_, index) => Container(
              width: size.width,
              child: Image.file(
                pictureController.photos[index],
                fit: BoxFit.cover,
              ),
            ),
            itemCount: pictureController.photos.length,
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              child: InkWell(
                onTap: () => Get.offNamed('/'),
                child: Row(children: [
                  Icon(
                    Icons.navigate_before,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 8.0,
                  ),
                  Text(
                    '카메라',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  )
                ]),
              ),
              padding: const EdgeInsets.all(10.0),
            ),
          )
        ]),
      ),
    );
  }
}
