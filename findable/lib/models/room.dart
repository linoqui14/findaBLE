
class Room {
  String id,name,userID,esp32ID;
  Room({this.id = "", required this.name,required this.userID,required this.esp32ID});


  Map<String,dynamic> toJson({bool isNew = false}){
    if(isNew){
      return {
        'userID':userID,
        'name':name,
        'esp32ID':esp32ID,
      };
    }

    return {
      'id':id.toString(),
      'userID':userID,
      'name':name,
      'esp32ID':esp32ID,
    };
  }

  static Room toObject(Map<String,dynamic> json){
    return Room(
      id: json['id'],
      name: json['name'],
      userID:json['userID'],
      esp32ID:json['esp32ID'],
    );
  }



}