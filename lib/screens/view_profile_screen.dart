import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatfirebase/api/api.dart';
import 'package:chatfirebase/helper/dialogs.dart';
import 'package:chatfirebase/helper/my_date_util.dart';
import 'package:chatfirebase/main.dart';
import 'package:chatfirebase/models/chat_users.dart';
import 'package:chatfirebase/screens/auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class ViewProfileScreen extends StatefulWidget {
  final ChatUsers users;
  const ViewProfileScreen({Key? key, required this.users}) ;

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //for hiding keyboard
      onTap: ()=> FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.users.name),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Joined On: ', style: TextStyle(fontWeight: FontWeight.w500,color: Colors.black87,fontSize: 16),),
            Text(MyDateUtill.getLastMessageTime(context: context, time: widget.users.lastActive, showYear: true), style: TextStyle(color: Colors.black54, fontSize: 16),),
          ],
        ),
        body: Padding(
          padding:EdgeInsets.symmetric(horizontal: mq.width * .05),
          child: SingleChildScrollView(
            child: Container(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
                child: Column(
                  children: [
                    SizedBox(
                      height: mq.height * .03,
                      width: mq.width,
                    ) ,
                    ClipRRect(
                      borderRadius: BorderRadius.circular(mq.height * .1),
                      child: CachedNetworkImage(
                        width: mq.height * .2,
                        height: mq.height * .2,
                        imageUrl: widget.users.image,
                        fit: BoxFit.cover,
                        // placeholder: (context, url) => CircularProgressIndicator(),
                        errorWidget: (context, url, error) => const CircleAvatar(child: Icon(CupertinoIcons.person)),
                      ),
                    ),
                    SizedBox(height: mq.height * .03,),

                    Text(widget.users.email, style: TextStyle(color: Colors.black54, fontSize: 15),),
                    SizedBox(height: mq.height * .02,),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('About', style: TextStyle(fontWeight: FontWeight.w500,color: Colors.black87,fontSize: 16),),
                        Text(widget.users.email, style: TextStyle(color: Colors.black54, fontSize: 15),),
                      ],
                    ),

                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


}
