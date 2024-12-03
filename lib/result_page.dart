import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ResultPage extends StatefulWidget {
  final List<XFile> images;

  const ResultPage({super.key, required this.images});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  List<String> imageUrls = [];
  bool isLoading = false;
  String progressPercentage = '';

  void processImage() async {
    final Dio dio = Dio();
    final FormData formData = FormData();

    for (var image in widget.images) {
      formData.files.add(
        MapEntry(
          "files",
          MultipartFile.fromFileSync(image.path, filename: image.name),
        ),
      );
    }

    setState(() {
      isLoading = true;
    });

    try {
      final Response response = await dio.post(
        'https://pumped-kingfish-partly.ngrok-free.app/upload',
        data: formData,
        onSendProgress: (sent, total) {
          if (total <= 0) {
            return;
          }
          setState(() {
            progressPercentage = (sent / total * 100).toStringAsFixed(0);
            debugPrint('Progress percentage: $progressPercentage');
          });
        },
      );

      for (var item in response.data) {
        imageUrls.add(
            'https://pumped-kingfish-partly.ngrok-free.app/${item["resultPath"]}');
      }

      debugPrint('Images: $imageUrls');
    } catch (err) {
      rethrow;
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    debugPrint('List of images: ${widget.images}');
    processImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Results'),
      ),
      body: Center(
        child: isLoading
            ? Text('Processing: $progressPercentage%')
            : ListView.separated(
                separatorBuilder: (context, index) => SizedBox(height: 15),
                itemBuilder: (context, index) =>
                    Image.network(imageUrls[index]),
                itemCount: widget.images.length,
              ),
      ),
    );
  }
}
