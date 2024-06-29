import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:image/image.dart';

enum ImageFormat {
  jpeg,
  png,
  gif,
  bmp,
  tiff,
  webp,
}

extension ImageFormatExtension on ImageFormat {
  String get value {
    switch (this) {
      case ImageFormat.jpeg:
        return 'jpeg';
      case ImageFormat.png:
        return 'png';
      case ImageFormat.gif:
        return 'gif';
      case ImageFormat.bmp:
        return 'bmp';
      case ImageFormat.tiff:
        return 'tiff';
      case ImageFormat.webp:
        return 'webp';
      default:
        return '';
    }
  }
}

ImageFormat? _imageFromString(String value) {
  switch (value) {
    case 'jpeg':
      return ImageFormat.jpeg;
    case 'png':
      return ImageFormat.png;
    case 'gif':
      return ImageFormat.gif;
    case 'bmp':
      return ImageFormat.bmp;
    case 'tiff':
      return ImageFormat.tiff;
    case 'webp':
      return ImageFormat.webp;
    default:
      return null;
  }
}

class InvalidImageInputException implements Exception {
  final String message;
  InvalidImageInputException(this.message);
}

typedef Seam = List<Point>;
typedef CostMatrix = List<List<double>>;

enum Dimension { height, width }

class ReduceOptions {
  final Dimension dimension;
  final int amount;
  ReduceOptions({required this.dimension, required this.amount});
}

Future<Uint8List> reduceImageFromPath(String src,
    {required ReduceOptions options}) async {
  final bytes = await File(src).readAsBytes();


  final sanitizedFormat = src.split(".").last;
  final imageFormat = _imageFromString(sanitizedFormat);
  if (imageFormat == null) {
    throw ArgumentError.value("Unsupported image type provided: $sanitizedFormat");
  }

  return reduceImageFromBytes(bytes, _imageFromString(sanitizedFormat)!,
      options: options);
}

Uint8List reduceImageFromBytes(Uint8List input, ImageFormat format,
    {required ReduceOptions options}) {
  final formatString = ".${format.value}";
  final im = decodeNamedImage(formatString, input);

  if (im == null) {
    throw ArgumentError("Could not decode image");
  }

  final Uint8List? reducedBytes;
  if (options.dimension == Dimension.height) {
    final result = _reduceHeight(im, options.amount);
    reducedBytes = encodeNamedImage(formatString, result);
  } else {
    final result = _reduceWidth(im, options.amount);
    reducedBytes = encodeNamedImage(formatString, result);
  }

  if (reducedBytes == null) {
    throw StateError("Could not encode to original format");
  }

  return reducedBytes;
}


Image _reduceHeight(Image im, int n) {
  int height = im.height;
  if (height < n) {
    throw InvalidImageInputException(
        'Cannot resize image of height $height by $n pixels');
  }

  for (int x = 0; x < n; x++) {
    final energy = _generateEnergyMap(im);
    final seam = _generateSeam(energy);
    im = _removeSeam(im, seam);
  }
  return im;
}

Image _reduceWidth(Image im, int n) {
  Image rotated = copyRotate(im, angle: 90);
  var reducedImage = _reduceHeight(rotated, n);
  return copyRotate(reducedImage, angle: -90);
}

Image _generateEnergyMap(Image im) {
  Image gray = grayscale(Image.from(im));
  return sobel(gray);
}

Seam _generateSeam(Image im) {
  final mat = _generateCostMatrix(im);
  return _findLowestCostSeam(mat);
}

Image _removeSeam(Image im, Seam seam) {
  final out = Image(width: im.width, height: im.height - 1);

  for (final point in seam) {
    final x = point.x.toInt();
    final yPoint = point.y.toInt();
    for (int y = 0; y < point.y; y++) {
      out.setPixel(x, y, im.getPixel(x, y));
    }
    for (int y = yPoint + 1; y < im.height; y++) {
      out.setPixel(x, y - 1, im.getPixel(x, y));
    }
  }

  return out;
}

CostMatrix _generateCostMatrix(Image im) {
  final mat = List.generate(
    im.width,
    (x) => List.generate(
      im.height,
      (y) => x == 0 ? _getInitialEnergy(im, x, y) : 0.0,
    ),
  );

  double getMinPoint(int x, int y) {
    final pixel = im.getPixel(x, y);
    var up = double.maxFinite, down = double.maxFinite;
    final left = mat[x - 1][y];
    if (y != 0) {
      up = mat[x - 1][y - 1];
    }

    if (y < im.height - 1) {
      down = mat[x - 1][y + 1];
    }

    final val = min(left, min(up, down));

    return val + (pixel.r / pixel.a);
  }

  for (int x = 1; x < im.width; x++) {
    for (int y = 0; y < im.height; y++) {
      mat[x][y] = getMinPoint(x, y);
    }
  }

  return mat;
}

int _findMinimumBottomIndex(CostMatrix mat) {
  int width = mat.length;
  int height = mat[0].length;

  var min = double.maxFinite;
  var y = 0;
  for (int i = 0; i < height; i++) {
    final val = mat[width - 1][i];
    if (val < min) {
      min = val;
      y = i;
    }
  }

  return y;
}

Seam _findLowestCostSeam(CostMatrix mat) {
  int width = mat.length;
  int height = mat[0].length;
  final seam = List.filled(width, Point(0, 0));
  var y = _findMinimumBottomIndex(mat);

  seam[width - 1] = Point(width - 1, y);
  for (int x = width - 2; x >= 0; x--) {
    final left = mat[x][y];
    var up = double.maxFinite, down = double.maxFinite;

    if (y > 0) {
      up = mat[x][y - 1];
    }

    if (y < height - 1) {
      down = mat[x][y + 1];
    }

    if (up <= left && up <= down) {
      seam[x] = Point(x, y - 1);
      y = y - 1;
    } else if (left <= up && left <= down) {
      seam[x] = Point(x, y);
    } else {
      seam[x] = Point(x, y + 1);
      y = y + 1;
    }
  }

  return seam;
}

double _getInitialEnergy(Image im, int x, int y) {
  final pixel = im.getPixel(x, y);
  return pixel.r / pixel.a;
}
