  // * Chat GPT Provided
  ////////////////////////////////
  import 'dart:typed_data';
import 'package:image/image.dart' show Image, encodeJpg;
Uint8List convertNv21ToJpeg(Uint8List nv21Bytes, int width, int height) {
    final Image imgImage = Image(width: width, height: height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int index = y * width + x;
        final int yp = nv21Bytes[index] & 0xFF;
        int r = yp;
        int g = yp;
        int b = yp;
        imgImage.setPixelRgba(x, y, r, g, b, 255);
      }
    }

    return Uint8List.fromList(encodeJpg(imgImage));
  }

  Uint8List convertBgra8888ToJpeg(Uint8List bgra8888Bytes, int width, int height) {
    final Image imgImage = Image(width: width, height: height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int index = y * width * 4 + x * 4;
        final int b = bgra8888Bytes[index];
        final int g = bgra8888Bytes[index + 1];
        final int r = bgra8888Bytes[index + 2];
        final int a = bgra8888Bytes[index + 3];
        imgImage.setPixelRgba(x, y, r, g, b, a);
      }
    }

    return Uint8List.fromList(encodeJpg(imgImage));
  }