import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatfirebase/api/api.dart';
import 'package:chatfirebase/helper/my_date_util.dart';
import 'package:chatfirebase/main.dart';
import 'package:chatfirebase/models/chat_users.dart';
import 'package:chatfirebase/models/message.dart';
import 'package:chatfirebase/screens/chat_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUsers users;
  const ChatUserCard({Key? key, required this.users}) : super(key: key);

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {

  //last message info (if null --> no message)
  Message? _message;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * .04, vertical: 4),
      color: Colors.blue.shade100,
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (_)=> ChatScreen(users: widget.users)));
        },
        child: StreamBuilder(
          stream: APIs.getLastMessage(widget.users),
          builder: (context, snapshot) {

            final data = snapshot.data?.docs;
            final lists = data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
            if(lists.isNotEmpty) _message = lists[0];


            return ListTile(
              //leading: CircleAvatar(child: Icon(CupertinoIcons.person),),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * .3),
                child: CachedNetworkImage(
                  width: mq.height * .055,
                  height: mq.height * .055,
                  imageUrl: widget.users.image,
                  // placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const CircleAvatar(child: Icon(CupertinoIcons.person)),
                ),
              ),
              title: Text(widget.users.name),
              subtitle: Text(
                _message != null
                    ?_message!.type == Type.image
                    ? 'image'
                    :_message!.msg
                    : widget.users.about,
                maxLines: 1,),
              trailing: _message == null
                  ? null // show nothing when no message is sent
                  : _message!.read.isEmpty &&
                        _message!.fromId != APIs.user.uid
                  ?
              //show for unread message
              Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                    color: Colors.greenAccent.shade400,
                    borderRadius: BorderRadius.circular(10)
                ),
              ):
              Text(MyDateUtill.getLastMessageTime(context: context, time: _message!.sent), style: const TextStyle(color: Colors.black),),
            );
          },
        ),
      ),
    );
  }
}
