import 'package:flutter/material.dart';


class AppFonts {
  AppFonts._();

  
  
  static const String poppinsFontFamily = 'Poppins';  
  static const String headlandFontFamily = 'HeadLand'; 

 
  static TextStyle poppins({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? wordSpacing,
    double? height,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    FontStyle? fontStyle,
    TextBaseline? textBaseline,
    List<Shadow>? shadows,
    TextOverflow? overflow,
  }) {
    return TextStyle(
      fontFamily: poppinsFontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.w400,
      color: color,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      height: height,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      fontStyle: fontStyle,
      textBaseline: textBaseline,
      shadows: shadows,
      overflow: overflow,
    );
  }

  
  static TextStyle poppinsRegular({
    double? fontSize,
    Color? color,
    double? letterSpacing,
    double? wordSpacing,
    double? height,
    TextDecoration? decoration,
    FontStyle? fontStyle,
    List<Shadow>? shadows,
    TextOverflow? overflow,
  }) {
    return TextStyle(
      fontFamily: poppinsFontFamily,
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: color,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      height: height,
      decoration: decoration,
      fontStyle: fontStyle,
      shadows: shadows,
      overflow: overflow,
    );
  }


  static TextStyle poppinsMedium({
    double? fontSize,
    Color? color,
    double? letterSpacing,
    double? wordSpacing,
    double? height,
    TextDecoration? decoration,
    FontStyle? fontStyle,
    List<Shadow>? shadows,
    TextOverflow? overflow,
  }) {
    return TextStyle(
      fontFamily: poppinsFontFamily,
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: color,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      height: height,
      decoration: decoration,
      fontStyle: fontStyle,
      shadows: shadows,
      overflow: overflow,
    );
  }

  
  static TextStyle poppinsSemiBold({
    double? fontSize,
    Color? color,
    double? letterSpacing,
    double? wordSpacing,
    double? height,
    TextDecoration? decoration,
    FontStyle? fontStyle,
    List<Shadow>? shadows,
    TextOverflow? overflow,
  }) {
    return TextStyle(
      fontFamily: poppinsFontFamily,
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: color,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      height: height,
      decoration: decoration,
      fontStyle: fontStyle,
      shadows: shadows,
      overflow: overflow,
    );
  }

 
  static TextStyle poppinsBold({
    double? fontSize,
    Color? color,
    double? letterSpacing,
    double? wordSpacing,
    double? height,
    TextDecoration? decoration,
    FontStyle? fontStyle,
    List<Shadow>? shadows,
    TextOverflow? overflow,
  }) {
    return TextStyle(
      fontFamily: poppinsFontFamily,
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      color: color,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      height: height,
      decoration: decoration,
      fontStyle: fontStyle,
      shadows: shadows,
      overflow: overflow,
    );
  }

  
 
  static TextStyle headland({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? wordSpacing,
    double? height,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    FontStyle? fontStyle,
    TextBaseline? textBaseline,
    List<Shadow>? shadows,
    TextOverflow? overflow,
  }) {
    return TextStyle(
      fontFamily: headlandFontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.w400,
      color: color,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      height: height,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      fontStyle: fontStyle,
      textBaseline: textBaseline,
      shadows: shadows,
      overflow: overflow,
    );
  }

}