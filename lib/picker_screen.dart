import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:poc_ml/models/ocr_detail.dart';
import 'package:poc_ml/utils/ocr_services.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class PickerScreen extends StatefulWidget {
  const PickerScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _State();
  }
}

class _State extends State<PickerScreen> {
  List<OcrDetail> ocrs = [];
  File? previewImage;
  final _controller = ScreenshotController();

  void _pickImage() async {

    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (image == null) return;

    final file = File(image.path);
    final stopwatch = Stopwatch()..start();
    final ocrDetails = await OcrServices.mlKitTextrecognize(file);
    print('time pass ${stopwatch.elapsed.inSeconds}');
    stopwatch.stop();
    stopwatch.reset();
    setState(() {
      previewImage = file;
      ocrs = ocrDetails;
    });
  }

  void _export() async {
    try {
      final capture = await _controller.captureFromLongWidget(
        InheritedTheme.captureAll(
          context,
          Material(
            child: _buildLongWidget(),
          ),
        ),
        delay: Duration(milliseconds: 100),
        context: context,
      );
      if (capture == null) return;
      final file =
          XFile.fromData(capture, mimeType: "image/png", name: "capture.png");
      await Share.shareXFiles([file]);
    } catch (err) {
      print(err);
    }
  }

  void _showPreviewFullImage() {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        if (previewImage == null) {
          return CloseButton(
            onPressed: () {
              Navigator.pop(context);
            },
          );
        }

        return Container(
          alignment: Alignment.center,
          child: Image.file(previewImage!),
        );
      },
    );
  }

  void _resetOcrList() {
    setState(() {
      ocrs = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("POC ML KIT"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: _pickImage,
                child: const Text('Pick Slip Image'),
              ),
              TextButton(
                onPressed: _showPreviewFullImage,
                child: const Text('Preview Image'),
              ),
              TextButton(
                onPressed: _export,
                child: const Text('Capture'),
              ),
            ],
          ),
          Expanded(
            child: _buildList(),
          )
        ],
      ),
    );
  }

  Widget _buildLongWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: ocrs.map((ocr) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.file(File(ocr.subPath)),
                const SizedBox(height: 10.0),
                Text('ML: ${ocr.mlText}'),
                Text('Tess: ${ocr.tessText}'),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildList() {
    return ListView.separated(
      separatorBuilder: (context, index) => const Divider(),
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      itemCount: ocrs.length,
      itemBuilder: (context, index) {
        final ocr = ocrs.elementAt(index);
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.file(File(ocr.subPath)),
                const SizedBox(height: 10.0),
                Text('ML: ${ocr.mlText}'),
                Text('Tess: ${ocr.tessText}'),
              ],
            ),
          ),
        );
      },
    );
  }
}
