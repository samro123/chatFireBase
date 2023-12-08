import 'package:chatfirebase/api/api.dart';
import 'package:chatfirebase/helper/my_date_util.dart';
import 'package:chatfirebase/main.dart';
import 'package:chatfirebase/models/message.dart';
import 'package:flutter/material.dart';

class MessageCard extends StatefulWidget {
  final Message message;
  const MessageCard({Key? key, required this.message}) : super(key: key);

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return APIs.user.uid == widget.message.fromId
           ? _greenMessage()
           : _blueMessage()
    ;
  }

  //sender or another user message
  Widget _blueMessage(){

    //update last read message if sender and receiver are different
    if(widget.message.read.isEmpty){
      APIs.updateMessageReadStatus(widget.message);
      print("message read updated");
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //message content
        Flexible(
          child: Container(
            padding: EdgeInsets.all(mq.width * .04),
            margin: EdgeInsets.symmetric(horizontal: mq.width * .04, vertical: mq.height * .01),
            decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius:const BorderRadius.only(
                  topRight: Radius.circular(30),
                  topLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30)
                ),
                border: Border.all(color: Colors.lightBlue)
            ),
            child: Text(widget.message.msg, style: TextStyle(color: Colors.black87, fontSize: 15),),
          ),
        ),

        //message time
        Padding(
          padding:  EdgeInsets.only(right: mq.width * .04),
          child: Text(MyDateUtill.getFormattedTime(context: context, time: widget.message.sent), style: TextStyle(color: Colors.black54, fontSize: 13),),
        ),
      ],
    );
  }

  //our or user message
  Widget _greenMessage(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //message time
        Row(
          children: [
            //for adding some space
            SizedBox(width: mq.width * .04,),
            //double tick blue icon for message read

            //double tick blue icon for message read
            if(widget.message.read.isNotEmpty)
              const Icon(Icons.done_all_outlined, color: Colors.blue,size: 20,),
            SizedBox(width: 2,),
            //read time
            Text(MyDateUtill.getFormattedTime(context: context, time: widget.message.sent), style: TextStyle(color: Colors.black54, fontSize: 13),),
          ],
        ),
        //message content
        Flexible(
          child: Container(
            padding: EdgeInsets.all(mq.width * .04),
            margin: EdgeInsets.symmetric(horizontal: mq.width * .04, vertical: mq.height * .01),
            decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius:const BorderRadius.only(
                    topRight: Radius.circular(30),
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30)
                ),
                border: Border.all(color: Colors.lightGreen)
            ),
            child: Text(widget.message.msg, style: TextStyle(color: Colors.black87, fontSize: 15),),
          ),
        ),
      ],
    );
  }
}
