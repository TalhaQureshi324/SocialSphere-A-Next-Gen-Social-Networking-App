import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_sphere/core/common/error_text.dart';
import 'package:social_sphere/core/common/loader.dart';
import 'package:social_sphere/core/constants/constants.dart';
import 'package:social_sphere/features/community/controller/community_controller.dart';
import 'package:social_sphere/models/community_model.dart';
//import 'package:social_sphere/responsive/responsive.dart';
import 'package:social_sphere/theme/pallete.dart';

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
  Uint8List? bannerWebFile;
  Uint8List? profileWebFile;
  final ImagePicker _picker = ImagePicker();

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

  void save(Community community) {
    ref
        .read(communityControllerProvider.notifier)
        .editCommunity(
          profileFile: profileFile,
          bannerFile: bannerFile,
          context: context,
          community: community,
          profileWebFile: profileWebFile,
          bannerWebFile: bannerWebFile,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communityControllerProvider);
    final currentTheme = ref.watch(themeNotifierProvider);
    final isDark = currentTheme.brightness == Brightness.dark;

    return ref
        .watch(getCommunityByNameProvider(widget.name))
        .when(
          data:
              (community) => Scaffold(
                backgroundColor: currentTheme.scaffoldBackgroundColor,
                appBar: AppBar(
                  title: const Text(
                    'Edit Group',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  centerTitle: true,
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: ElevatedButton(
                        onPressed: () => save(community),
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
                                    Container(
                                      height: 180,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color:
                                            isDark
                                                ? Colors.grey.shade800
                                                : Colors.grey.shade200,
                                      ),
                                      child: _buildBannerImage(community),
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
                                const SizedBox(height: 20),

                                // Profile Image Section
                                Center(
                                  child: Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: currentTheme.cardColor,
                                            width: 3,
                                          ),
                                        ),
                                        child: CircleAvatar(
                                          radius: 50,
                                          backgroundColor:
                                              isDark
                                                  ? Colors.grey.shade800
                                                  : Colors.grey.shade200,
                                          backgroundImage: _buildProfileImage(
                                            community,
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
                                const SizedBox(height: 30),

                                // Community Info Section
                                Container(
                                  width: double.infinity, // Full width

                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color:
                                        isDark
                                            ? Colors.grey.shade800
                                            : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Group Details',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              currentTheme
                                                  .textTheme
                                                  .titleLarge
                                                  ?.color,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        '${community.name}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color:
                                              currentTheme
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.color,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${community.members.length} members',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color:
                                              isDark
                                                  ? Colors.grey.shade400
                                                  : Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
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

  Widget? _buildBannerImage(Community community) {
    if (bannerWebFile != null) {
      return Image.memory(bannerWebFile!, fit: BoxFit.cover);
    }
    if (bannerFile != null) {
      return Image.file(bannerFile!, fit: BoxFit.cover);
    }
    if (community.banner.isNotEmpty &&
        community.banner != Constants.bannerDefault) {
      return Image.network(community.banner, fit: BoxFit.cover);
    }

    return const Center(child: Icon(Icons.camera_alt_outlined, size: 40));
  }

  ImageProvider? _buildProfileImage(Community community) {
    if (profileWebFile != null) return MemoryImage(profileWebFile!);
    if (profileFile != null) return FileImage(profileFile!);
    return NetworkImage(community.avatar);
  }
}
