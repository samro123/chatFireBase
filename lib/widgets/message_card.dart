import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatfirebase/api/api.dart';
import 'package:chatfirebase/helper/dialogs.dart';
import 'package:chatfirebase/helper/my_date_util.dart';
import 'package:chatfirebase/main.dart';
import 'package:chatfirebase/models/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';

class MessageCard extends StatefulWidget {
  final Message message;
  const MessageCard({Key? key, required this.message}) : super(key: key);

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.message.fromId;
    return InkWell(
      onLongPress: (){
        _showBottomSheet(isMe);
      },
      child: isMe ? _greenMessage() : _blueMessage(),
    );

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
            padding: EdgeInsets.all(widget.message.type == Type.image
                ?mq.width * .03
                :mq.width * .04
            ),
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
            child: widget.message.type == Type.text ?
            Text(widget.message.msg, style: TextStyle(color: Colors.black87, fontSize: 15),)
            :   //user profile image
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CachedNetworkImage(
                imageUrl: widget.message.msg,
                placeholder: (context, url) => const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(strokeWidth: 2,),
                ),
                errorWidget: (context, url, error) => Icon(Icons.image,size: 70,),
              ),
            ),

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
            padding: EdgeInsets.all(widget.message.type == Type.image
                ?mq.width * .03
                :mq.width * .04
            ),
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
            child: widget.message.type == Type.text ?
            Text(widget.message.msg, style: TextStyle(color: Colors.black87, fontSize: 15),)
                :   //user profile image
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CachedNetworkImage(
                imageUrl: widget.message.msg,
                placeholder: (context, url) => const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(strokeWidth: 2,),
                ),
                errorWidget: (context, url, error) => Icon(Icons.image,size: 70,),
              ),
            ),
          ),
        ),
      ],
    );
  }


  // bottom sheet for picking a profile picture for user
  void _showBottomSheet(bool isMe){
    showModalBottomSheet(context: context,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20)
        )),
        builder: (_){
          return ListView(
            shrinkWrap: true,
            children: [
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(
                  vertical: mq.height * .015,
                  horizontal: mq.width * .4
                ),
                decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(8)),),
              widget.message.type == Type.text
              //Copy option
              ?_OptionItem(
                  icon:const Icon(
                    Icons.copy_all_rounded, color: Colors.blue, size: 26,),
                  name: 'Copy Text',
                  onTap: () async{
                      await Clipboard.setData(ClipboardData(text: widget.message.msg)).then((value){
                        Navigator.pop(context);

                        Dialogs.showSnackbar(context, 'Text Copied!');
                      });
                  }
              )
                  :_OptionItem(
                  icon:const Icon(
                    Icons.download_rounded, color: Colors.blue, size: 26,),
                  name: 'Save Image',
                  onTap: (){
                      try{
                        GallerySaver.saveImage(widget.message.msg, albumName: 'We chat').then((sucess){
                          Navigator.pop(context);
                          if(sucess!=null && sucess){
                            Dialogs.showSnackbar(context, 'Image Successfully Saved !');
                          }

                        });
                      }catch(e){
                        print('ErrorWhileSavingImg: $e');
                      }
                  }
              ),


              //separator or divider
              Divider(
                color: Colors.black54,
                endIndent: mq.width * .04,
                indent: mq.width * .04,
              ),

              //Edit option
              if(widget.message.type == Type.text && isMe)
                  _OptionItem(
                  icon:const Icon(
                    Icons.edit, color: Colors.blue, size: 26,),
                  name: 'Edit messages',
                  onTap: (){
                    Navigator.pop(context);
                    _showMessageUpdateDialog();
                  }
                  ),

              //Delete option
              if(isMe)
                  _OptionItem(
                  icon:const Icon(
                    Icons.delete, color: Colors.red, size: 26,),
                  name: 'Delete Message',
                  onTap: () async{
                    await APIs.deleteMessage(widget.message).then((value){
                        Navigator.pop(context);
                    });
                  }
                  ),

              //separator or divider
              Divider(
                color: Colors.black54,
                endIndent: mq.width * .04,
                indent: mq.width * .04,
              ),

              //Sent option
              _OptionItem(
                  icon:const Icon(
                    Icons.remove_red_eye, color: Colors.blue, size: 26,),
                  name: 'Send At: ${MyDateUtill.getMessageTime(context: context, time: widget.message.sent)}',
                  onTap: (){}
              ),

              //Read option
              _OptionItem(
                  icon:const Icon(
                    Icons.remove_red_eye, color: Colors.red, size: 26,),
                  name: widget.message.read.isEmpty
                      ? 'Read At: Not seen yet'
                      :'Read At: ${MyDateUtill.getMessageTime(context: context, time: widget.message.read)}',
                  onTap: (){}
              ),

            ],
          );
        });
  }

  //dialog for updating message content
 void _showMessageUpdateDialog(){
    String updateMsg = widget.message.msg;

    showDialog(context: context, builder: (_) => AlertDialog(
      contentPadding: EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20)
      ),
      title: Row(
        children: [
          const Icon(Icons.message, color: Colors.blue,size: 28,),
          const Text('Update Message')
        ],
      ),

      //content
      content: TextFormField(
        initialValue: updateMsg,
        onChanged: (value) => updateMsg = value,
        decoration: InputDecoration(border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15)
        )),),
      actions: [
        MaterialButton(onPressed: (){
          Navigator.pop(context);
        },child: Text('Cancel', style: TextStyle(color: Colors.blue, fontSize: 16),),),
        MaterialButton(onPressed: (){
          Navigator.pop(context);
          APIs.updateMessage(widget.message, updateMsg);

        },child: Text('Update', style: TextStyle(color: Colors.blue, fontSize: 16),),)
      ],
    ),);
 }
}

class _OptionItem extends StatelessWidget {
  final String name;
  final Icon icon;
  final VoidCallback onTap;
  const _OptionItem({Key? key,required this.icon, required this.name,  required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ()=> onTap(),
      child: Padding(
        padding:  EdgeInsets.only(
            left: mq.width * .05,
            top: mq.height * .015,
            bottom: mq.height * .025
        ),
        child: Row(
          children: [
            icon,
            Text('    $name', style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
              letterSpacing: 0.5
            ),),
          ],
        ),
      ),
    );
  }
}

