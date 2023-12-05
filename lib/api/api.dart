import 'package:chatfirebase/models/chat_users.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class APIs {

  //for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  //for accessing cloud firebase database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  //for storing self information
  static late ChatUsers me;

  // to return current user
  static User get user => auth.currentUser!;

  //for checking ì user exists or not?
  static Future<bool> userExists() async{
    return (await firestore
        .collection('users')
        .doc(user.uid)
        .get()
    ).exists;
  }
  //for getting current user info
  static Future<void> getSelfInfo() async{
    return await firestore
        .collection('users')
        .doc(user.uid)
        .get()
        .then((user) async{
        if(user.exists){
          me =ChatUsers.fromJson(user.data()!);
        }else {
          await createUser().then((value)=> getSelfInfo());
        }
    });

  }

  //for creating a new letter
  static Future<void> createUser() async{
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatUser = ChatUsers(
        id: user.uid,
        name: user.displayName.toString(),
        email: user.email.toString(),
        about: "Hey, I'm using We Chat!",
        image: user.photoURL.toString(),
        createdAt: time,
        isOnline: false,
       lastActive: time,
       pushToken: '',
    );
    return await firestore.collection('users').doc(user.uid).set(chatUser.toJson());

  }

  //for getting all user from users from firestores database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUser(){
    return firestore.collection('users').where('id', isNotEqualTo: user.uid ).snapshots();
  }

  //for updating user information
  static Future<void> updateUserInfo() async{
    await firestore.collection('users').doc(user.uid).update({
      'name': me.name,
      'about': me.about
    });
  }
}