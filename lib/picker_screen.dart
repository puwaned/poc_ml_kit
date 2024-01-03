import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PickerScreen extends StatefulWidget {
  const PickerScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _State();
  }
}

class _State extends State<PickerScreen> {
  void _pickImage() async {
    final image = await ImagePicker.platform.getImageFromSource(
      source: ImageSource.gallery,
    );
    if (image == null) return;


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
          TextButton(
            onPressed: _pickImage,
            child: const Text('Pick Slip Image.'),
          )
        ],
      ),
    );
  }
}
