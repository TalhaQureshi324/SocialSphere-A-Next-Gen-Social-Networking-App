import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_sphere/core/common/loader.dart';
import 'package:social_sphere/core/constants/constants.dart';
import 'package:social_sphere/theme/pallete.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:social_sphere/features/community/controller/community_controller.dart';
import 'package:social_sphere/core/common/error_text.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart'; // ✨ Updated: Added image_picker

class EditCommunityScreen extends ConsumerStatefulWidget {
  final String name;
  const EditCommunityScreen({super.key, required this.name});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditCommunityScreenState();
}

class _EditCommunityScreenState extends ConsumerState<EditCommunityScreen> {
  File? bannerFile;
  File? profileFile;

  final ImagePicker _picker =
      ImagePicker(); // ✨ Added: create ImagePicker instance

  void selectBannerImage() async {
    //final res = await pickImage();
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
    ); // ✨ Updated

    if (image != null) {
      setState(() {
        bannerFile = File(image.path);
      });
    }
  }

  // void selectProfileImage() async {
  //   final res = await pickImage();
  //   if (res != null) {
  //     setState(() {
  //       profileFile = File(res.files.first.path!);
  //     });
  //   }
  // }

  void selectProfileImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
    ); // ✨ Updated
    if (image != null) {
      setState(() {
        profileFile = File(image.path); // ✨ Updated
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ref
        .watch(getCommunityByNameProvider(widget.name))
        .when(
          data:
              (community) => Scaffold(
                backgroundColor:
                    Pallete.darkModeAppTheme.appBarTheme.backgroundColor,
                appBar: AppBar(
                  title: const Text("Edit Community"),
                  centerTitle: false,
                  actions: [
                    TextButton(
                      onPressed: () {
                        // Save changes
                      },
                      child: const Text("Save"),
                    ),
                  ],
                ),
                body: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 200,
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTap: selectBannerImage,
                              child: DottedBorder(
                                borderType: BorderType.RRect,
                                radius: const Radius.circular(10),
                                dashPattern: const [10, 4],
                                strokeCap: StrokeCap.round,
                                color:
                                    Pallete
                                        .darkModeAppTheme
                                        .textTheme
                                        .displayMedium!
                                        .color!,
                                child: Container(
                                  width: double.infinity,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child:
                                      bannerFile != null
                                          ? Image.file(bannerFile!)
                                          : community.banner.isEmpty ||
                                              community.banner ==
                                                  Constants.bannerDefault
                                          ? const Center(
                                            child: Icon(
                                              Icons.camera_alt_outlined,
                                              size: 40,
                                            ),
                                          )
                                          : Image.network(
                                            community.banner,
                                            fit: BoxFit.cover,
                                          ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 20,
                              left: 20,
                              child: GestureDetector(
                                onTap: selectProfileImage,
                                child:
                                    profileFile != null
                                        ? CircleAvatar(
                                          backgroundImage: FileImage(
                                            profileFile!,
                                          ),
                                          radius: 32,
                                        )
                                        : CircleAvatar(
                                          backgroundImage: NetworkImage(
                                            community.avatar,
                                          ),
                                          radius: 32,
                                        ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          loading: () => const Loader(),
          error: (error, stackTrace) => ErrorText(error: error.toString()),
        );
  }
}
