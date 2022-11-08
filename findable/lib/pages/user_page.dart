import 'dart:math';

import 'package:findable/my_widgets/custom_text_button.dart';
import 'package:findable/my_widgets/custom_textfield.dart';
import 'package:findable/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/room.dart';
import '../models/tag.dart';
import '../models/users.dart';
import '../tools/variables.dart';
import 'dart:ui' as ui;

class UserPage extends StatefulWidget {
  const UserPage({Key? key, required this.user}) : super(key: key);
  final User user;


  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> with SingleTickerProviderStateMixin{
  late TabController _tabController;
  List<Room> rooms = [];
  List<Tag> tags =[];
  void initState() {
    super.initState();
    _tabController = new TabController(length: 1, vsync: this);

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
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        alignment: Alignment.center,
                        child: Text("ROOMS",style: GoogleFonts.nunitoSans(fontWeight: FontWeight.bold),)
                    ),
                    Expanded(
                      child: Container(
                        // padding: EdgeInsets,
                        margin: EdgeInsets.only(top: 10),
                        decoration: BoxDecoration(
                            color: Colors.indigo,
                            borderRadius: BorderRadius.all(Radius.circular(20))
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: ListView(
                              children: rooms.map((room) {

                                return  StatefulBuilder(
                                    builder: (context,setState1) {
                                      return ClipRRect(
                                        borderRadius: BorderRadius.all(Radius.circular(20)),
                                        child: ExpansionTile(
                                          collapsedIconColor: Colors.white,
                                          backgroundColor: Colors.indigoAccent,
                                          iconColor: Colors.indigo,
                                          title: Container(
                                            margin: EdgeInsets.only(bottom: 10),
                                            decoration: BoxDecoration(
                                                color: Colors.indigoAccent,
                                                borderRadius: BorderRadius.all(Radius.circular(20))
                                            ),
                                            padding: const EdgeInsets.all(10),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(room.id,style: GoogleFonts.nunitoSans(fontWeight: FontWeight.w100,color: Colors.white),),
                                                Text(room.name.toUpperCase(),style: GoogleFonts.nunitoSans(fontWeight: FontWeight.bold,color: Colors.white),),
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(tags.where((element) => room.id==element.roomID).length.toString(),style: GoogleFonts.nunitoSans(fontWeight: FontWeight.bold,color: Colors.white),),
                                                    Text(tags.where((element) => room.id==element.roomID).length>1?' tags':' tag',style: GoogleFonts.nunitoSans(fontWeight: FontWeight.w100,color: Colors.white,fontSize: 10),),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          children:[
                                            SizedBox(
                                              height: 100,
                                              child: ListView(
                                                children: tags.where((element) => room.id==element.roomID) .map((e){
                                                  return Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 27),
                                                    child: Container(
                                                        padding: EdgeInsets.all(10),
                                                        margin: EdgeInsets.only(bottom: 10),
                                                        decoration: BoxDecoration(
                                                            color: Colors.indigo,
                                                            borderRadius: BorderRadius.all(Radius.circular(20))
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Expanded(
                                                                child: GestureDetector(
                                                                    onTap: (){
                                                                      Tools.basicDialog(
                                                                          context: context,
                                                                          statefulBuilder: StatefulBuilder(
                                                                              builder: (context,setState3){
                                                                                return Dialog(
                                                                                  elevation: 0,
                                                                                  backgroundColor: Colors.transparent,
                                                                                  alignment: Alignment.center,
                                                                                  child: Column(
                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children: [
                                                                                      Text("${e.name} Location",style:GoogleFonts.nunitoSans(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 25) ,),
                                                                                      Container(
                                                                                        height: 330,
                                                                                        width: double.infinity,
                                                                                        decoration: BoxDecoration(
                                                                                            color: Colors.white,
                                                                                            borderRadius: BorderRadius.all(Radius.circular(20))
                                                                                        ),
                                                                                        child: Column(

                                                                                          children: [
                                                                                            Padding(
                                                                                              padding: const EdgeInsets.all(10),
                                                                                              child: Row(
                                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                children: [
                                                                                                  Icon(Icons.sensors),
                                                                                                  Icon(Icons.sensors),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                            Expanded(
                                                                                              child: Stack(
                                                                                                children: [
                                                                                                  Builder(
                                                                                                      builder: (context) {
                                                                                                        double distance = sqrt(((150-12)*(150-12))+((150-12)*(150-31)));
                                                                                                        return Positioned(
                                                                                                          child: Column(
                                                                                                            children: [
                                                                                                              Text("Distance",style: TextStyle(fontSize: 10),),
                                                                                                              Text(distance.roundToDouble().toString(),style: TextStyle(fontSize: 10),),
                                                                                                            ],
                                                                                                          ),
                                                                                                          right: (150+12)/2,
                                                                                                          bottom: (150+31)/2,
                                                                                                        );
                                                                                                      }
                                                                                                  ),
                                                                                                  Positioned(
                                                                                                    child: Column(
                                                                                                      children: [
                                                                                                        Icon(Icons.person_pin_circle,color: Colors.indigo,),
                                                                                                        Text("You",style: TextStyle(fontSize: 10),),
                                                                                                        Text("(150,150)",style: TextStyle(fontSize: 10),),
                                                                                                      ],
                                                                                                    ),
                                                                                                    right: 150,
                                                                                                    bottom: 150,
                                                                                                  ),
                                                                                                  Positioned(
                                                                                                    child: Column(
                                                                                                      children: [
                                                                                                        Icon(Icons.place,color: Colors.blue,),
                                                                                                        Text("${e.name}",style: TextStyle(fontSize: 10),),
                                                                                                        Text("(12,31)",style: TextStyle(fontSize: 10),),
                                                                                                      ],
                                                                                                    ),
                                                                                                    right: 12,
                                                                                                    bottom: 31,
                                                                                                  ),
                                                                                                  // CustomPaint(
                                                                                                  //   painter: LinePainter(),
                                                                                                  // ),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                );
                                                                              }
                                                                          )

                                                                      );
                                                                    },
                                                                    child: Text(e.name,style: GoogleFonts.nunitoSans(fontWeight: FontWeight.normal,color: Colors.white,fontSize: 10),)
                                                                ),
                                                            ),
                                                            GestureDetector(
                                                                onTap: (){
                                                                  TextEditingController tagName = TextEditingController(text: e.name);
                                                                  Tools.basicDialog(
                                                                      context: context,
                                                                      statefulBuilder: StatefulBuilder(
                                                                        builder: (contex,setState2){
                                                                          return Dialog(
                                                                            elevation: 0,
                                                                            alignment: Alignment.center,
                                                                            backgroundColor: Colors.transparent,
                                                                            child: Column(
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(left: 20.0),
                                                                                  child: Text('Tag',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 18),),
                                                                                ),
                                                                                Container(
                                                                                  padding: EdgeInsets.all(20),
                                                                                  width: double.infinity,
                                                                                  height: 100,
                                                                                  decoration: BoxDecoration(
                                                                                      color: Colors.white,
                                                                                      borderRadius: BorderRadius.only(topLeft:Radius.circular(20),topRight: Radius.circular(20),bottomRight: Radius.circular(20))
                                                                                  ),
                                                                                  child: Column(
                                                                                    children: [
                                                                                      CustomTextField(
                                                                                        hint: "Name",
                                                                                        controller: tagName,
                                                                                        color: Colors.blue,
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                                CustomTextButton(
                                                                                  rTopRight: 20,
                                                                                  rBottomRight: 20,
                                                                                  rTopLeft: 0,
                                                                                  rBottomLeft: 20,
                                                                                  color: Colors.blue,
                                                                                  text: "Save",
                                                                                  onPressed: (){
                                                                                    setState(() {
                                                                                      Tag tag = Tag(id: e.id, name: tagName.text, roomID: room.id.toString(),x: 0,y: 0);
                                                                                      tags[int.parse(tag.id)-1] = tag;
                                                                                    });
                                                                                    Navigator.of(context).pop();
                                                                                  },
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          );
                                                                        },
                                                                      )
                                                                  );
                                                                  print("asdasda");
                                                                },
                                                                child: SizedBox(
                                                                    width: 20,
                                                                    height: 20,
                                                                    child: Icon(Icons.edit,color: Colors.white,size: 12,)
                                                                )
                                                            ),

                                                          ],
                                                        )
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                            IconButton(
                                              icon:Icon(Icons.add,color: Colors.white,),
                                              onPressed: () {
                                                TextEditingController tagName = TextEditingController();
                                                Tools.basicDialog(
                                                    context: context,
                                                    statefulBuilder: StatefulBuilder(
                                                      builder: (contex,setState2){
                                                        return Dialog(
                                                          elevation: 0,
                                                          alignment: Alignment.center,
                                                          backgroundColor: Colors.transparent,
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Padding(
                                                                padding: const EdgeInsets.only(left: 20.0),
                                                                child: Text('Tag',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 18),),
                                                              ),
                                                              Container(
                                                                padding: EdgeInsets.all(20),
                                                                width: double.infinity,
                                                                height: 100,
                                                                decoration: BoxDecoration(
                                                                    color: Colors.white,
                                                                    borderRadius: BorderRadius.only(topLeft:Radius.circular(20),topRight: Radius.circular(20),bottomRight: Radius.circular(20))
                                                                ),
                                                                child: Column(
                                                                  children: [
                                                                    CustomTextField(
                                                                      hint: "Name",
                                                                      controller: tagName,
                                                                      color: Colors.blue,
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                              CustomTextButton(
                                                                rTopRight: 20,
                                                                rBottomRight: 20,
                                                                rTopLeft: 0,
                                                                rBottomLeft: 20,
                                                                color: Colors.blue,
                                                                text: "Add",
                                                                onPressed: (){
                                                                  setState(() {
                                                                    Tag tag = Tag(id: (tags.length+1).toString(), name: tagName.text, roomID: room.id.toString(),x: 0,y: 0);
                                                                    tags.add(tag);
                                                                  });
                                                                  Navigator.of(context).pop();
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    )
                                                );
                                              },


                                            )
                                          ],
                                        ),
                                      );
                                    }
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Container(
              //   child: Text('Tags'),
              // )
            ],
          ),
          floatingActionButton:FloatingActionButton(
            //Floating action button on Scaffold
            onPressed: (){
              TextEditingController roomName = TextEditingController();
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
                                Padding(
                                  padding: const EdgeInsets.only(left: 20.0),
                                  child: Text('Room',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 18),),
                                ),
                                Container(
                                  padding: EdgeInsets.all(20),
                                  width: double.infinity,
                                  height: 100,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(topLeft:Radius.circular(20),topRight: Radius.circular(20),bottomRight: Radius.circular(20))
                                  ),
                                  child: Column(
                                    children: [
                                      CustomTextField(
                                        hint: "Name",
                                        controller: roomName,
                                        color: Colors.blue,
                                      )
                                    ],
                                  ),
                                ),
                                CustomTextButton(
                                  rTopRight: 20,
                                  rBottomRight: 20,
                                  rTopLeft: 0,
                                  rBottomLeft: 20,
                                  color: Colors.blue,
                                  text: "Add",
                                  onPressed: (){
                                    setState(() {
                                      Room room = Room(id: (rooms.length+1).toString(), name: roomName.text, userID: widget.user.id.toString());
                                      rooms.add(room);

                                    });
                                    Navigator.of(context).pop();
                                  },
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
            backgroundColor: Colors.indigoAccent,
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
                // Tab(
                //   child: Icon(Icons.settings_remote, color: Colors.white,semanticLabel: "Room",),
                // )
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

class LinePainter extends CustomPainter { //         <-- CustomPainter class
  @override
  void paint(Canvas canvas, Size size) {
    final pointMode = ui.PointMode.polygon;
    final points = [
      Offset(50, 100),
      Offset(150, 75),
      Offset(250, 250),
      Offset(130, 200),
      Offset(270, 100),
    ];
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawPoints(pointMode, points, paint);
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return false;
  }
}