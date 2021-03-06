import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_task/pages/login.dart';
import 'package:flutter_task/pages/print.dart';
import 'package:flutter_task/pages/web_view.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _url = TextEditingController();

  goToUrl() {
    FocusScope.of(context).unfocus();
    final isValidate = _formKey.currentState.validate();
    if (!isValidate) {
      print('Error');
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WebViewPage(
                    url: 'https://${_url.text}/',
                  )));
    }
  }

  List strLise = ['Bluetooth', 'WiFi'];
  String val;

  logout()async{
    final facebookLogin = new FacebookLogin();
    final GoogleSignIn googleSignIn = GoogleSignIn();
    try {
      if (!kIsWeb) {
        await googleSignIn.signOut();
      }
      await FirebaseAuth.instance.signOut();
      await facebookLogin.logOut();
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.remove('login');
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Login()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.black,
          content: Text('Error signing out. Try again.'),
        ),
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        centerTitle: true,
         actions: [
           IconButton(icon: Icon(Icons.logout),onPressed: (){
             logout();
           },)
         ],
      ),
      body: Container(
        padding: EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Material(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.grey.withOpacity(0.2),
                elevation: 0.0,
                child: Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: ListTile(
                    title: TextFormField(
                      controller: _url,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Url : www.google.com",
                        icon: Icon(Icons.link),
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please make sure that url is valid';
                        } else {
                          return null;
                        }
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Material(
                  borderRadius: BorderRadius.circular(20.0),
                  color: Colors.blue,
                  elevation: 0.0,
                  child: MaterialButton(
                    onPressed: () {
                      goToUrl();
                    },
                    minWidth: MediaQuery.of(context).size.width,
                    child: Text(
                      "Go to url",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0),
                    ),
                  )),
              SizedBox(
                height: 50,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Select Type '),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButton(
                      onChanged: (value) {
                        setState(() {
                          val = value;
                        });
                      },
                      hint: Text('select type'),
                      items: strLise.map((e) {
                        return DropdownMenuItem(
                          child: Text(e),
                          value: e,
                        );
                      }).toList(),
                      value: val,
                    ),
                  )
                ],
              ),
              Material(
                  borderRadius: BorderRadius.circular(20.0),
                  color: Colors.greenAccent,
                  elevation: 0.0,
                  child: MaterialButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>Print(val: val,)));
                    },
                    child: Text(
                      "Search devices",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
