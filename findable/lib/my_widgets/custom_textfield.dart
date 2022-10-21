

import 'package:flutter/material.dart';

import '../tools/variables.dart';



class CustomTextField extends StatefulWidget{
  CustomTextField({
    Key? key,
    required this.hint,
    this.padding = const EdgeInsets.all(5),
    this.obscureText = false,
    this.rTopRight = 10,
    this.rTopLeft = 10,
    this.rBottomRight = 10,
    this.rBottomLeft = 10,
    this.color = MyColors.red,
    required this.controller,
    this.filled = false,
    this.icon,
    this.enable = true,
    this.readonly = false,
    this.suffix,
    this.keyBoardType,
    this.onChange,
    this.alignment,
    this.rAll,
    this.filledColor,
    this.borderWidth = 1
  }) : super(key: key);

  final String hint;
  EdgeInsets padding;
  TextInputType? keyBoardType;
  final Function(String)? onChange;
  IconData? icon;
  Widget? suffix;
  bool obscureText = false;
  double rTopRight;
  double rTopLeft ;
  double rBottomRight;
  double rBottomLeft;
  double? rAll;
  Color color;
  Color? filledColor;
  bool filled;
  bool enable;
  bool readonly;
  double borderWidth;
  TextEditingController controller;
  TextAlign? alignment;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();



}

class _CustomTextFieldState extends State<CustomTextField>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
      padding: widget.padding,
      child: TextField(
        textAlign: widget.alignment!=null?widget.alignment!:TextAlign.start,
        keyboardType: widget.keyBoardType!=null?widget.keyBoardType!:TextInputType.text,
        minLines: 1,
        maxLines: widget.obscureText?1:3,
        readOnly: widget.readonly,
        enabled:widget.enable,
        controller: widget.controller,
        obscureText: widget.obscureText,
        onChanged: widget.onChange,
        style: TextStyle(

          color: widget.color.withAlpha(widget.enable?255:50),

        ),
        decoration: InputDecoration(
            fillColor: widget.filledColor,

            suffixIcon:widget.suffix,
            prefixIcon: widget.icon != null?Icon(widget.icon,color: widget.color.withAlpha(widget.enable?255:50),size: 20,):null,
            filled: widget.filled,
            contentPadding: EdgeInsets.only(bottom: 0,top: 10,left: 10,right: 10),
            labelText: widget.hint,
            labelStyle: TextStyle(
              color: widget.color.withAlpha(widget.enable?255:50),
            ),
            border: OutlineInputBorder(
                borderSide: BorderSide(
                    width: widget.borderWidth,
                    color:  widget.color.withAlpha(widget.enable?255:50)
                ),
                borderRadius: widget.rAll!=null?BorderRadius.all(Radius.circular(widget.rAll!)):BorderRadius.only(
                  bottomRight: Radius.circular(widget.rBottomRight),
                  bottomLeft: Radius.circular(widget.rBottomLeft),
                  topRight: Radius.circular(widget.rTopRight),
                  topLeft: Radius.circular(widget.rTopLeft),
                )
            ),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    width: widget.borderWidth,
                    color:  widget.color.withAlpha(widget.enable?255:50)
                ),
                borderRadius:  widget.rAll!=null?BorderRadius.all(Radius.circular(widget.rAll!)):BorderRadius.only(
                  bottomRight: Radius.circular(widget.rBottomRight),
                  bottomLeft: Radius.circular(widget.rBottomLeft),
                  topRight: Radius.circular(widget.rTopRight),
                  topLeft: Radius.circular(widget.rTopLeft),
                )
            ),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    width: widget.borderWidth,
                    color: widget.color.withAlpha(widget.enable?255:50)
                ),
                borderRadius:  widget.rAll!=null?BorderRadius.all(Radius.circular(widget.rAll!)):BorderRadius.only(
                  bottomRight: Radius.circular(widget.rBottomRight),
                  bottomLeft: Radius.circular(widget.rBottomLeft),
                  topRight: Radius.circular(widget.rTopRight),
                  topLeft: Radius.circular(widget.rTopLeft),
                )
            ),
            disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    width: widget.borderWidth,
                    color: widget.color.withAlpha(50)
                ),
                borderRadius:  widget.rAll!=null?BorderRadius.all(Radius.circular(widget.rAll!)):BorderRadius.only(
                  bottomRight: Radius.circular(widget.rBottomRight),
                  bottomLeft: Radius.circular(widget.rBottomLeft),
                  topRight: Radius.circular(widget.rTopRight),
                  topLeft: Radius.circular(widget.rTopLeft),
                )
            ),
            hintText: widget.hint,
            hintStyle: TextStyle(
                color:  widget.color.withAlpha(100)
            )
        ),
      ),
    );
  }


}