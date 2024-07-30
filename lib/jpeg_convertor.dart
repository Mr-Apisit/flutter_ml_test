// * Chat GPT Provided
////////////////////////////////
import 'dart:typed_data';
import 'package:image/image.dart' show Image, bakeOrientation, encodeJpg;

Uint8List convertNv21ToJpeg(Uint8List nv21Bytes, int width, int height) {
  Image imgImage = Image(width: width, height: height);
  final int frameSize = width * height;
  imgImage = bakeOrientation(imgImage);
  for (int j = 0, yp = 0; j < height; j++) {
    int uvp = frameSize + (j >> 1) * width, u = 0, v = 0;
    for (int i = 0; i < width; i++, yp++) {
      int y = (0xff & nv21Bytes[yp]) - 16;
      if (y < 0) y = 0;
      if ((i & 1) == 0) {
        v = (0xff & nv21Bytes[uvp++]) - 128;
        u = (0xff & nv21Bytes[uvp++]) - 128;
      }

      int y1192 = 1192 * y;
      int r = (y1192 + 1634 * v);
      int g = (y1192 - 833 * v - 400 * u);
      int b = (y1192 + 2066 * u);

      if (r < 0) {
        r = 0;
      } else if (r > 262143) {
        r = 262143;
      }
      if (g < 0) {
        g = 0;
      } else if (g > 262143) {
        g = 262143;
      }
      if (b < 0) {
        b = 0;
      } else if (b > 262143) {
        b = 262143;
      }

      imgImage.setPixelRgba(i, j, (r >> 10) & 0xff, (g >> 10) & 0xff, (b >> 10) & 0xff, 255);
    }
  }
  return Uint8List.fromList(encodeJpg(imgImage));
}

Uint8List convertBgra8888ToJpeg(Uint8List bgra8888Bytes, int width, int height) {
  final imgImage = Image(width: width, height: height);

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
