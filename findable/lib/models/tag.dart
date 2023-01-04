
class Tag{
String name,espID,id;
double left,right;

Tag({required this.id,required this.name, required this.espID, required this.right, required this.left});

static Tag toObject(Map<String,dynamic> json){
  return Tag(
    id: json['id'],
    name: json['name'],
    espID:json['espID'],
    left:json['distance_left'],
    right:json['distance_right'],
  );
}
}