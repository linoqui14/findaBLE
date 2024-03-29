import 'dart:ui';
import 'dart:io' show File, Platform, stdout;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/users.dart';
class MyColors{
  static const Color red = Color(0xffBF1744);
  static const Color darkBlue = Color(0xff0433BF);
  static const Color grey = Color(0xff434A59);
  static const Color deadBlue = Color(0xff558ED9);
  static const Color skyBlueDead = Color(0xffA7C8F2);
  static const Color black = Color(0xff151515);

}

class Constants{
  static String hostname = Platform.localHostname;
}

class DBController{
  static String ip = "192.168.1.6";
  static String code = "123556";
  static Future<bool> testConnection() async{
    String phpurl = "http://$ip:5000/is_connected";
    var res = await http.post(Uri.parse(phpurl), body: {
    }); //sending post request with header data
    return int.parse(res.body)==1?true:false;
  }
  static Future<String?> get({required String command,required Map<String,dynamic> data}) async{
    var res = await http.post(Uri.http('$ip:5000','/$command'),body: data);
    return res.body;
  }

  static Future<String?> post({required String command,required Map<String,dynamic> data}) async{
    String phpurl = "http://$ip:5000/$command";
    var res = await http.post(Uri.parse(phpurl),body: data);
    // print(res.body);
    return res.body;

  }
  static Future<User?> getUser({required String username,required String password,required String deviceID}) async{
    String phpurl = "http://$ip:5000/get_user/$code";
    var res = await http.post(Uri.parse(phpurl),body: {'username':username,'password':password,'deviceID':deviceID});
    print(res.body);
    try {
      User user = User.toObject(json.decode(res.body));
      return user;
    }
    catch(e){
      return null;
    }
  }
  static Future<User?> getCurrentLogin({required deviceID}) async{
    String phpurl = "http://$ip:5000/get_current_login/$code";
    var res = await http.post(Uri.parse(phpurl),body: {'deviceID':deviceID,});

    try {
      User user = User.toObject(json.decode(res.body));
      return user;
    }
    catch(e){
      return null;
    }
  }

  static Future<User?> upsertUser({required User user}) async{
    String phpurl = "http://$ip:5000/insert_user/$code";
    var res = await http.post(Uri.parse(phpurl),body: user.toJson());
    try {
      User user = User.toObject(json.decode(res.body));
      return user;
    }
    catch(e){
      return null;
    }
  }




}
class Tools{



  // static Future<File> downloadFile(String url, String filename) async {
  //   http.Client client = new http.Client();
  //   var req = await client.get(Uri.parse(url));
  //   var bytes = req.bodyBytes;
  //   String dir = './images';
  //   File file = new File('$dir/$filename');
  //   await file.writeAsBytes(bytes);
  //   return file;
  // }
  static Future<void> basicDialog({
    required BuildContext context,
    required StatefulBuilder statefulBuilder,
    required Future<bool> Function()? onPop
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return WillPopScope(
            onWillPop: onPop,
            child: statefulBuilder
        );
      },
    );
  }


}