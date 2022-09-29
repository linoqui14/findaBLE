import 'package:findable/my_widgets/pressable.dart';
import 'package:flutter/material.dart';


class PressOnText extends StatelessWidget{
  const PressOnText({Key? key,required this.text,required this.pressables,this.textStyle}) : super(key: key);
  final String text;
  final List<Pressable> pressables;
  final TextStyle? textStyle;
  static String tokenizer = '%press';

  Widget initWords(){

    List<String> words = text.split(tokenizer);
    List<Widget> row =[];

    if(words.length-1!=pressables.length){
      return Text("Error");
    }
    for (int i = 0 ;i<words.length-1;i++) {
      print(words[i]);
      row.add(Text(words[i],style: textStyle,));
      row.add(
          GestureDetector(
            onTap: (){pressables[words.indexOf(words[i])].onPressed();},
            child: pressables[words.indexOf(words[i])].text,

          ));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: row,
    );
  }


  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return initWords();
  }



}