import 'dart:convert';

import 'package:chatfirebase/api/api.dart';
import 'package:chatfirebase/main.dart';
import 'package:chatfirebase/screens/auth/profile_screen.dart';
import 'package:chatfirebase/widgets/chat_user_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/chat_users.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUsers> lists = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(CupertinoIcons.home),
        title: Text("We chat"),
        actions: [
          IconButton(onPressed: (){}, icon:const Icon(Icons.search)),
          IconButton(onPressed: (){
            Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfileScreen(users: lists[0],),)
            );
          }, icon:const Icon(Icons.more_vert_rounded))
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FloatingActionButton(
          onPressed: () async{
            await APIs.auth.signOut();
            await GoogleSignIn().signOut();
          },
          child: const Icon(Icons.add_comment_rounded),
        ),
      ),
      body: StreamBuilder(
        stream: APIs.firestore.collection('users').snapshots(),
        builder: (context, snapshot) {

          switch(snapshot.connectionState){
            //if data is loading
            case ConnectionState.waiting:
            case ConnectionState.none:
              return const Center(child: CircularProgressIndicator(),);

            //if some or all data is loaded then show it
            case ConnectionState.active:
            case ConnectionState.done:


            final data = snapshot.data?.docs;
            lists = data?.map((e) => ChatUsers.fromJson(e.data())).toList() ?? [];

           if(lists.isNotEmpty){
             return ListView.builder(
               itemCount: lists.length,
               padding: EdgeInsets.only(top: mq.height * .01),
               physics: BouncingScrollPhysics(),
               itemBuilder: (context, index) {
                 return ChatUserCard(users: lists[index],);
               },
             );
           }else{
             return Center(
                 child: const Text(
                     "No connections Found! ",
                      style: TextStyle(fontSize: 20),
                 ));
           }
          }
        },
      ),
    );
  }
}
