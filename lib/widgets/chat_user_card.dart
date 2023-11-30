import 'package:chatfirebase/main.dart';
import 'package:chatfirebase/models/chat_users.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUsers users;
  const ChatUserCard({Key? key, required this.users}) : super(key: key);

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * .04, vertical: 4),
      color: Colors.blue.shade100,
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: (){},
        child: ListTile(
          leading: CircleAvatar(child: Icon(CupertinoIcons.person),),
          title: Text(widget.users.name),
          subtitle: Text(widget.users.about, maxLines: 1,),
          trailing: Text("12:00 PM", style: TextStyle(color: Colors.black54),),
        ),
      ),
    );
  }
}
