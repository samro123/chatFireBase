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
  //for storing all users
  List<ChatUsers> _lists = [];

  //for storing searched items
  final List<ChatUsers> _searchList = [];
  //for storing search items
  bool _isSearch = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    APIs.getSelfInfo();
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //for hiding keyboard when a tap is detected on screen 
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        //if sreach is on & back button is pressed then close search
        //of else simple close current screen on back button click
        onWillPop: (){
          if(_isSearch){
            setState(() {
              _isSearch = !_isSearch;
            });
            return Future.value(false);
          } else{
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: Icon(CupertinoIcons.home),
            title: _isSearch
                ? TextFormField(
              decoration:const InputDecoration(border: InputBorder.none, hintText: "Name, Email..."),
              autofocus: true,
              style:const TextStyle(fontSize: 17, letterSpacing: 0.5),
              //when search text changes then update search list
              onChanged: (val) {
                //search logic
                _searchList.clear();

                for(var i in _lists){
                  if(i.name.toLowerCase().contains(val.toLowerCase()) ||
                      i.email.toLowerCase().contains(val.toLowerCase())){
                    _searchList.add(i);
                  }
                  setState(() {
                    _searchList;
                  });
                }
              },
            )
                : Text("We chat"),
            actions: [
              //search button
              IconButton(
                  onPressed: (){
                    setState(() {
                      _isSearch = !_isSearch;
                    });
                  },
                  icon: Icon(_isSearch
                      ? CupertinoIcons.clear_circled_solid
                      :Icons.search)),
              //for more features button
              IconButton(onPressed: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ProfileScreen(users: APIs.me,),)
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
            stream: APIs.getAllUser(),
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
                _lists = data?.map((e) => ChatUsers.fromJson(e.data())).toList() ?? [];

               if(_lists.isNotEmpty){
                 return ListView.builder(
                   itemCount: _isSearch ? _searchList.length:_lists.length,
                   padding: EdgeInsets.only(top: mq.height * .01),
                   physics: BouncingScrollPhysics(),
                   itemBuilder: (context, index) {
                     return ChatUserCard(users: _isSearch ? _searchList [index] : _lists[index],);
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
        ),
      ),
    );
  }
}
