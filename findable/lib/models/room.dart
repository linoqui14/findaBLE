
class Room {
  String id,name,userID;
  Room({required this.id, required this.name,required this.userID});


  Map<String,dynamic> toJson(){
    return {
      'id':id.toString(),
      'userID':userID,
      'name':name,
    };
  }

  static Room toObject(Map<String,dynamic> json){
    return Room(
      id: json['id'],
      name: json['name'],
      userID:json['userID'],

    );
  }



}