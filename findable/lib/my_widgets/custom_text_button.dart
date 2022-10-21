

import 'package:flutter/material.dart';

import '../tools/variables.dart';



class CustomTextButton extends StatelessWidget{
  const CustomTextButton(
      {
        Key? key,
        this.onPressed,
        this.text="Text Here",
        this.rTopRight=10,this.rTopLeft=10,
        this.rBottomRight=10,this.rBottomLeft=10,
        this.rAll,
        this.color=MyColors.skyBlueDead,
        this.width = 100,
        this.height = 30,
        this.padding = EdgeInsets.zero,
        this.onHold
      }) : super(key: key);

  final Function()? onPressed;
  final String text;
  final double rTopRight;
  final double rTopLeft ;
  final double rBottomRight;
  final double rBottomLeft;
  final double? rAll;
  final Color color;
  final double width;
  final double height;
  final EdgeInsets padding;
  final Function()? onHold;


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return TextButton(
        onLongPress: onHold,
        onPressed: onPressed,
        child: Container(
            height: height,
            padding: padding,
            alignment: Alignment.center,
            width: width,
            child: Text(text,style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)
        ),
        style: ButtonStyle(
            padding: MaterialStateProperty.all(EdgeInsets.zero),
            fixedSize: MaterialStateProperty.all(Size(width, height)),
            backgroundColor: MaterialStateProperty.all(color),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: rAll!=null?BorderRadius.all(Radius.circular(rAll!)):BorderRadius.only(
                      bottomRight: Radius.circular(rBottomRight),
                      bottomLeft: Radius.circular(rBottomLeft),
                      topRight: Radius.circular(rTopRight),
                      topLeft: Radius.circular(rTopLeft),
                    )

                )
            )
        )
    );
  }
}