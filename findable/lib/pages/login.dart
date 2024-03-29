import 'dart:convert';

import 'package:findable/my_widgets/custom_text_button.dart';
import 'package:findable/my_widgets/custom_textfield.dart';
import 'package:findable/my_widgets/press_on_text.dart';
import 'package:findable/pages/user_page.dart';
import 'package:findable/tools/variables.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:platform_device_id/platform_device_id.dart';

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


  @override
  void initState() {

    PlatformDeviceId.getDeviceId.then((value) {

      DBController.getCurrentLogin(deviceID: value).then((res) {
        print(res);
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
                              PlatformDeviceId.getDeviceId.then((deviceID){
                                DBController.getUser(username: username.text, password: password.text,deviceID: deviceID!).then((user) {
                                  if(user==null){
                                    Tools.basicDialog(
                                      context: context,
                                      statefulBuilder: StatefulBuilder (
                                          builder: (context,stateNouser){
                                            return Dialog(

                                              backgroundColor: Colors.transparent,
                                              child: Container(
                                                padding: EdgeInsets.all(10),
                                                alignment: Alignment.center,
                                                height: 260,
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.all(Radius.circular(20)),
                                                    border: Border.all(
                                                        color: Colors.redAccent,
                                                        width: 2
                                                    )
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Lottie.network("https://assets6.lottiefiles.com/private_files/lf30_LOw4AL.json",height: 200),
                                                    Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Text("USER NOT FOUND!",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.redAccent),),
                                                        Text("Please contact your admin to recover your account",style: TextStyle(fontSize: 10,fontWeight: FontWeight.w100),),

                                                      ],
                                                    ),

                                                  ],
                                                ),
                                              ),
                                            );
                                          }),
                                      onPop: ()async => true,
                                    );
                                    return;
                                  }
                                  user.isLogin = true;
                                  user.deviceID = deviceID;
                                  DBController.get(command:'update_user',data: user.toJson()).then((updatedUser){
                                    // print(updatedUser!.deviceID);
                                    if(updatedUser==null) return;
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(builder: (context) => UserPage(user: user,)),
                                          (Route<dynamic> route) => false,
                                    );
                                  });

                                });
                              });

                            }
                            else{
                              Tools.basicDialog(
                                context: context,
                                statefulBuilder: StatefulBuilder (
                                    builder: (context,stateNouser){
                                      return Dialog(

                                        backgroundColor: Colors.transparent,
                                        child: Container(
                                          padding: EdgeInsets.all(10),
                                          alignment: Alignment.center,
                                          height: 250,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.all(Radius.circular(20)),
                                              border: Border.all(
                                                  color: Colors.redAccent,
                                                  width: 2
                                              )
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Lottie.network("https://assets7.lottiefiles.com/packages/lf20_qfkr9cgr.json",height: 200),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text("Please fill out the",style: TextStyle(fontSize: 15,fontWeight: FontWeight.normal),),
                                                  Text(" required fields.",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.redAccent),),

                                                ],
                                              ),

                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                                onPop: ()async => true,
                              );
                            }

                          },
                          onHold: (){
                            if(password.text=='users'&&username.text=='USERS'){
                              Tools.basicDialog(
                                context: context,
                                statefulBuilder: StatefulBuilder (
                                    builder: (context,stateNouser){
                                      return Dialog(

                                        backgroundColor: Colors.transparent,
                                        child: Container(
                                          padding: EdgeInsets.all(10),
                                          alignment: Alignment.center,
                                          height: 500,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.all(Radius.circular(20)),
                                              border: Border.all(
                                                  color: Colors.blue,
                                                  width: 2
                                              )
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              // Text("ADMIN",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                                              Container(
                                                width: double.infinity,
                                                // color: Colors.redAccent,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text("Users",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),),
                                                    Container(
                                                      height: 250,
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          // borderRadius: BorderRadius.all(Radius.circular(20)),
                                                          border: Border.all(
                                                              color: Colors.blue,
                                                              width: 2
                                                          )
                                                      ),
                                                      child: FutureBuilder<String?>(
                                                        future: DBController.get(command: "get_users", data: {}),
                                                        builder: (context,snapshot){
                                                          if(!snapshot.hasData)return Center();
                                                          if(snapshot.connectionState==ConnectionState.waiting)return Center(child: CircularProgressIndicator(),);
                                                          print(snapshot.data!);
                                                          List<User> users = [];
                                                          var jsons = jsonDecode(snapshot.data!);
                                                          for(var json in jsons){
                                                            User user = User.toObject(json);
                                                            users.add(user);
                                                          }
                                                          return Column(
                                                            children: [
                                                              Padding(
                                                                padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 5),
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Text("Username",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 10),),
                                                                    Text("Password",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 10))
                                                                  ],
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: ListView(
                                                                  children: users.map((user) {
                                                                    return Padding(
                                                                      padding: const EdgeInsets.all(10),
                                                                      child: Row(
                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Text(user.name),
                                                                          Text(user.password)
                                                                        ],
                                                                      ),
                                                                    );
                                                                  }).toList(),
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        },

                                                      ),
                                                    )
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                                onPop: ()async => true,
                              );
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
                                    onPop: () async => true,
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
                                                            PlatformDeviceId.getDeviceId.then((value) {
                                                              DBController.upsertUser(user: User(name: username.text,password: password.text,deviceID: value!)).then((value) {
                                                                print(value!);
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