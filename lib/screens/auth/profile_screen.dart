import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatfirebase/api/api.dart';
import 'package:chatfirebase/helper/dialogs.dart';
import 'package:chatfirebase/main.dart';
import 'package:chatfirebase/models/chat_users.dart';
import 'package:chatfirebase/screens/auth/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUsers users;
  const ProfileScreen({Key? key, required this.users}) ;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:const Text("Profile Screen"),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.redAccent,
          onPressed: () async{
            //for showing progress dialog
            Dialogs.showProgressBar(context);

            //sign out from app
            await APIs.auth.signOut().then((value)async{
              await GoogleSignIn().signOut().then((value){
                // for hiding progress dialog
                Navigator.pop(context);

                //for removing to home
                Navigator.pop(context);
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
              });
            });
            
          },
          icon: const Icon(Icons.logout),
          label: Text('Logout'),
        ),
      ),
      body: Container(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
          child: Column(
            children: [
              SizedBox(
                height: mq.height * .03,
                width: mq.width,
              ) ,
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .1),
                    child: CachedNetworkImage(
                      width: mq.height * .2,
                      height: mq.height * .2,
                      imageUrl: widget.users.image,
                      fit: BoxFit.fill,
                      // placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const CircleAvatar(child: Icon(CupertinoIcons.person)),
                    ),
                  ),
                  
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: MaterialButton(
                      elevation: 1,
                      onPressed: (){},
                      child: const Icon(Icons.edit, color: Colors.blue,),
                      color: Colors.white,
                      shape: const CircleBorder(),
                    ),
                  )
                ],
              ),
              SizedBox(height: mq.height * .03,),
              
              Text(widget.users.email, style: TextStyle(color: Colors.black54, fontSize: 16),),
              SizedBox(height: mq.height * .05,),
              TextFormField(
                initialValue: widget.users.name,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person, color: Colors.blue,),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)
                  ),
                  hintText: 'eg. Happy Signh',
                  label:Text("Name"),

                ),
              ),
              SizedBox(height: mq.height * .02,),
              TextFormField(
                initialValue: widget.users.about,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.info_outline, color: Colors.blue,),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)
                  ),
                  hintText: 'eg. Feeling Happy',
                  label:Text("About"),

                ),
              ),
              SizedBox(height: mq.height * .02,),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(shape: StadiumBorder(), maximumSize: Size(mq.width * .5, mq.height* .06 )),
                onPressed: (){},
                icon: Icon(Icons.edit, size: 28,),
                label: Text('Update',style: TextStyle(fontSize: 16),),
              )
            ],
          ),
        ),
      ),
    );
  }
}
