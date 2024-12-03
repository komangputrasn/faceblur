import 'package:faceblur/result_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final List<XFile> images = [];

  void pickFromGallery(BuildContext context) async {
    final ImagePicker imagePicker = ImagePicker();
    final NavigatorState navigator = Navigator.of(context);
    final List<XFile> pickedImages = await imagePicker.pickMultiImage();

    if (pickedImages.isNotEmpty) {
      navigator.push(
        MaterialPageRoute(
          builder: (context) => ResultPage(images: pickedImages),
        ),
      );
    }
  }

  void pickFromCamera(BuildContext context) async {
    final NavigatorState navigator = Navigator.of(context);
    final ImagePicker imagePicker = ImagePicker();
    final XFile? image =
        await imagePicker.pickImage(source: ImageSource.camera);

    if (image != null) {
      navigator.push(
        MaterialPageRoute(
          builder: (context) => ResultPage(images: [image]),
        ),
      );
    }
  }

  void showImageOptionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
      ),
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text('Camera'),
            onTap: () {
              Navigator.pop(context); // Close the bottom sheet
              pickFromCamera(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.photo),
            title: Text('Gallery'),
            onTap: () {
              Navigator.pop(context); // Close the bottom sheet
              pickFromGallery(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FaceBlur'),
      ),
      body: Center(child: Text('Press + to select photo')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showImageOptionBottomSheet(context),
        tooltip: 'Increment',
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}
