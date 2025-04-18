import 'package:flutter/material.dart';
//import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}

Future<XFile?> pickImage() async {
  final ImagePicker picker = ImagePicker();

  // Pick a single image from gallery
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);

  return image;
}