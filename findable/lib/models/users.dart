
class User{
  int? id;
  String name,password,deviceID;
  bool isLogin;

  User({this.id, required this.name,required this.password,required this.deviceID,this.isLogin = false});


  Map<String,dynamic> toJson(){
    return {
      'id':id.toString(),
      'username':name,
      'password':password,
      'deviceID':deviceID,
      'isLogin':isLogin.toString()
    };
  }

  static User toObject(Map<String,dynamic> json){
    return User(
      id: json['id'],
      password: json['password'],
      name: json['name'],
      deviceID: json['deviceID'],
      isLogin: json['isLogin'],
    );
  }
}