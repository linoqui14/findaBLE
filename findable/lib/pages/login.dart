import 'dart:io';

import 'package:findable/my_widgets/custom_text_button.dart';
import 'package:findable/my_widgets/custom_textfield.dart';
import 'package:findable/my_widgets/press_on_text.dart';
import 'package:findable/pages/user_page.dart';
import 'package:findable/tools/variables.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../models/users.dart';
import '../my_widgets/pressable.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key,}) : super(key: key);


  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  Future<String?> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) { // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if(Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId; // unique ID on Android
    }
  }

  @override
  void initState() {

    _getId().then((value) {

      DBController.getCurrentLogin(deviceID: value).then((res) {

        if(res==null)return;
        User user = res;
        if(user.isLogin){
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => UserPage(user: user,)),
                (Route<dynamic> route) => false,
          );
        }

      });
    });

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(

                  padding: EdgeInsets.all(20),
                  child: Image.asset("img/logo.png")
              ),
              Column(
                children: [
                  Container(
                    margin: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: MyColors.darkBlue,
                        borderRadius: BorderRadius.all(Radius.circular(20))
                    ),
                    padding: EdgeInsets.all(20),
                    child:Column(
                      children: [
                        CustomTextField(
                            icon: Icons.person,
                            color: Colors.white,
                            hint: "Name",
                            controller: username,

                        ),
                        CustomTextField(
                          icon: Icons.password,
                          color: Colors.white,
                          hint: "Password",
                          controller: password,
                        ),
                        CustomTextButton(
                          color: Colors.blue,
                          onPressed: (){
                            if(password.text.isNotEmpty&&username.text.isNotEmpty){
                              _getId().then((deviceID){
                                DBController.getUser(username: username.text, password: password.text,deviceID: deviceID!).then((user) {
                                  if(user==null)return;
                                  user.isLogin = true;
                                  DBController.upsertUser(user: user).then((updatedUser){
                                    // print(updatedUser!.deviceID);
                                    if(updatedUser==null) return;
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(builder: (context) => UserPage(user: updatedUser,)),
                                          (Route<dynamic> route) => false,
                                    );
                                  });

                                });
                              });

                            }

                          },
                          text: "Login",
                        )




                      ],
                    ),
                  ),
                  Text("or"),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: PressOnText(
                        textStyle: TextStyle(color: Colors.black87),
                        text: "Create an %press",
                        pressables: [
                          Pressable(
                              text: Text("Account",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: MyColors.darkBlue),),
                              onPressed: (){
                                TextEditingController username = TextEditingController();
                                TextEditingController password = TextEditingController();
                                bool hidePassword = true;
                                Tools.basicDialog(
                                    context: context,
                                    statefulBuilder: StatefulBuilder(
                                        builder: (context,setStateRegistration){

                                          return Dialog(
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10)),
                                            backgroundColor: Colors.transparent,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(bottom: 5,left: 15),
                                                  child: Text("Registration",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30,color: Colors.white),),
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.all(Radius.circular(20))
                                                  ),
                                                  height: 200,
                                                  width: double.infinity,
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      CustomTextField(
                                                          icon: Icons.person,
                                                          color: Colors.blue,
                                                          hint: "Username",
                                                          controller: username
                                                      ),
                                                      CustomTextField(
                                                        obscureText: hidePassword,
                                                        color: Colors.blue,
                                                        hint: "Password",
                                                        icon: Icons.password,
                                                        controller: password,
                                                        suffix: IconButton(
                                                          splashRadius: 1,
                                                          onPressed: (){
                                                            setStateRegistration((){
                                                              hidePassword=hidePassword?false:true;
                                                            });
                                                          },
                                                          icon: Icon(hidePassword?Icons.visibility_off:Icons.visibility),
                                                        ),
                                                      ),
                                                      CustomTextButton(
                                                        color: MyColors.darkBlue,
                                                        text: "Register",
                                                        onPressed: (){
                                                          if(password.text.isNotEmpty&&username.text.isNotEmpty){
                                                            _getId().then((value) {
                                                              DBController.upsertUser(user: User(name: username.text,password: password.text,deviceID: value!)).then((value) {
                                                                if(value!=null){
                                                                  Navigator.of(
                                                                      context)
                                                                      .pop();
                                                                  Fluttertoast
                                                                      .showToast(
                                                                      msg: "Successfully Register",
                                                                      toastLength: Toast
                                                                          .LENGTH_SHORT,
                                                                      gravity: ToastGravity
                                                                          .BOTTOM,
                                                                      timeInSecForIosWeb: 1,
                                                                      backgroundColor: MyColors.darkBlue,
                                                                      textColor: Colors.white,
                                                                      fontSize: 16.0
                                                                  );
                                                                }
                                                                else{
                                                                  Fluttertoast
                                                                      .showToast(
                                                                      msg: "Registration Failed",
                                                                      toastLength: Toast
                                                                          .LENGTH_SHORT,
                                                                      gravity: ToastGravity
                                                                          .BOTTOM,
                                                                      timeInSecForIosWeb: 1,
                                                                      backgroundColor: MyColors.red,
                                                                      textColor: Colors.white,
                                                                      fontSize: 16.0
                                                                  );
                                                                }
                                                              });
                                                            });

                                                          }
                                                        },
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                    )
                                );
                              }
                          ),
                          // Pressable(text: Text(""), onPressed: (){})
                        ]),
                  ),

                ],
              ),


              Center(),
              Center()
            ],
          ),
        ),
      ),

    );
  }
}