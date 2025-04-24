import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}

final ImagePicker _picker = ImagePicker();

Future<XFile?> pickImage() async {
  final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
  return image;
}
