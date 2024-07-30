import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';

Future<void> sendToServer(List<Uint8List> filesImage) async {
  try {
    // Create Dio instance
    Dio dio = Dio();

    // Create FormData object
    FormData formData = FormData();

    // Add files to FormData
    final date =
        "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}-${DateTime.now().hour}-${DateTime.now().minute}-${DateTime.now().second}";
    for (int i = 0; i < filesImage.length; i++) {
      formData.files.add(
        MapEntry(
          'images', // Field name should match the one expected by the server
          MultipartFile.fromBytes(
            filesImage[i],
            filename: 'image$i-$date.jpg', // Name of the file
            contentType: MediaType('image', 'jpeg'), // Media type of the file
          ),
        ),
      );
    }

    // Send POST request
    Response response = await dio.post(
      'http://192.168.1.51:3000/uploads', // Replace with your server URL
      data: formData,
    );

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print('Upload successful: ${response.data}');
      }
    } else {
      if (kDebugMode) {
        print('Upload failed: ${response.statusCode}');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error uploading files: $e');
    }
  }
}
