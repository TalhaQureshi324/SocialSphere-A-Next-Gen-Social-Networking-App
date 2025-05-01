import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_sphere/core/common/error_text.dart';
import 'package:social_sphere/core/common/loader.dart';
import 'package:social_sphere/core/constants/constants.dart';
import 'package:social_sphere/features/auth/controller/auth_controller.dart';
import 'package:social_sphere/features/user_profile/controller/user_profile_controller.dart';
import 'package:social_sphere/theme/pallete.dart';
//import 'package:social_sphere/responsive/responsive.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final String uid;
  const EditProfileScreen({super.key, required this.uid});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  File? bannerFile;
  File? profileFile;
  Uint8List? bannerWebFile;
  Uint8List? profileWebFile;
  late TextEditingController nameController;
  late TextEditingController usernameController;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: ref.read(userProvider)!.name);
    usernameController = TextEditingController(
      text: ref.read(userProvider)!.username,
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  Future<void> selectBannerImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() => bannerWebFile = bytes);
      } else {
        setState(() => bannerFile = File(pickedFile.path));
      }
    }
  }

  Future<void> selectProfileImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() => profileWebFile = bytes);
      } else {
        setState(() => profileFile = File(pickedFile.path));
      }
    }
  }

  void save() {
    ref
        .read(userProfileControllerProvider.notifier)
        .editCommunity(
          profileFile: profileFile,
          bannerFile: bannerFile,
          context: context,
          name: nameController.text.trim(),
          username: usernameController.text.trim(),
          bannerWebFile: bannerWebFile,
          profileWebFile: profileWebFile,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(userProfileControllerProvider);
    final currentTheme = ref.watch(themeNotifierProvider);
    final isDark = currentTheme.brightness == Brightness.dark;

    return ref
        .watch(getUserDataProvider(widget.uid))
        .when(
          data:
              (user) => Scaffold(
                backgroundColor:
                    isDark
                        ? const Color.fromARGB(255, 21, 21, 21)
                        : Colors.white,
                appBar: AppBar(
                  title: const Text(
                    'Edit Profile',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  centerTitle: true,
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: ElevatedButton(
                        onPressed: save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                body:
                    isLoading
                        ? const Loader()
                        : SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                // Banner Image Section
                                Stack(
                                  children: [
                                    GestureDetector(
                                      onTap: selectBannerImage,
                                      child: Container(
                                        height: 180,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          color:
                                              isDark
                                                  ? Colors.grey.shade800
                                                  : Colors.grey.shade200,
                                        ),
                                        child: _buildBannerImage(user),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 10,
                                      right: 10,
                                      child: FloatingActionButton.small(
                                        onPressed: selectBannerImage,
                                        backgroundColor: Colors.blue,
                                        child: const Icon(
                                          Icons.edit,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 80),

                                // Profile Image Section
                                Center(
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color:
                                                currentTheme
                                                    .scaffoldBackgroundColor,
                                            width: 4,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.1,
                                              ),
                                              blurRadius: 10,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                        child: CircleAvatar(
                                          radius: 50,
                                          backgroundColor:
                                              isDark
                                                  ? Colors.grey.shade800
                                                  : Colors.grey.shade200,
                                          child: ClipOval(
                                            child: _buildProfileImage(user),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: FloatingActionButton.small(
                                          onPressed: selectProfileImage,
                                          backgroundColor: Colors.blue,
                                          child: const Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 32),

                                // Name Field
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                  ),
                                  child: TextField(
                                    controller: nameController,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor:
                                          isDark
                                              ? Colors.grey.shade900
                                              : Colors.grey.shade100,
                                      hintText: 'Your Name',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: const EdgeInsets.all(16),
                                      prefixIcon: Icon(
                                        Icons.person,
                                        color: currentTheme.iconTheme.color,
                                      ),
                                    ),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                  ),
                                  child: TextField(
                                    controller: usernameController,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor:
                                          isDark
                                              ? Colors.grey.shade900
                                              : Colors.grey.shade100,
                                      hintText: 'Your UserName',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: const EdgeInsets.all(16),
                                      prefixIcon: Icon(
                                        Icons.badge_outlined,
                                        color: currentTheme.iconTheme.color,
                                      ),
                                    ),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
              ),
          loading: () => const Loader(),
          error: (error, stackTrace) => ErrorText(error: error.toString()),
        );
  }

  Widget _buildBannerImage(user) {
    if (bannerWebFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(bannerWebFile!, fit: BoxFit.cover),
      );
    } else if (bannerFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(bannerFile!, fit: BoxFit.cover),
      );
    } else if (user.banner.isEmpty || user.banner == Constants.bannerDefault) {
      return Center(
        child: Icon(
          Icons.camera_alt_outlined,
          size: 40,
          color: Colors.grey.shade500,
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(user.banner, fit: BoxFit.cover),
      );
    }
  }

  Widget _buildProfileImage(user) {
    if (profileWebFile != null) {
      return Image.memory(profileWebFile!, fit: BoxFit.cover);
    } else if (profileFile != null) {
      return Image.file(profileFile!, fit: BoxFit.cover);
    } else {
      return Image.network(user.profilePic, fit: BoxFit.cover);
    }
  }
}
