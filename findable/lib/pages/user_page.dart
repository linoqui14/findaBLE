import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:findable/my_widgets/custom_text_button.dart';
import 'package:findable/my_widgets/custom_textfield.dart';
import 'package:findable/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/ESP.dart';
import '../models/room.dart';
import '../models/tag.dart';
import '../models/users.dart';
import '../tools/variables.dart';
import 'package:http/http.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
  List<ESP> esps = [];

  final FlutterBlue flutterBlue = FlutterBlue.instance;
  late Timer timer;
  List<Map<String,dynamic>> tagsDevice = [];
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();



  void initState() {
    super.initState();

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'findable',
      'findable',
      importance: Importance.max,
      priority: Priority.high,

    );
    var initializationSettingsAndroid = const AndroidInitializationSettings('mipmap/ic_launcher'); // <- default icon name is @mipmap/ic_launcher
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,

    );
    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveBackgroundNotificationResponse:(res){
          // print("asdasdasdasdasssssssssssssssssssssssssssssssssss");
          // print(res.payload);
        },
        onDidReceiveNotificationResponse: (res){
          switch(res.id){
            case 1:
              print("New Tag");
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
                  DBController.get(command: "get_tag_pos", data: {}).then((value){
                      var json = jsonDecode(value!);
                      x = json['x'];
                      y = json['y'];
                      print(x);
                      print(y);
                      Tools.basicDialog(
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





    final List<BluetoothDevice> devicesList = [];
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
          for(var result in element){

            if(result.device.name.contains("iTAG")){

              if(tagsDevice.where((tDevice) => tDevice['id']==result.device.id.id ).isEmpty){

                tagsDevice.add({
                  'id':result.device.id.id,
                  'count':0,
                  'name':result.device.name,
                  'isNotified':false
                });
                DBController.get(command: 'get_tag_where_id', data: {'id':result.device.id.id.toLowerCase()}).then((value) {
                  var json = jsonDecode(value!);
                  flutterLocalNotificationsPlugin.show(1, 'Findable',
                      'Tag named ${json['name']}  is detected!',
                      platformChannelSpecifics, payload: 'Default_Sound,${result.device.id.id}'
                  );
                });

              }

            }
          }

          for(var tdvice in tagsDevice){

            print(tdvice['count']);
            if(tdvice['count']>=15&&!tdvice['isNotified']){
              tdvice['isNotified'] = true;
              DBController.get(command: 'get_tag_where_id', data: {'id':tdvice['id'].toString().toLowerCase()}).then((value) {
                var json = jsonDecode(value!);
                flutterLocalNotificationsPlugin.show(2, 'Findable',
                    'This tag named ${json['name']} is too far away or not visible!',
                    platformChannelSpecifics, payload: '${tdvice['id']}'
                );
                tagsDevice.remove(tdvice);

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


          element.clear();

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
              child: Row(
                children: [
                  Icon(Icons.face,color: Colors.blue,),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
                  Text(widget.user.name,style: TextStyle(color: Colors.blue),)
                ],
              ),
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
                                      future: DBController.get(command: 'get_esp32_with_room', data: {'roomID':room.id.toString()}),
                                      builder: (context,snapshot) {
                                        if(!snapshot.hasData)return Center();
                                        if(snapshot.connectionState==ConnectionState.waiting)return Center(child: CircularProgressIndicator(),);
                                        print(snapshot.data);
                                        var jsons = jsonDecode(snapshot.data!);
                                        print(jsons);
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
                                        return StatefulBuilder(
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
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Text(room.id,style: GoogleFonts.nunitoSans(fontWeight: FontWeight.w100,color: Colors.white),),
                                                            Text(room.name.toUpperCase(),style: GoogleFonts.nunitoSans(fontWeight: FontWeight.bold,color: Colors.white),),
                                                            // Row(
                                                            //   crossAxisAlignment: CrossAxisAlignment.start,
                                                            //   children: [
                                                            //     Text(tags.where((element) => room.id==element.roomID).length.toString(),style: GoogleFonts.nunitoSans(fontWeight: FontWeight.bold,color: Colors.white),),
                                                            //     Text(tags.where((element) => room.id==element.roomID).length>1?' tags':' tag',style: GoogleFonts.nunitoSans(fontWeight: FontWeight.w100,color: Colors.white,fontSize: 10),),
                                                            //   ],
                                                            // ),

                                                          ],
                                                        ),
                                                        Column(
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Text(esp.id,style: GoogleFonts.nunitoSans(fontWeight: FontWeight.w100,color: Colors.white),),
                                                                CustomTextButton(
                                                                  onPressed: (){
                                                                    DBController.get(command: "update_esp32_reset/${esp.id}/1", data: {}).then((value) {
                                                                      print(value);
                                                                      stateDistanceFunction(() {
                                                                        esp.mode = esp.mode==1?0:1;

                                                                      });
                                                                    });

                                                                  },
                                                                  color: Colors.blue,
                                                                  style: TextStyle(fontSize: 8,color: Colors.white),
                                                                  text: "Mode: "+(esp.mode==0?"Scan":"Get ESP distance"),
                                                                ),
                                                                Text(esp.mode.toString(),style: GoogleFonts.nunitoSans(fontWeight: FontWeight.w100,color: Colors.white),),



                                                              ],
                                                            ),
                                                            Column(
                                                                children: [
                                                                  Text(esp.sensorDistance.toStringAsPrecision(2)+"m",style: GoogleFonts.nunitoSans(fontWeight: FontWeight.w100,color: Colors.white),)
                                                                ]
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  children:[
                                                    SizedBox(
                                                      height: 100,
                                                      child: FutureBuilder<String?>(
                                                          future:DBController.get(command: "get_tag", data: {"esp32":esp.id}),
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
                                                                                  TextEditingController tagName = TextEditingController(text: e.name);
                                                                                  bool isEdit = false;
                                                                                  double k = 250/esp.sensorDistance;
                                                                                  double x=0,y=0;
                                                                                  late Function(Function()) setStateMap;
                                                                                  getPos(){


                                                                                    DBController.get(command: "get_tag_pos", data: {}).then((value){
                                                                                      Future.delayed(Duration(seconds:5), () {
                                                                                      }).then((n) {
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
                                                                                      context: context,
                                                                                      statefulBuilder: StatefulBuilder(
                                                                                          builder: (context,setState3){
                                                                                            setStateMap = setState3;



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
                                                                                                    )
                                                                                                  ],
                                                                                                ),
                                                                                              ),
                                                                                            );
                                                                                          }
                                                                                      )

                                                                                  );
                                                                                },
                                                                                child: Text(e.name,style: GoogleFonts.nunitoSans(fontWeight: FontWeight.normal,color: Colors.white,fontSize: 10),)
                                                                            ),
                                                                          ),


                                                                        ],
                                                                      )
                                                                  ),
                                                                );
                                                              }).toList(),
                                                            );
                                                          }
                                                      ),
                                                    ),
                                                    // IconButton(
                                                    //   icon:Icon(Icons.add,color: Colors.white,),
                                                    //   onPressed: () {
                                                    //     TextEditingController tagName = TextEditingController();
                                                    //     Tools.basicDialog(
                                                    //         context: context,
                                                    //         statefulBuilder: StatefulBuilder(
                                                    //           builder: (contex,setState2){
                                                    //             return Dialog(
                                                    //               elevation: 0,
                                                    //               alignment: Alignment.center,
                                                    //               backgroundColor: Colors.transparent,
                                                    //               child: Column(
                                                    //                 mainAxisAlignment: MainAxisAlignment.center,
                                                    //                 crossAxisAlignment: CrossAxisAlignment.start,
                                                    //                 children: [
                                                    //                   Padding(
                                                    //                     padding: const EdgeInsets.only(left: 20.0),
                                                    //                     child: Text('Tag',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 18),),
                                                    //                   ),
                                                    //                   Container(
                                                    //                     padding: EdgeInsets.all(20),
                                                    //                     width: double.infinity,
                                                    //                     height: 100,
                                                    //                     decoration: BoxDecoration(
                                                    //                         color: Colors.white,
                                                    //                         borderRadius: BorderRadius.only(topLeft:Radius.circular(20),topRight: Radius.circular(20),bottomRight: Radius.circular(20))
                                                    //                     ),
                                                    //                     child: Column(
                                                    //                       children: [
                                                    //                         CustomTextField(
                                                    //                           hint: "Name",
                                                    //                           controller: tagName,
                                                    //                           color: Colors.blue,
                                                    //                         )
                                                    //                       ],
                                                    //                     ),
                                                    //                   ),
                                                    //                   // CustomTextButton(
                                                    //                   //   rTopRight: 20,
                                                    //                   //   rBottomRight: 20,
                                                    //                   //   rTopLeft: 0,
                                                    //                   //   rBottomLeft: 20,
                                                    //                   //   color: Colors.blue,
                                                    //                   //   text: "Add",
                                                    //                   //   onPressed: (){
                                                    //                   //     setState(() {
                                                    //                   //       Tag tag = Tag(id: (tags.length+1).toString(), name: tagName.text, roomID: room.id.toString(),x: 0,y: 0);
                                                    //                   //       tags.add(tag);
                                                    //                   //     });
                                                    //                   //     Navigator.of(context).pop();
                                                    //                   //   },
                                                    //                   // ),
                                                    //                 ],
                                                    //               ),
                                                    //             );
                                                    //           },
                                                    //         )
                                                    //     );
                                                    //   },
                                                    //
                                                    //
                                                    // )
                                                  ],
                                                ),
                                              );
                                            }
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
                                          Room room = Room(name: roomName.text, userID: widget.user.id.toString());
                                          DBController.get(command: 'insert_room/', data: {'userID':widget.user.id.toString(),'name':room.name}).then((room){
                                            print(room);
                                            ESP esp = ESP.toObject(jsonDecode(esp32));
                                            DBController.post(command: "update_esp32_room", data: {'id':esp.id,'roomID':room}).then((value) {
                                              setState(() {

                                                // Room room = Room(id: (rooms.length+1).toString(), name: roomName.text, userID: widget.user.id.toString());
                                                // rooms.add(room);
                                                // esp.roomID = room.id;
                                                // if(esps.where((element) => element.id==esp.id).isEmpty)esps.add(esp);
                                              });
                                              Navigator.of(context).pop();
                                            });

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