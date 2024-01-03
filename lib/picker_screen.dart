import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:poc_ml/models/ocr_detail.dart';
import 'package:poc_ml/utils/ocr_services.dart';

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

  void _pickImage() async {
    final image = await ImagePicker.platform.getImageFromSource(
      source: ImageSource.gallery,
    );
    if (image == null) return;

    final file = File(image.path);

    final ocrDetails = await OcrServices.mlKitTextrecognize(file);

    setState(() {
      previewImage = file;
      ocrs = ocrDetails;
    });
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
                onPressed: _resetOcrList,
                child: const Text('Reset'),
              ),
            ],
          ),
          Expanded(
            child: ListView.separated(
              separatorBuilder: (context, index) => const Divider(),
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
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
            ),
          )
        ],
      ),
    );
  }
}
