
class ESP{
  String id;
  int mode;
  double sensorDistance;

  ESP({required this.id, required this.sensorDistance, required this.mode});



  Map<String,dynamic> toJson(){
    return {
      'id':id.toString(),
      'distance':sensorDistance,
      'reset':mode,
    };
  }

  static ESP toObject(Map<String,dynamic> json){
    double distance = 0;
    try{
      distance = json['distance'];
    }catch(e){
      distance = 0.0;
    }
    return ESP(
        id: json['id'],
        mode:json['mode'],
        sensorDistance:distance,
    );
  }
}