import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_sphere/main.dart';

void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}

void showSnackBar2(String text) {
  scaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(content: Text(text), duration: const Duration(seconds: 2)),
  );
}

final ImagePicker _picker = ImagePicker();

Future<XFile?> pickImage() async {
  final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
  return image;
}

Future<XFile?> pickVideo() async {
  final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
  return video;
}
