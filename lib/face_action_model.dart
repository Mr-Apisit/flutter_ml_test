import 'dart:typed_data';

enum FaceActionType {faceStand, faceSmile, faceLeft, faceRight}
class FaceAction {
  String msg;
  Uint8List? faceStand;
  Uint8List? faceSmile;
  Uint8List? faceLeft;
  Uint8List? faceRight;
  FaceAction(
    this.msg, {
    this.faceStand,
    this.faceSmile,
    this.faceLeft,
    this.faceRight,
  });
}
