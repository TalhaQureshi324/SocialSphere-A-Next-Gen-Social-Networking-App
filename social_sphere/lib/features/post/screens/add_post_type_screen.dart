import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart'; // Added package
import 'package:social_sphere/core/common/error_text.dart';
import 'package:social_sphere/core/common/loader.dart';
import 'package:social_sphere/core/utils.dart';
import 'package:social_sphere/features/community/controller/community_controller.dart';
import 'package:social_sphere/features/post/controller/post_controller.dart';
import 'package:social_sphere/models/community_model.dart';
import 'package:social_sphere/theme/pallete.dart';

class AddPostTypeScreen extends ConsumerStatefulWidget {
  final String type;
  const AddPostTypeScreen({super.key, required this.type});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddPostTypeScreenState();
}

class _AddPostTypeScreenState extends ConsumerState<AddPostTypeScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final linkController = TextEditingController();
  File? bannerFile;
  Uint8List? bannerWebFile;
  Uint8List? videoThumbnail;
  List<Community> communities = [];
  Community? selectedCommunity;
  bool isAnonymous = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    descriptionController.dispose();
    linkController.dispose();
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

  Future<void> selectBannerVideo() async {
    final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          bannerWebFile = bytes;
          videoThumbnail = null;
        });
      } else {
        setState(() {
          bannerFile = File(pickedFile.path);
          videoThumbnail = null;
        });
        final thumbnail = await VideoThumbnail.thumbnailFile(
          video: pickedFile.path,
          imageFormat: ImageFormat.JPEG,
          maxHeight: 200,
          quality: 25,
        );
        if (thumbnail != null) {
          final bytes = await File(thumbnail).readAsBytes();
          setState(() => videoThumbnail = bytes);
        }
      }
    }
  }

  void sharePost() {
    if ((widget.type == 'image' || widget.type == 'video') &&
        (bannerFile != null || bannerWebFile != null) &&
        titleController.text.isNotEmpty) {
      ref.read(postControllerProvider.notifier).shareVideoPost(
        context: context,
        title: titleController.text.trim(),
        selectedCommunity: selectedCommunity ?? communities[0],
        file: bannerFile,
        webFile: bannerWebFile,
        isAnonymous: isAnonymous,
      );
    } else if (widget.type == 'text' && titleController.text.isNotEmpty) {
      ref.read(postControllerProvider.notifier).shareTextPost(
        context: context,
        title: titleController.text.trim(),
        selectedCommunity: selectedCommunity ?? communities[0],
        description: descriptionController.text.trim(),
        isAnonymous: isAnonymous,
      );
    } else if (widget.type == 'link' &&
        titleController.text.isNotEmpty &&
        linkController.text.isNotEmpty) {
      ref.read(postControllerProvider.notifier).shareLinkPost(
        context: context,
        title: titleController.text.trim(),
        selectedCommunity: selectedCommunity ?? communities[0],
        link: linkController.text.trim(),
        isAnonymous: isAnonymous,
      );
    } else {
      showSnackBar(context, 'Please fill all required fields');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTypeMedia = widget.type == 'image' || widget.type == 'video';
    final isTypeText = widget.type == 'text';
    final isTypeLink = widget.type == 'link';
    final currentTheme = ref.watch(themeNotifierProvider);
    final isLoading = ref.watch(postControllerProvider);
    final isDark = currentTheme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Create ${widget.type} Post',
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

                    // Content Section
                    const SizedBox(height: 20),
                    if (isTypeMedia) _buildMediaUploadSection(currentTheme),
                    if (isTypeText) _buildDescriptionField(currentTheme),
                    if (isTypeLink) _buildLinkField(currentTheme),
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

  Widget _buildMediaUploadSection(ThemeData theme) {
    final isVideo = widget.type == 'video';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isVideo ? 'Add video' : 'Add image',
          style: TextStyle(
            fontSize: 16,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: isVideo ? selectBannerVideo : selectBannerImage,
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: theme.brightness == Brightness.dark
                  ? Colors.grey.shade900
                  : Colors.grey.shade100,
            ),
            child: isVideo ? _buildVideoPreview(theme) : _buildImagePreview(theme),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPreview(ThemeData theme) {
    if (kIsWeb) {
      return _buildPlaceholder(theme, isVideo: true);
    }
    if (videoThumbnail != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(videoThumbnail!, fit: BoxFit.cover),
      );
    }
    return _buildPlaceholder(theme, isVideo: true);
  }

  Widget _buildImagePreview(ThemeData theme) {
    if (bannerWebFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(bannerWebFile!, fit: BoxFit.cover),
      );
    }
    if (bannerFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(bannerFile!, fit: BoxFit.cover),
      );
    }
    return _buildPlaceholder(theme);
  }

  Widget _buildPlaceholder(ThemeData theme, {bool isVideo = false}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isVideo ? Icons.video_library_outlined : Icons.photo_library_outlined,
            size: 40,
            color: theme.iconTheme.color?.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            isVideo ? 'Tap to upload a video' : 'Tap to upload an image',
            style: TextStyle(
              color: theme.iconTheme.color?.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkField(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Link URL',
          style: TextStyle(
            fontSize: 16,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: linkController,
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
            hintText: 'https://example.com',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
            prefixIcon: Icon(Icons.link, color: theme.iconTheme.color),
          ),
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildDescriptionField(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: TextStyle(
            fontSize: 16,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: descriptionController,
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
            hintText: 'What are your thoughts?',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          maxLines: 8,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}