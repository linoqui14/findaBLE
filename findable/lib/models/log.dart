class Log {
  int id;
  String date,roomID,userID,status;
  double left,right;

  Log({this.id = 0, required this.date, required this.roomID, required this.userID,required this.status,required this.right,required this.left});

  Map<String,dynamic> tojson(){

    return{
      'id':id.toString(),
      'date':date,
      'roomID':roomID,
      'userID':userID,
      'status':status,
      'left':status,
      'right':status,
    };
  }

  static Log toObject({required Map<String,dynamic> json} ){
    return Log(
      date: json['log_time'].toString(),
      roomID: json['roomID'],
      userID: json['userID'],
      id:json['id'],
      status:json['status'],
      right:json['right'],
      left: json['left'],
    );
  }
}