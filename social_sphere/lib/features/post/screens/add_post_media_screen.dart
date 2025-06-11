import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_sphere/core/common/error_text.dart';
import 'package:social_sphere/core/common/loader.dart';
import 'package:social_sphere/core/utils.dart';
import 'package:social_sphere/features/community/controller/community_controller.dart';
import 'package:social_sphere/features/post/controller/post_controller.dart';
import 'package:social_sphere/models/community_model.dart';
import 'package:social_sphere/theme/pallete.dart';

class AddPostMediaScreen extends ConsumerStatefulWidget {
  final String type;
  const AddPostMediaScreen({super.key, required this.type});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddPostMediaScreenState();
}

class _AddPostMediaScreenState extends ConsumerState<AddPostMediaScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  List<File>? images;
  List<Uint8List>? webImages;
  List<Community> communities = [];
  Community? selectedCommunity;
  bool isAnonymous = false;
  final int maxImageCount = 10;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> selectImages() async {
    final pickedFiles = await _picker.pickMultiImage(
      maxWidth: 2000,
      maxHeight: 2000,
      imageQuality: 85,
    );
    
    if (pickedFiles.isNotEmpty) {
      final remainingSlots = maxImageCount - (images?.length ?? webImages?.length ?? 0);
      final filesToAdd = pickedFiles.length > remainingSlots 
          ? pickedFiles.sublist(0, remainingSlots)
          : pickedFiles;

      if (filesToAdd.isNotEmpty) {
        if (kIsWeb) {
          webImages = [
            ...?webImages,
            ...await Future.wait(filesToAdd.map((file) => file.readAsBytes()))
          ];
        } else {
          images = [
            ...?images,
            ...filesToAdd.map((file) => File(file.path))
          ];
        }
        setState(() {});
      } else {
        showSnackBar(context, 'Maximum $maxImageCount images allowed');
      }
    }
  }

  void removeImage(int index) {
    setState(() {
      if (kIsWeb) {
        webImages?.removeAt(index);
      } else {
        images?.removeAt(index);
      }
    });
  }

  void sharePost() {
    if (titleController.text.trim().isEmpty) {
      showSnackBar(context, 'Please enter a title');
      return;
    }
    if ((images == null || images!.isEmpty) && (webImages == null || webImages!.isEmpty)) {
      showSnackBar(context, 'Please select at least one image');
      return;
    }
    if (selectedCommunity == null) {
      showSnackBar(context, 'Please select a community');
      return;
    }

    ref.read(postControllerProvider.notifier).shareImagePost(
      context: context,
      title: titleController.text.trim(),
      selectedCommunity: selectedCommunity!,
      files: images,
      webFiles: webImages,
      isAnonymous: isAnonymous,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeNotifierProvider);
    final isLoading = ref.watch(postControllerProvider);
    final isDark = currentTheme.brightness == Brightness.dark;
    final mediaCount = images?.length ?? webImages?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Create Image Post',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 80), // Space for bottom button
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Community Selector
                    Text(
                      'Post to',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildCommunitySelector(currentTheme),
                    const SizedBox(height: 24),

                    // Title Field
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                        hintText: 'Add a title...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      style: const TextStyle(fontSize: 18),
                      maxLength: 30,
                    ),

                    // Anonymous Toggle
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: Text(
                        'Post Anonymously',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      value: isAnonymous,
                      activeColor: Pallete.blueColor,
                      onChanged: (value) => setState(() => isAnonymous = value),
                    ),

                    // Image Upload Section
                    const SizedBox(height: 20),
                    _buildImageUploadSection(currentTheme),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Post Button
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade400,
                    Colors.purple.shade600,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: sharePost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Text(
                        'Post',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunitySelector(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ref.watch(userCommunitiesProvider).when(
        data: (data) {
          communities = data;
          if (data.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No communities available'),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Community>(
                value: selectedCommunity ?? data[0],
                isExpanded: true,
                icon: Icon(Icons.arrow_drop_down, color: theme.iconTheme.color),
                items: data.map((community) => DropdownMenuItem<Community>(
                  value: community,
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(community.avatar),
                        radius: 16,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        community.name,
                        style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                      ),
                    ],
                  ),
                )).toList(),
                onChanged: (community) => setState(() => selectedCommunity = community),
              ),
            ),
          );
        },
        error: (error, stackTrace) => ErrorText(error: error.toString()),
        loading: () => const Padding(padding: EdgeInsets.all(16), child: Loader()),
      ),
    );
  }

  Widget _buildImageUploadSection(ThemeData theme) {
    final mediaCount = images?.length ?? webImages?.length ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Add images',
              style: TextStyle(
                fontSize: 16,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            if (mediaCount > 0)
              Text(
                '$mediaCount/$maxImageCount',
                style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (mediaCount > 0) _buildImageGrid(theme),
        GestureDetector(
          onTap: selectImages,
          child: Container(
            width: double.infinity,
            height: mediaCount > 0 ? 120 : 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: theme.brightness == Brightness.dark
                  ? Colors.grey.shade900
                  : Colors.grey.shade100,
              border: Border.all(
                color: theme.dividerColor.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: _buildImagePlaceholder(theme, hasImages: mediaCount > 0),
          ),
        ),
      ],
    );
  }

  Widget _buildImageGrid(ThemeData theme) {
    final mediaCount = images?.length ?? webImages?.length ?? 0;
    final crossAxisCount = mediaCount > 3 ? 3 : mediaCount;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemCount: mediaCount,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: kIsWeb
                    ? Image.memory(
                        webImages![index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      )
                    : Image.file(
                        images![index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => removeImage(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImagePlaceholder(ThemeData theme, {bool hasImages = false}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasImages ? Icons.add_photo_alternate : Icons.photo_library_outlined,
            size: hasImages ? 30 : 40,
            color: theme.iconTheme.color?.withOpacity(0.5),
          ),
          const SizedBox(height: 8),
          Text(
            hasImages ? 'Add more images' : 'Tap to upload images',
            style: TextStyle(
              color: theme.iconTheme.color?.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}