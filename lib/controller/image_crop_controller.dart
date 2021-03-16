import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_kakao_profile_img_app/controller/profile_controller.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImageCropController extends GetxController {
  static ImageCropController get to => Get.find();

  Future<File> selectImage(ProfileImageType type) async {
    PickedFile pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile == null) return null;
    return _cropImage(pickedFile, type);
  }

  Future<File> _cropImage(PickedFile file, ProfileImageType type) async {
    List<CropAspectRatioPreset> presets = [];
    switch (type) {
      case ProfileImageType.thumbnail:
        presets = [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.original,
        ];
        break;
      case ProfileImageType.background:
        presets = [
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio5x3,
        ];
        break;
    }
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: file.path,
        aspectRatioPresets: presets,
        androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: true,
        ),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));
    return croppedFile;
  }
}
