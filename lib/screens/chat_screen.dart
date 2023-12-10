import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatfirebase/api/api.dart';
import 'package:chatfirebase/helper/my_date_util.dart';
import 'package:chatfirebase/main.dart';
import 'package:chatfirebase/models/chat_users.dart';
import 'package:chatfirebase/models/message.dart';
import 'package:chatfirebase/widgets/emoji_show.dart';
import 'package:chatfirebase/widgets/message_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  final ChatUsers users;
  const ChatScreen({Key? key, required this.users});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //for storing all message
  List<Message> _lists = [];

  //for handing message text changes
  final _textController = TextEditingController();


  //for storing value of showing or hiding emoji
  bool _showEmoji = false;

  //for checking if image is uploading or not?
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=> FocusScope.of(context).unfocus(),
      child: WillPopScope(
        //if sreach is on & back button is pressed then close search
        //of else simple close current screen on back button click
        onWillPop: (){
          if(_showEmoji){
            setState(() {
              _showEmoji = !_showEmoji;
            });
            return Future.value(false);
          } else{
            return Future.value(true);
          }
        },
        child: SafeArea(
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
            ),

            //body
            body: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: APIs.getAllMessage(widget.users),
                  builder: (context, snapshot) {

                    switch(snapshot.connectionState){
                    //if data is loading
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return const SizedBox();


                    //if some or all data is loaded then show it
                      case ConnectionState.active:
                      case ConnectionState.done:
                        final data = snapshot.data?.docs;
                        _lists = data?.map((e) => Message.fromJson(e.data())).toList() ?? [];


                        if(_lists.isNotEmpty){
                          return ListView.builder(
                           // reverse: true,
                            itemCount: _lists.length,
                            padding: EdgeInsets.only(top: mq.height * .01),
                            physics: BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return MessageCard(message: _lists[index],);
                            },
                          );
                        }else{
                          return Center(
                              child: const Text(
                                "Say Hi! 👋 ",
                                style: TextStyle(fontSize: 20),
                              ));
                        }
                    }
                  },
                ),
              ),

              //progress indicator for showing uploading
              if(_isUploading)
                const Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: CircularProgressIndicator(strokeWidth: 2,),
                ),
              ),
              _chatInput(),

              //show emojis on keyboard emoji button click & vice versa
              if(_showEmoji)
                EmojiShow(textControler: _textController)
            ],),
          ),
        ),
      ),
    );
  }

  Widget _appBar(){
    return InkWell(
      onTap: (){},
      child: StreamBuilder(
        stream: APIs.getUserInfo(widget.users),
        builder: (context, snapshot) {
          final data = snapshot.data?.docs;
          final lists =
              data?.map((e) => ChatUsers.fromJson(e.data())).toList() ?? [];
          return Row(
            children: [
              //back button
              IconButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
              ),

              //user profile image
              ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * .3),
                child: CachedNetworkImage(
                  width: mq.height * .05,
                  height: mq.height * .05,
                  imageUrl:lists.isNotEmpty ? lists[0].image : widget.users.image,
                  // placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const CircleAvatar(child: Icon(CupertinoIcons.person)),
                ),
              ),

              const SizedBox(width: 10,),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lists.isNotEmpty ? lists[0].name : widget.users.name,
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500),),

                  //for adding some space
                  const SizedBox(height: 2,),

                  //last seen time of user
                  Text(
                    lists.isNotEmpty
                        ? lists[0].isOnline
                          ? 'Online'
                          : MyDateUtill.getLastActiveTime(context: context, lastActive: lists[0].lastActive)
                        :  MyDateUtill.getLastActiveTime(context: context, lastActive: widget.users.lastActive),
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500),),
                ],),
            ],
          );
        },
      ),
    );
  }

  //bottom chat input field
  Widget _chatInput(){
    return Padding(
      padding:  EdgeInsets.symmetric(vertical: mq.height * .01,horizontal: mq.width * .025),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  //emoji button
                  IconButton(
                    onPressed: (){
                      FocusScope.of(context).unfocus();
                      setState(() => _showEmoji = !_showEmoji);
                    },
                    icon: const Icon(
                      Icons.emoji_emotions,
                      color: Colors.blueAccent,
                    ),
                  ),

                  //Text field
                  Expanded(child: TextField(
                    controller: _textController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    onTap: (){
                      if(_showEmoji) setState(() => _showEmoji = !_showEmoji);
                    },
                    decoration: const InputDecoration(
                      hintText: 'Type Something...',
                      hintStyle: TextStyle(color: Colors.blueAccent),
                      border: InputBorder.none,
                    ),
                  )),
                  //pick image from gallery button
                  IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      // Pick multiple image
                      final List<XFile> images =
                          await picker.pickMultiImage(imageQuality: 70);

                      //uploading & sending image one by one
                      for (var i in images) {
                        setState(() => _isUploading = true);
                        await APIs.sendChatImage(widget.users,File(i.path));
                        setState(() => _isUploading = false);
                      }

                    },
                    icon: const Icon(
                      Icons.image,
                      color: Colors.blueAccent,
                    ),
                  ),
                  //take image from camera button
                  IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      // Pick an image
                      final XFile? image = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
                      if(image !=null){
                        setState(() => _isUploading = true);
                        print('Image Path: ${image.path} -- MineType: ${image.mimeType}');
                        await APIs.sendChatImage(widget.users,File(image.path));
                        setState(() => _isUploading = false);

                      }
                    },
                    icon: const Icon(
                      Icons.camera,
                      color: Colors.blueAccent,
                    ),
                  ),

                SizedBox(width: mq.width * .02,)
                ],
              ),
            ),
          ),

          //send message button
          MaterialButton(
            onPressed: (){
              if (_textController.text.isNotEmpty){
                APIs.sendMessage(widget.users, _textController.text, Type.text);
                _textController.text = '';
              }
            },
            minWidth: 0,
            color: Colors.lightGreen,
            padding: const EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            child: Icon(Icons.send, color: Colors.white, size: 28,),
            shape: CircleBorder(),
          )
        ],
      ),
    );
  }
}
