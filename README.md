# Seam carver Library

## Overview

This Dart library provides functionality to reduce the dimensions of images using seam carving techniques.

## Features

- **Image Reduction**: Reduce image dimensions (height or width) while preserving important content using seam carving.
- **Supported Formats**: Supports JPEG, PNG, GIF, BMP, TIFF, and WebP image formats.

## Installation

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  seam_carver_dart:
    git:
      url: git://github.com/ArtAhmetaj/seam_carver_dart.git
```


## Usage

### Example 1: Reduce image from file path

```dart
import 'dart:typed_data';
import 'package:seam_carver_dart/seam_carver_dart.dart';

void main() async {
  try {
    final options = ReduceOptions(dimension: Dimension.height, amount: 50);
    final reducedBytes = await reduceImageFromPath('path_to_your_image.jpg', options: options);
    // Use reducedBytes as needed
  } catch (e) {
    print('Error reducing image: $e');
  }
}
```

### Example 2: Reduce image from bytes

```dart
import 'dart:typed_data';
import 'package:seam_carver_dart/seam_carver_dart.dart';

void main() {
  try {
    final options = ReduceOptions(dimension: Dimension.width, amount: 30);
    final bytes = // your image bytes
    final reducedBytes = reduceImageFromBytes(bytes, ImageFormat.jpeg, options: options);
    // Use reducedBytes as needed
  } catch (e) {
    print('Error reducing image: $e');
  }
}
```

## License

This library is licensed under the MIT License. See the LICENSE file for details.
