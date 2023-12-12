import 'dart:convert';

import 'package:chatfirebase/models/chat_users.dart';
import 'package:chatfirebase/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io' as i;

import 'package:http/http.dart';

class APIs {

  //for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  //for accessing cloud firebase database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  //for accessing firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  //for storing self information
  static late ChatUsers me;

  // to return current user
  static User get user => auth.currentUser!;

  // for accessing firebase messaging (Push Notification)
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  //for getting firebase message token
  static Future<void> getFirebaseMessagingToken() async{
     await fMessaging.requestPermission();

     await fMessaging.getToken().then((t){
       if(t != null){
         me.pushToken = t;
         print('Push Token: $t');
       }
     });
  }

  //for sending push notification
  static Future<void> sendPushNotification(ChatUsers chatUsers, String mgs) async{
    try{
      final body =
      {
        "to": chatUsers.pushToken,
        "notification": {
          "title": chatUsers.name,
          "body": mgs,
          "android_channel_id": "chats"
        },
        "data": {
          "some_data" : "Use ID: ${me.id}",
        },
      };


      var response = await post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            i.HttpHeaders.contentTypeHeader: 'application/json',
            i.HttpHeaders.authorizationHeader:
            'key= AAAAONVUxZ0:APA91bFHbIL0Ti5mxljywQwqTU88J_3z_tO8Ef2y4aT1_yR5H_T23ZZT1miHkaNRzUg1E5saztiKRDaz3JFkluFheK59j_1_Sjn5BqHbT33svGrn-EZ-kQcUBkvo4FSOdtCKjVt97Yco'
          },
          body: jsonEncode(body)
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
    }catch(e){
          print('\nsendPushNotification: $e');
        }
  }

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
          await getFirebaseMessagingToken();

          //for setting user status to active
          APIs.updateActiveStatus(true);
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
    return firestore
        .collection('users')
        .where('id', isNotEqualTo: user.uid )
        .snapshots();
  }

  //for updating user information
  static Future<void> updateUserInfo() async{
    await firestore.collection('users').doc(user.uid).update({
      'name': me.name,
      'about': me.about
    });
  }

  //for profile picture of user
  static Future<void> updateProfilePicture(i.File file) async{
    //getting image file extension
    final ext = file.path.split('.').last;
    print('Extension: $ext');

    //storage file ref with auth
    final ref = storage.ref().child('profile_picture/${user.uid}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0){
          print("Data Transferred: ${p0.bytesTransferred / 1000} kb");
    });

    //uploading image in firestore database
    me.image = await ref.getDownloadURL();
    await firestore.collection('users').doc(user.uid).update({
      'image': me.image,
    });
  }

  // for getting specific user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUsers chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }



  // update online or last active status of user
  static Future<void> updateActiveStatus(bool isOnline) async{
    firestore
        .collection('users')
        .doc(user.uid)
        .update({
      'is_online' : isOnline,
      'last_active' : DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token' : me.pushToken
        });
  }

  /***********Chat Screen Reload APIs*************/

  // chats (collection) --> conversion_id(doc) --> message(collection) --> message(doc)

  //useful for getting conversation id
  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  //for getting all users of a specific conversation from firestore databse
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessage(ChatUsers user){
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .snapshots();
  }

  //for sending message
  static Future<void> sendMessage(ChatUsers chatUsers, String msg, Type type) async{

    //messages sending time (also used as id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    //messages to send
    final Message  message = Message(
        msg: msg,
        read: '',
        told: chatUsers.id,
        type: type,
        fromId: user.uid,
        sent: time);

    final ref =
        firestore.collection('chats/${getConversationID(chatUsers.id)}/messages/');
    await ref.doc(time).set(message.toJson()).then((value) => sendPushNotification(chatUsers, type == Type.text ? msg : 'image'));
  }

  //update read status of message
  static Future<void> updateMessageReadStatus(Message message)async{
    firestore.collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }
  //get only last message of a specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(ChatUsers user){
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

   //send chat image
  static Future<void> sendChatImage(ChatUsers chatUsers, i.File file) async{
    //getting image file extension
    final ext = file.path.split('.').last;

    //storage file ref with auth
    final ref = storage.ref().child('images/${getConversationID(chatUsers.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0){
      print("Data Transferred: ${p0.bytesTransferred / 1000} kb");
    });

    //uploading image in firestore database
    final imgURL = await ref.getDownloadURL();
    await sendMessage(chatUsers, imgURL, Type.image);
  }

  //delete message
  static Future<void> deleteMessage(Message message) async{
    await firestore.collection('chats/${getConversationID(message.told)}/messages/')
        .doc(message.sent)
        .delete();

    if(message.type == Type.image)
    await storage.refFromURL(message.msg).delete();
  }

  //update message
  static Future<void> updateMessage(Message message, String updatedMsg) async{
    await firestore.collection('chats/${getConversationID(message.told)}/messages/')
        .doc(message.sent)
        .update({'msg': updatedMsg});
  }
}