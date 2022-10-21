import 'package:findable/my_widgets/custom_text_button.dart';
import 'package:findable/my_widgets/custom_textfield.dart';
import 'package:findable/pages/login.dart';
import 'package:flutter/material.dart';

import '../models/room.dart';
import '../models/users.dart';
import '../tools/variables.dart';


class UserPage extends StatefulWidget {
  const UserPage({Key? key, required this.user}) : super(key: key);
  final User user;


  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> with SingleTickerProviderStateMixin{
  late TabController _tabController;
  List<Room> rooms = [];
  void initState() {
    super.initState();
    _tabController = new TabController(length: 2, vsync: this);
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SafeArea(
        child:Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: GestureDetector(
              onTap: (){
                TextEditingController name = TextEditingController(text: widget.user.name);
                TextEditingController password = TextEditingController(text: widget.user.password);
                bool showPassword = false,isEdit = false;
                Tools.basicDialog(context: context,
                    statefulBuilder: StatefulBuilder(
                      builder: (context,setState1){
                        return Dialog(
                          alignment: Alignment.center,
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                          child: SingleChildScrollView(
                            child: Container(
                              margin: EdgeInsets.only(top: 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Account Manager",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,color: Colors.white),),
                                      IconButton(
                                          splashRadius: 0.1,
                                          onPressed: (){
                                            Navigator.of(context).pop();
                                          },
                                          icon: Icon(Icons.highlight_off,color: Colors.white,))
                                    ],
                                  ),
                                  Padding(padding: EdgeInsets.symmetric(vertical: 5)),
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            color: Colors.transparent
                                        ),
                                        borderRadius: BorderRadius.only(
                                          topLeft:Radius.circular(20),
                                          topRight:Radius.circular(20),
                                          bottomRight:Radius.circular(20),
                                          bottomLeft:Radius.circular(0),
                                        )
                                    ),
                                    padding: EdgeInsets.all(20),
                                    width: double.infinity,
                                    height: 300,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        CustomTextField(
                                          enable: isEdit,
                                          icon: Icons.face,
                                          filledColor: Colors.blue.shade50,
                                          filled: true,
                                          borderWidth: 3,
                                          color: Colors.blue,
                                          rAll: 20,
                                          controller: name,
                                          hint: 'Name',

                                        ),
                                        CustomTextField(
                                          enable: isEdit,
                                          suffix: IconButton(
                                            onPressed: (){
                                              setState1(() {
                                                showPassword = showPassword?false:true;
                                              });
                                            },
                                            icon: Icon(showPassword?Icons.visibility_rounded:Icons.visibility_off_rounded,color: Colors.blue.withAlpha(isEdit?255:50),),
                                          ),
                                          obscureText: !showPassword,
                                          icon: Icons.key_rounded,
                                          filledColor: Colors.blue.shade50,
                                          filled: true,
                                          borderWidth: 3,
                                          color: Colors.blue,
                                          rAll: 20,
                                          controller: password,
                                          hint: 'Password',

                                        ),
                                        CustomTextButton(
                                          onPressed: (){
                                            setState1(() {
                                              isEdit = isEdit?false:true;
                                            });
                                            setState(() {

                                            });
                                            if(!isEdit&& password.text.isNotEmpty&& name.text.isNotEmpty){
                                              widget.user.password = password.text;
                                              widget.user.name = name.text;
                                              DBController.upsertUser(user: widget.user).then((value) {
                                                print(value);
                                              });
                                            }

                                          },
                                          rAll: 20,
                                          text: !isEdit?"Edit":'Save',
                                          color: !isEdit?Colors.indigo:Colors.blue,
                                        )
                                      ],
                                    ),
                                  ),
                                  CustomTextButton(
                                      onPressed: (){
                                        widget.user.deviceID = '';
                                        widget.user.isLogin = false;
                                        DBController.upsertUser(user: widget.user).then((updatedUser){
                                          if(updatedUser==null) return;
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(builder: (context) => const LoginPage()),
                                                (Route<dynamic> route) => false,
                                          );
                                        });
                                      },
                                      padding: EdgeInsets.zero,
                                      color: Colors.black38,
                                      rTopLeft: 0,
                                      rBottomLeft: 20,
                                      rBottomRight: 20,
                                      rTopRight: 20,
                                      text:'Logout'
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )
                );
              },
              child: Row(
                children: [
                  Icon(Icons.face,color: Colors.blue,),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
                  Text(widget.user.name,style: TextStyle(color: Colors.blue),)
                ],
              ),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              Container(
                child: Text('Room'),
              ),
              Container(
                child: Text('Tags'),
              )
            ],
          ),
          floatingActionButton:FloatingActionButton(
            //Floating action button on Scaffold
            onPressed: (){
              switch(_tabController.index){
                case 0:
                  Tools.basicDialog(
                      context: context,
                      statefulBuilder: StatefulBuilder(
                        builder: (contex,setState1){
                          return Dialog(
                            elevation: 0,
                            alignment: Alignment.center,
                            backgroundColor: Colors.transparent,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Room',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 18),),
                                Container(
                                  width: double.infinity,
                                  height: 300,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(Radius.circular(20))
                                  ),
                                  child: Text("Add ROOM"),
                                ),
                              ],
                            ),
                          );
                        },
                      )
                  );
                  break;
                case 1:
                  Tools.basicDialog(
                      context: context,
                      statefulBuilder: StatefulBuilder(
                        builder: (contex,setState1){
                          return Dialog(
                            child: Container(
                              child: Text("Add TAG"),
                            ),
                          );
                        },
                      )
                  );
                  break;
              }

            },
            backgroundColor: Colors.indigo,
            child: Icon(Icons.add), //icon inside button
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
          //floating action button position to center
          bottomNavigationBar: BottomAppBar( //bottom navigation bar on scaffold
            color:Colors.blue,
            shape: const CircularNotchedRectangle(), //shape of notch
            notchMargin: 18, //notche margin between floating button and bottom appbar
            child: TabBar(
              splashBorderRadius: BorderRadius.zero,
              controller: _tabController,
              tabs: <Widget>[
                Tab(

                  child: Icon(Icons.bedroom_child, color: Colors.white,semanticLabel: "Room",),
                ),
                Tab(
                  child: Icon(Icons.settings_remote, color: Colors.white,semanticLabel: "Room",),
                )
                // IconButton(icon: Icon(Icons.manage_accounts, color: Colors.white,), onPressed: () {},),
                // IconButton(
                //   iconSize:20,
                //   icon: Icon(Icons.settings_remote, color: Colors.white,),
                //   onPressed: () {
                //
                //   },),
                // // Padding(padding: EdgeInsets.symmetric(horizontal: 30)),
                // IconButton(
                //   iconSize:20,
                //   icon: Icon(Icons.settings_remote, color: Colors.white,),
                //   onPressed: () {
                //
                //   },),
                // IconButton(icon: Icon(Icons.people, color: Colors.white,), onPressed: () {},),
              ],
            ),
          ),
        )
    );
  }

}