
class User{
  int? id;
  String name,password;

  User({this.id, required this.name,required this.password});


  Map<String,dynamic> toJson(){
    return {
      'username':name,
      'password':password
    };
  }

  static User toObject(Map<String,dynamic> json){
    return User(
        id: json['id'],
        password: json['password'],
        name: json['name']
    );
  }
}