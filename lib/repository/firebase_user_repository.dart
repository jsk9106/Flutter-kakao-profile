import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_kakao_profile_img_app/model/user_model.dart';

class FirebaseUserRepository{
  static Future<String> signUp(UserModel user) async{
    CollectionReference users = FirebaseFirestore.instance.collection("users");
    DocumentReference drf = await users.add(user.toMap());
    return drf.id;
  }
  
  static Future<UserModel> findUserByUid(String uid) async{
    CollectionReference users = FirebaseFirestore.instance.collection("users");
    QuerySnapshot data = await users.where("uid", isEqualTo: uid).get();
    if(data.size == 0){
      return null;
    } else{
      return UserModel.fromJson(data.docs[0].data(), data.docs[0].id);
    }
  }

  static void updateLastLoginDate(String docId, DateTime time){
    CollectionReference users = FirebaseFirestore.instance.collection("users");
    users.doc(docId).update({"last_login_time": time});
  }

  static void updateImageUrl(String docId, String url, String fieldName){
    CollectionReference users = FirebaseFirestore.instance.collection("users");
    users.doc(docId).update({fieldName: url});
  }

  static void updateData(String docId, UserModel user){
    CollectionReference users = FirebaseFirestore.instance.collection("users");
    users.doc(docId).update(user.toMap());
  }

}