import 'dart:io';
import 'dart:math';
import 'package:chatfirebase/api/api.dart';
import 'package:chatfirebase/helper/dialogs.dart';
import 'package:chatfirebase/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../main.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(milliseconds: 500),(){
        setState(() {
          _isAnimate = true;
        });
    });
  }


   //handles google login button click
  _handleGoogleBtnClick(){
    //for showing progress bar
      Dialogs.showProgressBar(context);
      _signInWithGoogle().then((users) async {
        //for hiding progress bar
        Navigator.pop(context);
        if(users != null){
          print('User: ${users.user}');
          print('User: ${users.additionalUserInfo}');

          if((await APIs.userExists())){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>HomeScreen()));
          } else{
            await APIs.createUser().then((value){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>HomeScreen()));
            });
          }
        }

      });
  }
  Future<UserCredential?> _signInWithGoogle() async {
    try{
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    }catch(e){
       print("\n _signInWithGoogle: $e");
       Dialogs.showSnackbar(context, 'Something went Wrong (Check Internet)');
       return null;
    }
  }
  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome to We Chat"),
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
              top: mq.height * .15,
              right:_isAnimate ? mq.width * .25 : -mq.width * .5,
              width: mq.width * .5,
              duration: Duration(
                seconds: 1
              ),
              child: Image.asset('images/icon.png')
          ),
          Positioned(
              bottom: mq.height * .15,
              left: mq.width * .05,
              width: mq.width * .9,
              height: mq.height * .06,
              child:ElevatedButton.icon(
                  onPressed: (){
                   _handleGoogleBtnClick();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen,
                    shape: const StadiumBorder(),
                    elevation: 1
                  ),
                  icon: Image.asset("images/google.png", height: mq.height *.03 ,),
                  label: Text("Sign In with Google", style: TextStyle(fontSize: 16),))
          ),
        ],
      ),
    );
  }
}
