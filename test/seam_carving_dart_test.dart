import 'dart:io';

import 'package:seam_carver_dart/seam_carver_dart.dart';
import 'package:test/test.dart';

const _imagePath = "./test/resources/chrome.jpeg";
const _imagePathHeightResult = "./test/resources/chrome_height.jpeg";
const _imagePathWidthResult = "./test/resources/chrome_width.jpeg";

void main() {
  test('reducing image height by 10 from scr', () async {
    var newImage = await reduceImageFromPath(_imagePath,
        options: ReduceOptions(dimension: Dimension.height, amount: 10));
    var imageToCompareBytes = File(_imagePathHeightResult).readAsBytesSync();
    expect(imageToCompareBytes.length, newImage.length);
    for (int i = 0; i < newImage.length; i++) {
      expect(imageToCompareBytes[i], newImage[i]);
    }
  });

  test('reducing image width by 10 from scr', () async {
    var newImage = await reduceImageFromPath(_imagePath,
        options: ReduceOptions(dimension: Dimension.width, amount: 10));
    var imageToCompareBytes = File(_imagePathWidthResult).readAsBytesSync();
    expect(imageToCompareBytes.length, newImage.length);
    for (int i = 0; i < newImage.length; i++) {
      expect(imageToCompareBytes[i], newImage[i]);
    }
  });

   test('reducing image width by 10 from bytes', () async {

    final bytes = File(_imagePath).readAsBytesSync();
    var newImage = reduceImageFromBytes(bytes,ImageFormat.jpeg,
        options: ReduceOptions(dimension: Dimension.width, amount: 10));
    var imageToCompareBytes = File(_imagePathWidthResult).readAsBytesSync();
    expect(imageToCompareBytes.length, newImage.length);
    for (int i = 0; i < newImage.length; i++) {
      expect(imageToCompareBytes[i], newImage[i]);
    }
  });
}
