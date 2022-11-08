import 'package:flutter/material.dart';

const dealDuration = Duration(milliseconds: 350);
const fadeInitDuration = Duration(milliseconds: 500);
const curves = Curves.decelerate;

Offset? getGlobalOffsetByKey(GlobalKey key) {
  final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
  final offSet = renderBox?.globalToLocal(Offset.zero);
  return offSet;
}

Offset? getLocalOffsetByKey(GlobalKey key) {
  final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
  final offSet = renderBox?.localToGlobal(Offset.zero);
  return offSet;
}

Size? getSizeByKey(GlobalKey key) {
  final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
  final size = renderBox?.size;
  return size;
}

Duration deplayPerItemDuration(bool delayPerItem, int index) =>
    delayPerItem ? (dealDuration * index) : Duration.zero;
