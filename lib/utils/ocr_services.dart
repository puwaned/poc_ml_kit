import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tesseract_ocr/android_ios.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:poc_ml/models/ocr_detail.dart';

class OcrServices {
  const OcrServices();

  static Future<String?> rectCrop(File rawFile, Rect rect) async {
    try {
      final bytes = rawFile.readAsBytesSync();
      final image = decodeImage(bytes);

      if (image == null) throw Exception('image is null');

      final cropImage = copyCrop(
        image,
        x: rect.left.toInt(),
        y: rect.top.toInt(),
        width: rect.right.toInt() - rect.left.toInt(),
        height: rect.bottom.toInt() - rect.top.toInt(),
      );

      List<int> jpgBytes = encodeJpg(cropImage);

      final tempPath = Platform.isAndroid
          ? await getApplicationDocumentsDirectory()
          : await getTemporaryDirectory();

      final path = '${tempPath.path}/${DateTime.now().millisecond}.jpg';

      final file = File(path);
      await file.writeAsBytes(jpgBytes);

      return path;
    } catch (e) {
      print('Crop Error $e');
      return null;
    }
  }

  static Future<String?> tesseractOcr(String path) async {
    try {
      final ocrString = await FlutterTesseractOcr.extractText(
        language: 'tha',
        path,
        args: {
          "psm": "3",
          "preserve_interword_spaces": "0",
        },
      );

      return ocrString;
    } catch (e) {
      print('Tesseract Error ===> $e');
      return null;
    }
  }

  static Future<List<OcrDetail>> mlKitTextrecognize(File file) async {
    try {
      final List<OcrDetail> results = [];
      final textReg = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText regText = await textReg.processImage(
        InputImage.fromFile(file),
      );

      for (TextBlock block in regText.blocks) {
        final Rect rect = block.boundingBox;
        final String? cropPath = await rectCrop(file, rect);

        if (cropPath == null) throw Exception('Crop image failure');
        final tessOcrText = await tesseractOcr(cropPath);

        if (tessOcrText == null) throw Exception('Tess Ocr error');

        results.add(
          OcrDetail(
            subPath: cropPath,
            mlText: block.text,
            rect: rect,
            tessText: tessOcrText,
          ),
        );
      }

      return results;
    } catch (e) {
      print('ML Kit Error ===> $e');
      return [];
    }
  }
}
