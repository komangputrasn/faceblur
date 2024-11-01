import 'package:dio/dio.dart';
import 'package:faceblur/result_model.dart';
import 'package:faceblur/result_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final List<XFile> images = [];

  Future<List<DetectionResult>> processImage(BuildContext context) async {
    final FormData formData = FormData();

    for (var image in images) {
      formData.files.add(
        MapEntry(
          "files",
          MultipartFile.fromFileSync(image.path, filename: image.name),
        ),
      );
    }

    final Dio dio = Dio();

    try {
      final Response response = await dio.post(
        'https://pumped-kingfish-partly.ngrok-free.app/upload',
        data: formData,
        onSendProgress: (sent, total) {
          if (total <= 0) {
            return;
          }
          print('percentage: ${(sent / total * 100).toStringAsFixed(0)}%');
        },
      );

      print("Response: $response");

      final List<DetectionResult> results = response.data
          .map<DetectionResult>(
              (item) => DetectionResult(resultPath: item['resultPath']))
          .toList();

      print("result: ${results.map((item) => item.resultPath).toList()}");

      // Navigate to the result screen with the processed data

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultPage(
                resultPaths: results.map((item) => item.resultPath).toList()),
          ),
        );
      }

      return results;
    } catch (err) {
      print('Error: $err');
      rethrow;
    }
  }

  void pickFromGallery(BuildContext context) async {
    final ImagePicker imagePicker = ImagePicker();
    final List<XFile> pickedImages = await imagePicker.pickMultiImage();
    for (var item in pickedImages) {
      images.add(item);
    }

    print("pickedImages: ${pickedImages.isNotEmpty}");
    print("Context: ${context.mounted}");
    if (pickedImages.isNotEmpty) {
      await processImage(context);
    }
  }

  void pickFromCamera(BuildContext context) async {
    final ImagePicker imagePicker = ImagePicker();
    final XFile? image =
        await imagePicker.pickImage(source: ImageSource.camera);

    if (image != null) {
      images.add(image);
      if (context.mounted) {
        await processImage(context);
      }
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
