import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_task/pages/home.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  logInWithFacebook() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    final facebookLogin = new FacebookLogin();
    final result = await facebookLogin.logIn(['email']);
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:

        final AuthCredential credential = FacebookAuthProvider.credential(result.accessToken.token);
        final UserCredential user = await FirebaseAuth.instance.signInWithCredential(credential);
        print(result.accessToken.token);
        pref.setString('login', user.user.email);
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>Home()));
        break;
      case FacebookLoginStatus.cancelledByUser:
        print('CANCELED BY USER');
        break;
      case FacebookLoginStatus.error:
        print(result.errorMessage);
        break;
    }
  }

  static Future<User> loginInWithGoogle({BuildContext context}) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    FirebaseAuth auth = FirebaseAuth.instance;
    User user;

    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {

        final UserCredential userCredential =
            await auth.signInWithCredential(credential);

        user = userCredential.user;

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Home()));

        pref.setString('login', user.email);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          // handle the error here
        } else if (e.code == 'invalid-credential') {
          // handle the error here
        }
      } catch (e) {
        // handle the error here
      }
    }

    return user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Login ',style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),),
              Divider(endIndent: 135,indent: 125,height: 5,thickness: 1,color: Colors.blue,),
              SizedBox(
                height: 50,
              ),
              Material(
                  borderRadius: BorderRadius.circular(20.0),
                  color: Colors.blue,
                  elevation: 0.0,
                  child: MaterialButton(
                    onPressed: () {
                      logInWithFacebook();
                    },
                    minWidth: MediaQuery.of(context).size.width,
                    child: Text(
                      "Facebook",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0),
                    ),
                  )),
              SizedBox(
                height: 10,
              ),
              Material(
                  borderRadius: BorderRadius.circular(20.0),
                  color: Colors.deepOrange,
                  elevation: 0.0,
                  child: MaterialButton(
                    onPressed: () {
                      loginInWithGoogle(context: context);
                    },
                    minWidth: MediaQuery.of(context).size.width,
                    child: Text(
                      "Google",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0),
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
