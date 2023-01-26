import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:findable/my_widgets/custom_text_button.dart';
import 'package:findable/my_widgets/custom_textfield.dart';
import 'package:findable/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/ESP.dart';
import '../models/log.dart';
import '../models/room.dart';
import '../models/tag.dart';
import '../models/users.dart';
import '../tools/variables.dart';
import 'package:http/http.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:ui' as ui;
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:lottie/lottie.dart';


class UserPage extends StatefulWidget {
  const UserPage({Key? key, required this.user}) : super(key: key);
  final User user;


  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> with SingleTickerProviderStateMixin{
  late TabController _tabController;
  List<Room> rooms = [];
  List<ESP> esps = [];
  Tag? currentSelectedTag;
  double currentSelectedTagDistance = 0;
  Function(Function())? updateCurrentDistance;
  bool isNotificationOn = true;
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  late Timer timer;
  List<Map<String,dynamic>> tagsDevice = [];
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  List<BluetoothDevice> devicesList = [];


  void initState() {
    super.initState();

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'findable',
      'findable-tag',
      importance: Importance.max,
      priority: Priority.high,

    );
    var initializationSettingsAndroid = const AndroidInitializationSettings('@mipmap/ic_launcher'); // <- default icon name is @mipmap/ic_launcher
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,

    );
    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        // onDidReceiveBackgroundNotificationResponse:(res){
        //   // print("asdasdasdasdasssssssssssssssssssssssssssssssssss");
        //   // print(res.payload);
        // },
        onDidReceiveNotificationResponse: (res){
          switch(res.id){
            case 1:
              String id = res.payload!;
              print(id);
              DBController.get(command: "get_tag_where_id", data: {"id":id.toLowerCase()}).then((value) {
                Tag tag = Tag.toObject(jsonDecode(value!));
                setState(() {
                  currentSelectedTag = tag;
                });
                DBController.get(command: "reset_tag_pos", data: {'tagID':tag.id.toLowerCase()}).then((value) {

                });
                DBController.get(command: "get_esp32/${tag.espID}", data: {}).then((value) {
                  ESP esp = ESP.toObject(jsonDecode(value!));
                  double k = 250/esp.sensorDistance;
                  double x=-1,y=-1;
                  int currentcount = 0;
                  late Function(Function()) setStateMap;
                  Function(Function())? setLoadingState;
                  getPos(){
                    DBController.get(command: "get_tag_pos", data: {'tagID':tag.id.toLowerCase()}).then((value){
                      Future.delayed(Duration(seconds:5), () {
                      }).then((n) {
                        var json = jsonDecode(value!);
                        if(setLoadingState!=null){
                          setLoadingState!((){
                            if(json['len']!=null){
                              currentcount = (json['len']+1);
                            }

                          });
                        }
                        setStateMap((){
                          var json = jsonDecode(value!);
                          x = json['x'];
                          y = json['y'];
                          getPos();
                          print(x);
                          print(y);
                        });
                      });
                    });
                  }
                  getPos();
                  Tools.basicDialog(
                      onPop: (){
                        setState(() {
                          currentSelectedTag = null;
                          updateCurrentDistance = null;
                        });
                        return Future<bool>.value(true);
                      },
                      context: context,
                      statefulBuilder: StatefulBuilder(
                          builder: (context,setState3){
                            setStateMap = setState3;
                            if(x==-1&&y==-1){
                              return Dialog(
                                alignment: Alignment.center,
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 150,
                                  width: double.infinity,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text("Locating ",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w100)),
                                            Text(tag.name,style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                                          ],
                                        ),

                                        Lottie.network('https://assets3.lottiefiles.com/packages/lf20_tIKIYX.json',width: 100,height: 80),
                                        StatefulBuilder(
                                            builder: (context,loadingState) {
                                              if(currentcount>=20){
                                                setLoadingState = null;
                                              }
                                              else{
                                                setLoadingState = loadingState;
                                              }

                                              return Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text("${((currentcount/20)*100).round()}",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold)),
                                                  Text("%",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w100)),
                                                ],
                                              );
                                            }
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                            return Dialog(
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              alignment: Alignment.center,
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Tag Name",style:TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 10) ,),
                                            Text("${tag.name}",style:GoogleFonts.nunitoSans(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 15) ,),
                                          ],
                                        ),
                                        StatefulBuilder(
                                            builder: (context,updateDistance) {
                                              updateCurrentDistance = updateDistance;
                                              return Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text("Distance",style:TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 10) ,),
                                                  Text("${currentSelectedTagDistance.toStringAsFixed(3)}m",style:GoogleFonts.nunitoSans(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 15) ,),
                                                ],
                                              );
                                            }
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: 330,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(Radius.circular(20))
                                      ),
                                      child: Column(

                                        children: [
                                          // Padding(
                                          //   padding: const EdgeInsets.all(10),
                                          //   child: Row(
                                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          //     children: [
                                          //       Icon(Icons.sensors),
                                          //       Icon(Icons.sensors),
                                          //     ],
                                          //   ),
                                          // ),
                                          Expanded(
                                            child: Stack(
                                              children: [
                                                // Builder(
                                                //     builder: (context) {
                                                //       double distance = sqrt(((150-12)*(150-12))+((150-12)*(150-31)));
                                                //       return Positioned(
                                                //         child: Column(
                                                //           children: [
                                                //             Text("Distance",style: TextStyle(fontSize: 10),),
                                                //             Text(distance.roundToDouble().toString(),style: TextStyle(fontSize: 10),),
                                                //           ],
                                                //         ),
                                                //         right: (150+12)/2,
                                                //         bottom: (150+31)/2,
                                                //       );
                                                //     }
                                                // ),
                                                // Positioned(
                                                //   child: Column(
                                                //     children: [
                                                //       Icon(Icons.person_pin_circle,color: Colors.indigo,),
                                                //       Text("You",style: TextStyle(fontSize: 10),),
                                                //       Text("(150,150)",style: TextStyle(fontSize: 10),),
                                                //     ],
                                                //   ),
                                                //   right: 150,
                                                //   bottom: 150,
                                                // ),
                                                Positioned(
                                                  child: Column(
                                                    children: [
                                                      Icon(Icons.sensors,color: Colors.blue,),
                                                      // Text("${e.name}",style: TextStyle(fontSize: 10),),
                                                      Text("(${esp.sensorDistance.toStringAsFixed(2)},0)",style: TextStyle(fontSize: 5),),
                                                    ],
                                                  ),
                                                  right: 2,
                                                  top: 5,
                                                ),
                                                Positioned(
                                                  child: Column(
                                                    children: [
                                                      Icon(Icons.sensors,color: Colors.blue,),
                                                      // Text("${esp}",style: TextStyle(fontSize: 10),),
                                                      Text("(0,0)",style: TextStyle(fontSize: 5),),
                                                    ],
                                                  ),
                                                  right: 248,
                                                  top: 5,
                                                ),
                                                Positioned(
                                                  child: Column(
                                                    children: [
                                                      Icon(Icons.place,color: Colors.blue,),
                                                      Text("${tag.name}",style: TextStyle(fontSize: 10),),
                                                      Text("(${(x).toStringAsFixed(2)},${(y).toStringAsFixed(2)})",style: TextStyle(fontSize: 5),),
                                                    ],
                                                  ),
                                                  left:  (x.abs()*k).abs(),
                                                  top: (y.abs()*k).abs(),
                                                ),
                                                // CustomPaint(
                                                //   painter: LinePainter(),
                                                // ),
                                              ],
                                            ),
                                          ),
                                          CustomTextButton(
                                            width: double.infinity,
                                            height: 50,
                                            color: Colors.indigo,
                                            text: "Found Tag",
                                            onPressed: (){
                                              DBController.get(command: 'get_room_where_esp', data: {'esp32ID':tag.espID,'userID':widget.user.id.toString()}).then((value) {
                                                var json = jsonDecode(value!);
                                                Log log = Log(date: "",roomID:json['id'] ,userID: widget.user.id.toString(),status: "Tag ${tag.name} is found!");
                                                DBController.get(command: "add_log", data: log.tojson()).then((value) {
                                                  setState((){
                                                    Navigator.of(context).pop();
                                                  });
                                                });
                                              });


                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Padding(padding: EdgeInsets.only(top: 5)),
                                    // Row(
                                    //   children: [
                                    //     Expanded(child: CustomTextField(hint:"Edit Name", controller: tagName,enable: isEdit,color: Colors.white,filled: true,filledColor: Colors.blue.withAlpha(200),)),
                                    //     CustomTextButton(
                                    //       height: 50,
                                    //       color: isEdit?Colors.indigo:Colors.blue,
                                    //       text: isEdit?"Save":"Edit",
                                    //       onPressed: (){
                                    //         setState3((){
                                    //           if(isEdit){
                                    //             isEdit = false;
                                    //             if(tagName.text.isNotEmpty){
                                    //               DBController.get(command:'update_tag_name' , data: {'id':tag.id,'name':tagName.text}).then((value) {
                                    //                 Navigator.of(context).pop();
                                    //               });
                                    //             }
                                    //
                                    //           }else isEdit = true;
                                    //         });
                                    //
                                    //       },
                                    //     ),
                                    //   ],
                                    // )
                                  ],
                                ),
                              ),
                            );
                          }
                      )

                  );
                });

              });

              break;
            case 2:
              String id = res.payload!;
              DBController.get(command: 'get_tag_where_id', data: {'id':id.toLowerCase()}).then((value) {
                Tag e = Tag.toObject(jsonDecode(value!));
                String date = jsonDecode(value!)['date_update'];
                DBController.get(command: 'get_esp32/'+e.espID, data: {}).then((esp_res) {
                  ESP esp = ESP.toObject(jsonDecode(esp_res!));
                  double k = 250/esp.sensorDistance;
                  double x=0,y=0;
                  DBController.get(command: "get_tag_pos", data: {'tagID':e.id.toLowerCase()}).then((value){

                    var json = jsonDecode(value!);
                    x = json['x'];
                    y = json['y'];
                    print(x);
                    print(y);
                    Tools.basicDialog(
                        onPop: (){
                          setState(() {
                            currentSelectedTag = null;
                          });
                          return Future<bool>.value(true);
                        },
                        context: context,
                        statefulBuilder: StatefulBuilder(
                            builder: (context,setState3){

                              return Dialog(
                                elevation: 0,
                                backgroundColor: Colors.transparent,
                                alignment: Alignment.center,
                                child: SingleChildScrollView(
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

                                            Expanded(
                                              child: Stack(
                                                children: [
                                                  Positioned(
                                                    child: Column(
                                                      children: [
                                                        Icon(Icons.sensors,color: Colors.blue,),
                                                        Text("${e.name}",style: TextStyle(fontSize: 10),),
                                                        Text("(${esp.sensorDistance.toStringAsFixed(2)},0)",style: TextStyle(fontSize: 5),),
                                                      ],
                                                    ),
                                                    right: 2,
                                                    top: 5,
                                                  ),
                                                  Positioned(
                                                    child: Column(
                                                      children: [
                                                        Icon(Icons.sensors,color: Colors.blue,),
                                                        // Text("${esp}",style: TextStyle(fontSize: 10),),
                                                        Text("(0,0)",style: TextStyle(fontSize: 5),),
                                                      ],
                                                    ),
                                                    right: 248,
                                                    top: 5,
                                                  ),
                                                  Positioned(
                                                    child: Column(
                                                      children: [
                                                        Icon(Icons.place,color: Colors.blue,),
                                                        Text("${e.name}",style: TextStyle(fontSize: 10),),
                                                        Text("(${(x).toStringAsFixed(2)},${(y).toStringAsFixed(2)})",style: TextStyle(fontSize: 5),),
                                                      ],
                                                    ),
                                                    left:  (x.abs()*k).abs(),
                                                    top: (y.abs()*k).abs(),
                                                  ),
                                                  // CustomPaint(
                                                  //   painter: LinePainter(),
                                                  // ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(padding: EdgeInsets.only(top: 5)),
                                      Center(child: Column(
                                        children: [
                                          Text("Last Location Time Date",style: TextStyle(color: Colors.white),),
                                          Text(date,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 15),),
                                        ],
                                      ))

                                    ],
                                  ),
                                ),
                              );
                            }
                        )

                    );

                  });

                });


              });


              break;
          }

        }
    );






    Permission.bluetooth.request().then((bt) {

      if(bt.isGranted){
        Permission.bluetoothConnect.request().then((btconnect) {
          if(btconnect.isGranted){
            Permission.bluetoothScan.request().then((btscan) {
              if(btscan.isGranted){
                flutterBlue.startScan();
              }
            });
          }

        });



      }

    });

    _tabController = new TabController(length: 1, vsync: this);
    timer = Timer.periodic(Duration(seconds: 3), (timer) {

      Future.delayed(Duration(seconds: 2), () {
        flutterBlue.startScan();



        flutterBlue.scanResults.first.then((element) {
          // print(tagsDevice.length);
          int tagCount = 0;
          // print("Asdasdadasdasdsadas");
          // print(element);
          for(var result in element){

            // print(result);

            if(result.device.type==BluetoothDeviceType.le){
              if(devicesList.where((element) => element.id.id.toLowerCase()==result.device.id.id.toLowerCase()).isEmpty){
                devicesList.add(result.device);
              }

              if(currentSelectedTag!=null){
                double distance =  pow(10,(((-77) - (result.rssi))/(10*2.5))).toDouble();
                currentSelectedTagDistance = distance;
                if(distance<=0.1&&result.device.id.id.toLowerCase() == currentSelectedTag!.id.toLowerCase()){
                  final Iterable<Duration> pauses = [
                    const Duration(milliseconds: 100),
                    const Duration(milliseconds: 500),
                    const Duration(milliseconds: 100),
                  ];
// vibrate - sleep 0.5s - vibrate - sleep 1s - vibrate - sleep 0.5s - vibrate
                  Vibrate.vibrateWithPauses(pauses);
                  if(updateCurrentDistance!=null){
                    updateCurrentDistance!((){

                    });
                  }
                }
              }

              if(tagsDevice.where((tDevice) => tDevice['id']==result.device.id.id ).isEmpty){
                // print('TAAAAAAAAAAAAAAAAAAAAAAAAAAAAAG');
                tagsDevice.add({
                  'id':result.device.id.id,
                  'count':0,
                  'name':result.device.name,
                  'isNotified':false
                });
                DBController.get(command: 'get_tag_where_id_userid', data: {'id':result.device.id.id.toLowerCase(),'userID':widget.user.id.toString()}).then((value) {
                  print(value!);
                  var json = jsonDecode(value!);

                  Tag tag = Tag.toObject(json);
                  DBController.get(command: 'get_room_where_esp', data: {'userID':widget.user.id.toString(),'esp32ID':tag.espID}).then((roomData) {
                    // print(roomData);
                    Room room = Room.toObject(jsonDecode(roomData!));
                    Log log = Log(roomID: room.id,userID: widget.user.id.toString(), date: '',status: "Tag named ${json['name']} is detected at room ${room.name}");
                    DBController.get(command: 'add_log', data: log.tojson());
                    if(isNotificationOn){
                      flutterLocalNotificationsPlugin.show(1, 'Findable',
                          'Tag named ${json['name']}  is detected!',
                          platformChannelSpecifics, payload: '${result.device.id.id}'
                      );
                    }

                  });


                });

              }

            }
          }

          for(var tdvice in tagsDevice){

            print(tdvice['count']);
            if(tdvice['count']>=20&&!tdvice['isNotified']){
              tdvice['isNotified'] = true;
              DBController.get(command: 'get_tag_where_id_userid', data: {'id':tdvice['id'].toString().toLowerCase(),'userID':widget.user.id.toString()}).then((value) {
                var json = jsonDecode(value!);
                Tag tag = Tag.toObject(json);
                DBController.get(command: 'get_room_where_esp', data: {'userID':widget.user.id.toString(),'esp32ID':tag.espID}).then((roomData) {
                  print(roomData);
                  Room room = Room.toObject(jsonDecode(roomData!));
                  Log log = Log(roomID: room.id,userID: widget.user.id.toString(), date: '',status: "Tag named ${json['name']} is too faraway. Last room ${room.name}");
                  DBController.get(command: 'add_log', data: log.tojson());
                  if(isNotificationOn){
                    flutterLocalNotificationsPlugin.show(2, 'Findable',
                        'This tag named ${json['name']} is not detected',
                        platformChannelSpecifics, payload: '${tdvice['id']}'
                    );
                  }

                  tagsDevice.remove(tdvice);
                });





              });

              print("This Tag is not found ${tdvice['name']}");
            }

            if(element.where((scannedD) =>scannedD.device.id.id==tdvice['id'] ).isEmpty){
              tagsDevice[tagsDevice.indexOf(tdvice)]['count']++;
              // print(tdvice['name']);
              break;
            }
            else{
              tagsDevice[tagsDevice.indexOf(tdvice)]['count'] = 0;
              tagsDevice[tagsDevice.indexOf(tdvice)]['isNotified'] = false;
              break;
            }


          }



          // print("${tagsDevice.length }---- ${tagCount}");


          // element.clear();

        });
      });
      flutterBlue.stopScan();



    });





  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SafeArea(
        child:Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: (){
                    TextEditingController name = TextEditingController(text: widget.user.name);
                    TextEditingController password = TextEditingController(text: widget.user.password);

                    bool showPassword = false,isEdit = false;
                    Tools.basicDialog(context: context,
                        onPop: () async => true,
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
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Column(
                                                  children: [
                                                    IconButton(

                                                        onPressed: (){
                                                          if(isNotificationOn){
                                                            setState1((){
                                                              setState(() {
                                                                isNotificationOn = false;
                                                              });
                                                            });

                                                          }
                                                          else{
                                                            setState1((){
                                                              setState(() {
                                                                isNotificationOn = true;
                                                              });
                                                            });


                                                          }
                                                        },
                                                        color: isNotificationOn?Colors.indigo:Colors.black38,
                                                        icon: Icon(isNotificationOn?Icons.notifications_active:Icons.notifications_off)
                                                    ),
                                                    Text("Alert Notification",style: TextStyle(fontSize: 10,color:Colors.black54),)
                                                  ],
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
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                      CustomTextButton(
                                          onPressed: (){
                                            widget.user.deviceID = '';
                                            widget.user.isLogin = false;
                                            DBController.get(command: 'update_user',data: widget.user.toJson()).then((updatedUser){
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
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.face,color: Colors.blue,),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
                          Text(widget.user.name,style: TextStyle(color: Colors.blue),)
                        ],
                      ),
                      Text("Account Manager",style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold,fontSize: 8),)
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    Tools.basicDialog(context: context,
                        onPop: () async => true,
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
                                          Text("Location Logs",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,color: Colors.white),),
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
                                              bottomLeft:Radius.circular(20),
                                            )
                                        ),
                                        child: FutureBuilder<String?>(
                                          future: DBController.get(command: 'get_logs', data: {'userID':widget.user.id.toString()}),
                                          builder: (context,snapshot){
                                            if(!snapshot.hasData)return Center();
                                            if(snapshot.connectionState==ConnectionState.waiting)return Center(child: CircularProgressIndicator(),);
                                            var jsons = jsonDecode(snapshot.data!);
                                            List<Log> logs = [];
                                            for (var json in jsons){
                                              Log log = Log.toObject(json: json);
                                              logs.add(log);
                                            }
                                            logs.sort((a,b)=>b.id.compareTo(a.id));
                                            return Container(
                                              padding: EdgeInsets.all(10),
                                              height: MediaQuery. of(context). size. height*.8,
                                              child: ListView(
                                                children: logs.map((log) {
                                                  // print(DateTime.parse(log.date));
                                                  return Container(

                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(log.status),
                                                          Text(log.date,style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),),
                                                          Divider()
                                                        ],
                                                      )
                                                  );
                                                }).toList(),
                                              ),
                                            );
                                          },
                                        ),
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
                  child: Column(
                    children: [
                      Icon(Icons.edit_location_alt,color: Colors.blue,),

                      Text("Location Logs",style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold,fontSize: 8),)
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: Container(
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
                        child: FutureBuilder<String?>(
                            future: DBController.get(command: 'get_room/', data: {'userID':widget.user.id.toString()}),
                            builder: (context, snapshot) {

                              if(!snapshot.hasData)return Center();
                              if(snapshot.connectionState==ConnectionState.waiting)return Center(child: CircularProgressIndicator(),);
                              print(snapshot.data!);
                              List<Room> rooms = [];
                              var jsons = jsonDecode(snapshot.data!);

                              for(var json in jsons){
                                rooms.add(Room.toObject(json));
                              }

                              return ListView(
                                children: rooms.map((room) {
                                  // ESP esp = esps.where((element) =>element.roomID == room.id).first;
                                  return  FutureBuilder<String?>(
                                      future: DBController.get(command: 'get_esp32/${room.esp32ID}', data: {}),
                                      builder: (context,snapshot) {
                                        if(!snapshot.hasData)return Center();
                                        if(snapshot.connectionState==ConnectionState.waiting)return Center(child: CircularProgressIndicator(),);
                                        var jsons = jsonDecode(snapshot.data!);
                                        ESP esp = ESP.toObject(jsons);
                                        late Function(void Function()) stateDistanceFunction;
                                        getESP(){
                                          DBController.get(command: "get_esp32/${esp.id}", data: {}).then((value) {

                                            esp = ESP.toObject(jsonDecode(value!));
                                            Future.delayed(Duration(seconds: 4), (){
                                              stateDistanceFunction((){
                                                getESP();
                                              });
                                            });
                                          });
                                        }

                                        getESP();
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            StatefulBuilder(
                                                builder: (context,setState1) {
                                                  stateDistanceFunction = setState1;
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
                                                        child: Column(
                                                          children: [
                                                            Column(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Text("Room Name",style: GoogleFonts.nunitoSans(fontWeight: FontWeight.normal,color: Colors.white,fontSize: 8),),
                                                                        Text(room.name.toUpperCase(),style: GoogleFonts.nunitoSans(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 20),),
                                                                      ],
                                                                    ),
                                                                    Column(
                                                                      children: [
                                                                        Text("ESP Current Mode",style: GoogleFonts.nunitoSans(fontWeight: FontWeight.normal,color: Colors.white,fontSize: 8),),
                                                                        Text(esp.mode==1?"Getting ESP Distance":"Finding Tags",style: GoogleFonts.nunitoSans(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 13),),
                                                                      ],
                                                                    ),
                                                                    // Text(esp.id,style: GoogleFonts.nunitoSans(fontWeight: FontWeight.w100,color: Colors.white),),

                                                                  ],
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Column(
                                                                      children: [
                                                                        Text("ESP ID",style: GoogleFonts.nunitoSans(fontWeight: FontWeight.normal,color: Colors.white,fontSize: 8),),
                                                                        Text(esp.id,style: GoogleFonts.nunitoSans(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 13),),
                                                                      ],
                                                                    ),
                                                                    Column(
                                                                      children: [
                                                                        Text("Distance Between ESPs",style: GoogleFonts.nunitoSans(fontWeight: FontWeight.normal,color: Colors.white,fontSize: 8),),
                                                                        Text(esp.sensorDistance.toStringAsPrecision(2)+"m",style: GoogleFonts.nunitoSans(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 13),),
                                                                      ],
                                                                    ),

                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      children:[
                                                        SizedBox(
                                                          height: 100,
                                                          child: FutureBuilder<String?>(
                                                              future:DBController.get(command: "get_tag_where_userid", data: {"userID":widget.user.id.toString()}),
                                                              builder: (context, snapshot) {
                                                                if(!snapshot.hasData)return Center();
                                                                if(snapshot.connectionState==ConnectionState.waiting)return Center(child: CircularProgressIndicator(),);
                                                                print(snapshot.data!);
                                                                var jsons = jsonDecode(snapshot.data!);
                                                                List<Tag> tags =[];
                                                                for(var json in jsons){
                                                                  Tag tag = Tag.toObject((json));

                                                                  if(tag.espID==esp.id&&tags.where((element) => element.id==tag.id).isEmpty){
                                                                    tags.add(tag);
                                                                  }

                                                                }


                                                                return ListView(
                                                                  children: tags.map((e){
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
                                                                                    setState(() {
                                                                                      currentSelectedTag = e;
                                                                                    });
                                                                                    DBController.get(command: "reset_tag_pos", data: {'tagID':e.id.toLowerCase()}).then((value) {

                                                                                    });
                                                                                    TextEditingController tagName = TextEditingController(text: e.name);
                                                                                    bool isEdit = false;
                                                                                    double k = 250/esp.sensorDistance;
                                                                                    double x=-1,y=-1;
                                                                                    int currentcount = 0;
                                                                                    late Function(Function()) setStateMap;
                                                                                    Function(Function())? setLoadingState;
                                                                                    getPos(){


                                                                                      DBController.get(command: "get_tag_pos", data: {'tagID':e.id.toLowerCase()}).then((value){

                                                                                        Future.delayed(Duration(seconds:3), () {
                                                                                        }).then((n) {
                                                                                          var json = jsonDecode(value!);
                                                                                          if(setLoadingState!=null){
                                                                                            setLoadingState!((){
                                                                                              if(json['len']!=null){
                                                                                                currentcount = (json['len']+1);
                                                                                              }

                                                                                            });
                                                                                          }

                                                                                          setStateMap((){
                                                                                            print(value);
                                                                                            print("asdasdasdaasasdasdasdas");

                                                                                            x = json['x'];
                                                                                            y = json['y'];

                                                                                            getPos();
                                                                                            // print(x);
                                                                                            // print(y);
                                                                                          });
                                                                                        });
                                                                                      });


                                                                                    }

                                                                                    getPos();
                                                                                    Tools.basicDialog(
                                                                                        onPop: (){
                                                                                          setState(() {
                                                                                            currentSelectedTag = null;
                                                                                            updateCurrentDistance = null;
                                                                                          });
                                                                                          return Future<bool>.value(true);
                                                                                        },
                                                                                        context: context,
                                                                                        statefulBuilder: StatefulBuilder(
                                                                                            builder: (context,setState3){
                                                                                              setStateMap = setState3;
                                                                                              if(x==-1&&y==-1){
                                                                                                return Dialog(
                                                                                                  alignment: Alignment.center,
                                                                                                  child: Container(
                                                                                                    alignment: Alignment.center,
                                                                                                    height: 150,
                                                                                                    width: double.infinity,
                                                                                                    child: Center(
                                                                                                      child: Column(
                                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                                        children: [
                                                                                                          Row(
                                                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                                                            children: [
                                                                                                              Text("Locating ",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w100)),
                                                                                                              Text(e.name,style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                                                                                                            ],
                                                                                                          ),

                                                                                                          Lottie.network('https://assets3.lottiefiles.com/packages/lf20_tIKIYX.json',width: 100,height: 80),
                                                                                                          StatefulBuilder(
                                                                                                              builder: (context,loadingState) {
                                                                                                                if(currentcount>=20){
                                                                                                                  setLoadingState = null;
                                                                                                                }
                                                                                                                else{
                                                                                                                  setLoadingState = loadingState;
                                                                                                                }

                                                                                                                return Row(
                                                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                                                  children: [
                                                                                                                    Text("${((currentcount/20)*100).round()}",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold)),
                                                                                                                    Text("%",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w100)),
                                                                                                                  ],
                                                                                                                );
                                                                                                              }
                                                                                                          ),
                                                                                                        ],
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                );
                                                                                              }
                                                                                              return Dialog(
                                                                                                elevation: 0,
                                                                                                backgroundColor: Colors.transparent,
                                                                                                alignment: Alignment.center,
                                                                                                child: SingleChildScrollView(
                                                                                                  child: Column(
                                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                    children: [
                                                                                                      Row(
                                                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                        children: [
                                                                                                          Column(
                                                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                            children: [
                                                                                                              Text("Your",style:TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 10) ,),
                                                                                                              Text("${e.name}",style:GoogleFonts.nunitoSans(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 25) ,),
                                                                                                            ],
                                                                                                          ),
                                                                                                          StatefulBuilder(
                                                                                                              builder: (context,updateDistance) {
                                                                                                                updateCurrentDistance = updateDistance;
                                                                                                                return Column(
                                                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                                  children: [
                                                                                                                    Text("Distance From You",style:TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 10) ,),
                                                                                                                    Text("${currentSelectedTagDistance.toStringAsFixed(3)}m",style:GoogleFonts.nunitoSans(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 25) ,),
                                                                                                                  ],
                                                                                                                );
                                                                                                              }
                                                                                                          ),
                                                                                                        ],
                                                                                                      ),


                                                                                                      Container(
                                                                                                        height: 330,
                                                                                                        width: double.infinity,
                                                                                                        decoration: BoxDecoration(
                                                                                                            color: Colors.white,
                                                                                                            borderRadius: BorderRadius.all(Radius.circular(20))
                                                                                                        ),
                                                                                                        child: Column(

                                                                                                          children: [
                                                                                                            Expanded(
                                                                                                              child: Stack(
                                                                                                                children: [
                                                                                                                  Positioned(
                                                                                                                    child: Column(
                                                                                                                      children: [
                                                                                                                        Icon(Icons.sensors,color: Colors.blue,),
                                                                                                                        // Text("${e.name}",style: TextStyle(fontSize: 10),),
                                                                                                                        Text("(${esp.sensorDistance.toStringAsFixed(2)},0)",style: TextStyle(fontSize: 5),),
                                                                                                                      ],
                                                                                                                    ),
                                                                                                                    right: 2,
                                                                                                                    top: 5,
                                                                                                                  ),
                                                                                                                  Positioned(
                                                                                                                    child: Column(
                                                                                                                      children: [
                                                                                                                        Icon(Icons.sensors,color: Colors.blue,),
                                                                                                                        // Text("${esp}",style: TextStyle(fontSize: 10),),
                                                                                                                        Text("(0,0)",style: TextStyle(fontSize: 5),),
                                                                                                                      ],
                                                                                                                    ),
                                                                                                                    right: 248,
                                                                                                                    top: 5,
                                                                                                                  ),
                                                                                                                  Positioned(
                                                                                                                    child: Column(
                                                                                                                      children: [
                                                                                                                        Stack(
                                                                                                                          alignment: Alignment.center,
                                                                                                                          children: [
                                                                                                                            Container(
                                                                                                                              width: 50,
                                                                                                                              height: 50,
                                                                                                                              decoration: new BoxDecoration(
                                                                                                                                color: Colors.blue.withAlpha(100),
                                                                                                                                shape: BoxShape.circle,
                                                                                                                              ),
                                                                                                                            ),
                                                                                                                            Icon(Icons.place,color: Colors.blue,size: 15,),
                                                                                                                          ],
                                                                                                                        ),
                                                                                                                        Text("${e.name}",style: TextStyle(fontSize: 10),),
                                                                                                                        Text("(${(x).toStringAsFixed(2)},${(y).toStringAsFixed(2)})",style: TextStyle(fontSize: 5),),
                                                                                                                      ],
                                                                                                                    ),
                                                                                                                    left:  (x.abs()*k).abs(),
                                                                                                                    top: (y.abs()*k).abs(),
                                                                                                                  ),
                                                                                                                  // CustomPaint(
                                                                                                                  //   painter: LinePainter(),
                                                                                                                  // ),
                                                                                                                ],
                                                                                                              ),
                                                                                                            ),
                                                                                                          ],
                                                                                                        ),
                                                                                                      ),
                                                                                                      Padding(padding: EdgeInsets.only(top: 5)),
                                                                                                      Row(
                                                                                                        children: [
                                                                                                          Expanded(child: CustomTextField(hint:"Edit Name", controller: tagName,enable: isEdit,color: Colors.white,filled: true,filledColor: Colors.blue.withAlpha(200),)),
                                                                                                          CustomTextButton(
                                                                                                            height: 50,
                                                                                                            color: isEdit?Colors.indigo:Colors.blue,
                                                                                                            text: isEdit?"Save":"Edit",
                                                                                                            onPressed: (){
                                                                                                              setState3((){
                                                                                                                if(isEdit){
                                                                                                                  isEdit = false;
                                                                                                                  if(tagName.text.isNotEmpty){
                                                                                                                    DBController.get(command:'update_tag_name' , data: {'id':e.id,'name':tagName.text}).then((value) {
                                                                                                                      Navigator.of(context).pop();
                                                                                                                    });
                                                                                                                  }

                                                                                                                }else isEdit = true;
                                                                                                              });

                                                                                                            },
                                                                                                          ),
                                                                                                        ],
                                                                                                      ),
                                                                                                      CustomTextButton(
                                                                                                        width: double.infinity,
                                                                                                        height: 50,
                                                                                                        color: Colors.indigo,
                                                                                                        text: "Found Tag",
                                                                                                        onPressed: (){
                                                                                                          Log log = Log(date: "",roomID: room.id,userID: widget.user.id.toString(),status: "Tag ${e.name} is found!");
                                                                                                          DBController.get(command: "add_log", data: log.tojson()).then((value) {
                                                                                                            setState((){
                                                                                                              Navigator.of(context).pop();
                                                                                                            });
                                                                                                          });

                                                                                                        },
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                ),
                                                                                              );
                                                                                            }
                                                                                        )

                                                                                    );
                                                                                  },
                                                                                  child: Text(e.name,style: GoogleFonts.nunitoSans(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 10),),
                                                                                ),
                                                                              ),
                                                                              Container(
                                                                                // color:Colors.red,
                                                                                child: GestureDetector(
                                                                                  onLongPress: (){
                                                                                    DBController.get(command: "update_tag_userid", data: {"id":e.id,"userID":(-1).toString()}).then((value) {
                                                                                      print(value);
                                                                                      if(value=="1"){
                                                                                        Tools.basicDialog(context: context,
                                                                                            onPop: () async => false,
                                                                                            statefulBuilder: StatefulBuilder(
                                                                                                builder: (context,state){
                                                                                                  return AlertDialog(
                                                                                                    title: Text("Deleted"),
                                                                                                    content: Text("This tag ${e.name} is deleted!"),
                                                                                                    actions: [
                                                                                                      CustomTextButton(
                                                                                                        color:Colors.red,
                                                                                                        onPressed: (){Navigator.of(context).pop();},
                                                                                                        text: "Confirm",
                                                                                                      )
                                                                                                    ],
                                                                                                  );
                                                                                                }
                                                                                            )
                                                                                        );
                                                                                      }
                                                                                    });
                                                                                  },
                                                                                  child: Icon(
                                                                                    size:15,
                                                                                    Icons.close,
                                                                                    color: Colors.white70,
                                                                                  ),
                                                                                ),
                                                                              )
                                                                            ],
                                                                          )
                                                                      ),
                                                                    );
                                                                  }).toList(),
                                                                );
                                                              }
                                                          ),
                                                        ),
                                                        IconButton(
                                                          icon:Icon(Icons.add,color: Colors.white,),
                                                          onPressed: () {
                                                            TextEditingController tagName = TextEditingController();
                                                            Tools.basicDialog(
                                                                onPop: () async => true,
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
                                                                            child: Text('Available Tags',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 18),),
                                                                          ),
                                                                          Container(
                                                                            padding: EdgeInsets.all(20),
                                                                            width: double.infinity,
                                                                            height: 300,
                                                                            decoration: BoxDecoration(
                                                                                color: Colors.white,
                                                                                borderRadius: BorderRadius.all(Radius.circular(20))
                                                                            ),
                                                                            child: Column(
                                                                              children: [

                                                                                Expanded(
                                                                                    child: FutureBuilder<String?>(
                                                                                      future: DBController.get(command: "get_tag_where_userid", data: {"userID":(-1).toString()}),
                                                                                      builder: (context, snapshot) {
                                                                                        if(!snapshot.hasData)return Center();
                                                                                        if(snapshot.connectionState==ConnectionState.waiting)return Center(child: CircularProgressIndicator(),);
                                                                                        List<Tag> tags = [];
                                                                                        var jsons = jsonDecode(snapshot.data!);
                                                                                        for(var x in jsons){
                                                                                          Tag tag = Tag.toObject(x);
                                                                                          if(devicesList.where((element) => element.id.id.toLowerCase()==tag.id.toLowerCase()).isNotEmpty ){
                                                                                            tags.add(tag);
                                                                                          }

                                                                                        }

                                                                                        return ListView(
                                                                                          children: tags.map((tag) {
                                                                                            return Container(
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
                                                                                                            DBController.get(command: "update_tag_userid", data: {"id":tag.id,"userID":widget.user.id.toString()}).then((value) {
                                                                                                              if(value=="1"){
                                                                                                                Navigator.of(context).pop();
                                                                                                              }
                                                                                                            });
                                                                                                          },
                                                                                                          child: Column(

                                                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                            children: [
                                                                                                              Text("Tag ${tags.indexOf(tag)}",style: GoogleFonts.nunitoSans(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 10),),
                                                                                                              Text(tag.id,style: GoogleFonts.nunitoSans(fontWeight: FontWeight.w100,color: Colors.white,fontSize: 10),),
                                                                                                            ],
                                                                                                          )
                                                                                                      ),
                                                                                                    ),


                                                                                                  ],
                                                                                                )
                                                                                            );
                                                                                          }).toList(),
                                                                                        );
                                                                                      },
                                                                                    )
                                                                                ),
                                                                                CustomTextButton(
                                                                                  text:"Refresh",
                                                                                  color:Colors.blue ,
                                                                                  onPressed: (){
                                                                                    // devicesList.clear();
                                                                                    setState2((){});
                                                                                  },
                                                                                )


                                                                              ],
                                                                            ),
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
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 15),
                                                  child: CustomTextButton(
                                                    rAll: 10,
                                                    text: "Edit",
                                                    color: Colors.blue,
                                                    style:TextStyle(fontSize: 8,color: Colors.white),
                                                    onPressed: (){
                                                      TextEditingController roomName = TextEditingController(text: room.name);
                                                      Tools.basicDialog(
                                                          onPop: () async => true,
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
                                                                      height: 180,
                                                                      decoration: BoxDecoration(
                                                                          color: Colors.white,
                                                                          borderRadius: BorderRadius.only(topLeft:Radius.circular(20),topRight: Radius.circular(20),bottomRight: Radius.circular(0))
                                                                      ),
                                                                      child: Column(
                                                                        children: [
                                                                          CustomTextField(
                                                                            hint: "Name",
                                                                            controller: roomName,
                                                                            color: Colors.blue,
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Row(
                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                      children: [
                                                                        CustomTextButton(
                                                                          rTopRight: 20,
                                                                          rBottomRight: 20,
                                                                          rTopLeft: 0,
                                                                          rBottomLeft: 20,
                                                                          color: Colors.blue,
                                                                          text: "Save",
                                                                          onPressed: (){
                                                                            if(roomName.text.isNotEmpty){
                                                                              DBController.get(command: "update_room", data: {'name':roomName.text,'id':room.id,'userID':widget.user.id.toString(),'newuserID':widget.user.id.toString(),'esp32ID':room.esp32ID}).then((value){
                                                                                Navigator.of(context).pop();
                                                                                setState((){});
                                                                              });
                                                                              // DBController.get(command: "get_esp32/${ESP32ID.text}", data: {}).then((esp32) {
                                                                              //
                                                                              //   if(esp32![0]=='{'){
                                                                              //     ESP esp = ESP.toObject(jsonDecode(esp32));
                                                                              //     // Room room = Room(name: roomName.text, userID: widget.user.id.toString(),esp32ID: esp.id);
                                                                              //     // DBController.get(command: 'insert_room/', data: room.toJson(isNew: true)).then((room){
                                                                              //     //   print(room);
                                                                              //     //   // ESP esp = ESP.toObject(jsonDecode(esp32));
                                                                              //     //   // DBController.post(command: "update_esp32_room", data: {'id':esp.id,'roomID':room}).then((value) {
                                                                              //     //   //   setState(() {
                                                                              //     //   //
                                                                              //     //   //     // Room room = Room(id: (rooms.length+1).toString(), name: roomName.text, userID: widget.user.id.toString());
                                                                              //     //   //     // rooms.add(room);
                                                                              //     //   //     // esp.roomID = room.id;
                                                                              //     //   //     // if(esps.where((element) => element.id==esp.id).isEmpty)esps.add(esp);
                                                                              //     //   //   });
                                                                              //     //   //   Navigator.of(context).pop();
                                                                              //     //   // });
                                                                              //     //   setState((){
                                                                              //     //
                                                                              //     //   });
                                                                              //     //   Navigator.of(context).pop();
                                                                              //     //
                                                                              //     // });
                                                                              //
                                                                              //
                                                                              //   }
                                                                              //
                                                                              // });

                                                                            }

                                                                          },
                                                                        ),
                                                                        CustomTextButton(
                                                                          rTopRight: 0,
                                                                          rBottomRight: 20,
                                                                          rTopLeft: 20,
                                                                          rBottomLeft: 20,
                                                                          color: Colors.red,
                                                                          text: "Delete",
                                                                          onPressed: (){
                                                                            if(roomName.text.isNotEmpty){
                                                                              DBController.get(command: "update_room", data: {'name':roomName.text,'userID':widget.user.id.toString(),'id':room.id,'esp32ID':room.esp32ID,'newuserID':"-1"}).then((value){
                                                                                Navigator.of(context).pop();
                                                                                setState((){});
                                                                              });
                                                                              // DBController.get(command: "get_esp32/${ESP32ID.text}", data: {}).then((esp32) {
                                                                              //
                                                                              //   if(esp32![0]=='{'){
                                                                              //     ESP esp = ESP.toObject(jsonDecode(esp32));
                                                                              //     // Room room = Room(name: roomName.text, userID: widget.user.id.toString(),esp32ID: esp.id);
                                                                              //     // DBController.get(command: 'insert_room/', data: room.toJson(isNew: true)).then((room){
                                                                              //     //   print(room);
                                                                              //     //   // ESP esp = ESP.toObject(jsonDecode(esp32));
                                                                              //     //   // DBController.post(command: "update_esp32_room", data: {'id':esp.id,'roomID':room}).then((value) {
                                                                              //     //   //   setState(() {
                                                                              //     //   //
                                                                              //     //   //     // Room room = Room(id: (rooms.length+1).toString(), name: roomName.text, userID: widget.user.id.toString());
                                                                              //     //   //     // rooms.add(room);
                                                                              //     //   //     // esp.roomID = room.id;
                                                                              //     //   //     // if(esps.where((element) => element.id==esp.id).isEmpty)esps.add(esp);
                                                                              //     //   //   });
                                                                              //     //   //   Navigator.of(context).pop();
                                                                              //     //   // });
                                                                              //     //   setState((){
                                                                              //     //
                                                                              //     //   });
                                                                              //     //   Navigator.of(context).pop();
                                                                              //     //
                                                                              //     // });
                                                                              //
                                                                              //
                                                                              //   }
                                                                              //
                                                                              // });

                                                                            }

                                                                          },
                                                                        ),
                                                                      ],
                                                                    ),

                                                                  ],
                                                                ),
                                                              );
                                                            },
                                                          )
                                                      );
                                                    },
                                                  ),
                                                ),
                                                CustomTextButton(
                                                  width:110,
                                                  onPressed: (){
                                                    DBController.get(command: "reset_esp_distance", data: {}).then((n) {
                                                      print(n);
                                                      DBController.get(command: "update_esp32_mode/${esp.id}/", data: {}).then((value) {

                                                        stateDistanceFunction(() {
                                                          esp.mode = esp.mode==1?0:1;
                                                          // setState(() {
                                                          //
                                                          // });
                                                        });

                                                      });

                                                    });


                                                  },
                                                  color: Colors.blue,
                                                  style: TextStyle(fontSize: 8,color: Colors.white),
                                                  text: "Setup Sensors",
                                                ),
                                              ],
                                            )
                                          ],
                                        );
                                      }
                                  );
                                }).toList(),
                              );
                            }
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton:FloatingActionButton(
            //Floating action button on Scaffold
            onPressed: (){
              TextEditingController roomName = TextEditingController();
              TextEditingController ESP32ID = TextEditingController();
              switch(_tabController.index){
                case 0:
                  Tools.basicDialog(
                      onPop: () async => true,
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
                                  height: 180,
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
                                      ),
                                      CustomTextField(
                                        hint: "ESP32 ID",
                                        controller: ESP32ID,
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
                                    if(ESP32ID.text.isNotEmpty&&roomName.text.isNotEmpty){
                                      DBController.get(command: "get_esp32/${ESP32ID.text}", data: {}).then((esp32) {

                                        if(esp32![0]=='{'){
                                          ESP esp = ESP.toObject(jsonDecode(esp32));
                                          Room room = Room(name: roomName.text, userID: widget.user.id.toString(),esp32ID: esp.id);
                                          DBController.get(command: 'insert_room/', data: room.toJson(isNew: true)).then((room){
                                            print(room);
                                            // ESP esp = ESP.toObject(jsonDecode(esp32));
                                            // DBController.post(command: "update_esp32_room", data: {'id':esp.id,'roomID':room}).then((value) {
                                            //   setState(() {
                                            //
                                            //     // Room room = Room(id: (rooms.length+1).toString(), name: roomName.text, userID: widget.user.id.toString());
                                            //     // rooms.add(room);
                                            //     // esp.roomID = room.id;
                                            //     // if(esps.where((element) => element.id==esp.id).isEmpty)esps.add(esp);
                                            //   });
                                            //   Navigator.of(context).pop();
                                            // });
                                            setState((){

                                            });
                                            Navigator.of(context).pop();

                                          });


                                        }

                                      });

                                    }

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
                      onPop: () async => true,
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