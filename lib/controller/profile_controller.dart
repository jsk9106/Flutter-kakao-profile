import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_kakao_profile_img_app/controller/image_crop_controller.dart';
import 'package:flutter_kakao_profile_img_app/model/user_model.dart';
import 'package:flutter_kakao_profile_img_app/repository/firebase_user_repository.dart';
import 'package:flutter_kakao_profile_img_app/repository/firestorage_repository.dart';
import 'package:get/get.dart';

enum ProfileImageType { thumbnail, background }

class ProfileController extends GetxController {
  static ProfileController get to => Get.find();

  RxBool isEditMyProfile = false.obs;
  UserModel originMyProfile = UserModel();
  Rx<UserModel> myProfile = UserModel().obs;
  FirestorageRepository _firestorageRepository = FirestorageRepository();

  void authStateChanges(User firebaseUser) async {
    if (firebaseUser != null) {
      UserModel userModel =
          await FirebaseUserRepository.findUserByUid(firebaseUser.uid);
      if (userModel != null) {
        originMyProfile = userModel;
        FirebaseUserRepository.updateLastLoginDate(
            userModel.docId, DateTime.now());
      } else {
        originMyProfile = UserModel(
          uid: firebaseUser.uid,
          name: firebaseUser.displayName,
          avatarUrl: firebaseUser.photoURL,
          createdTime: DateTime.now(),
          lastLoginTime: DateTime.now(),
        );
        String docId = await FirebaseUserRepository.signUp(originMyProfile);
        originMyProfile.docId = docId;
      }
    }
    myProfile(UserModel.clone(originMyProfile));
  }

  @override
  void onInit() {
    isEditMyProfile(false);
    super.onInit();
  }

  void toggleEditProfile() {
    isEditMyProfile(!isEditMyProfile.value);
  }

  void rollBack() {
    myProfile.value.initImageFile();
    myProfile(originMyProfile);
    toggleEditProfile();
  }

  void updateName(String updateName) {
    myProfile.update((my) {
      my.name = updateName;
    });
  }

  void updateDescription(String updateDescription) {
    myProfile.update((my) {
      my.description = updateDescription;
    });
  }

  void pickImage(ProfileImageType type) async {
    if (!isEditMyProfile.value) return;
    File file = await ImageCropController.to.selectImage(type);
    if (file == null) return;
    switch (type) {
      case ProfileImageType.thumbnail:
        myProfile.update((my) => my.avatarFile = file);
        break;
      case ProfileImageType.background:
        myProfile.update((my) => my.backgroundFile = file);
        break;
    }
  }

  void _updateProfileImageUrl(String downloadUrl) {
    originMyProfile.avatarUrl = downloadUrl;
    myProfile.update((my) => my.avatarUrl = downloadUrl);
  }

  void _updateBackgroundImageUrl(String downloadUrl) {
    originMyProfile.backgroundUrl = downloadUrl;
    myProfile.update((my) => my.backgroundUrl = downloadUrl);
  }

  void save() {
    originMyProfile = myProfile.value;

    if (originMyProfile.avatarFile != null) {
      UploadTask task = _firestorageRepository.uploadImageFile(
          originMyProfile.uid, "profile", originMyProfile.avatarFile);
      task.snapshotEvents.listen((event) async {
        if (event.bytesTransferred == event.totalBytes) {
          String downloadUrl = await event.ref.getDownloadURL();
          _updateProfileImageUrl(downloadUrl);
          FirebaseUserRepository.updateImageUrl(
              originMyProfile.docId, downloadUrl, "avatar_url");
        }
      });
    }

    if (originMyProfile.backgroundFile != null) {
      UploadTask task = _firestorageRepository.uploadImageFile(
          originMyProfile.uid, "background", originMyProfile.backgroundFile);
      task.snapshotEvents.listen((event) async {
        if (event.bytesTransferred == event.totalBytes) {
          String downloadUrl = await event.ref.getDownloadURL();
          _updateBackgroundImageUrl(downloadUrl);
          FirebaseUserRepository.updateImageUrl(
              originMyProfile.docId, downloadUrl, "background_url");
        }
      });
    }

    FirebaseUserRepository.updateData(originMyProfile.docId, originMyProfile);
    toggleEditProfile();
  }
}
