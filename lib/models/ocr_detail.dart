import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class OcrDetail extends Equatable {
  const OcrDetail({
    required this.subPath,
    required this.mlText,
    required this.rect,
    required this.tessText,
  });

  final Rect rect;
  final String subPath;
  final String mlText;
  final String tessText;

  @override
  List<Object> get props => [
        subPath,
        rect,
        mlText,
        tessText,
      ];
}
