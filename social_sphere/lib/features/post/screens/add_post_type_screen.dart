// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:social_sphere/core/common/error_text.dart';
// import 'package:social_sphere/core/common/loader.dart';
// import 'package:social_sphere/core/utils.dart';
// import 'package:social_sphere/features/community/controller/community_controller.dart';
// import 'package:social_sphere/features/post/controller/post_controller.dart';
// import 'package:social_sphere/models/community_model.dart';
// import 'package:social_sphere/theme/pallete.dart';

// class AddPostTypeScreen extends ConsumerStatefulWidget {
//   final String type;
//   const AddPostTypeScreen({super.key, required this.type});

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() =>
//       _AddPostTypeScreenState();
// }

// class _AddPostTypeScreenState extends ConsumerState<AddPostTypeScreen> {
//   final titleController = TextEditingController();
//   final descriptionController = TextEditingController();
//   final linkController = TextEditingController();
//   File? bannerFile;
//   Uint8List? bannerWebFile;
//   List<Community> communities = [];
//   Community? selectedCommunity;
//   final ImagePicker _picker = ImagePicker();

//   @override
//   void dispose() {
//     super.dispose();
//     titleController.dispose();
//     descriptionController.dispose();
//     linkController.dispose();
//   }

//   Future<void> selectBannerImage() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       if (kIsWeb) {
//         final bytes = await pickedFile.readAsBytes();
//         setState(() {
//           bannerWebFile = bytes;
//         });
//       } else {
//         setState(() {
//           bannerFile = File(pickedFile.path);
//         });
//       }
//     }
//   }

//   Future<void> selectBannerVideo() async {
//     final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       if (kIsWeb) {
//         final bytes = await pickedFile.readAsBytes();
//         setState(() {
//           bannerWebFile = bytes;
//         });
//       } else {
//         setState(() {
//           bannerFile = File(pickedFile.path);
//         });
//       }
//     }
//   }

//   void sharePost() {
//     if ((widget.type == 'image' || widget.type == 'video') &&
//         (bannerFile != null || bannerWebFile != null) &&
//         titleController.text.isNotEmpty) {
//       if (widget.type == 'video') {
//         ref
//             .read(postControllerProvider.notifier)
//             .shareVideoPost(
//               context: context,
//               title: titleController.text.trim(),
//               selectedCommunity: selectedCommunity ?? communities[0],
//               file: bannerFile,
//               webFile: bannerWebFile,
//             );
//       } else {
//         ref
//             .read(postControllerProvider.notifier)
//             .shareImagePost(
//               context: context,
//               title: titleController.text.trim(),
//               selectedCommunity: selectedCommunity ?? communities[0],
//               file: bannerFile,
//               webFile: bannerWebFile,
//             );
//       }
//     } else if (widget.type == 'text' && titleController.text.isNotEmpty) {
//       ref
//           .read(postControllerProvider.notifier)
//           .shareTextPost(
//             context: context,
//             title: titleController.text.trim(),
//             selectedCommunity: selectedCommunity ?? communities[0],
//             description: descriptionController.text.trim(),
//           );
//     } else if (widget.type == 'link' &&
//         titleController.text.isNotEmpty &&
//         linkController.text.isNotEmpty) {
//       ref
//           .read(postControllerProvider.notifier)
//           .shareLinkPost(
//             context: context,
//             title: titleController.text.trim(),
//             selectedCommunity: selectedCommunity ?? communities[0],
//             link: linkController.text.trim(),
//           );
//     } else {
//       showSnackBar(context, 'Please fill all required fields');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isTypeMedia = widget.type == 'image' || widget.type == 'video';
//     final isTypeText = widget.type == 'text';
//     final isTypeLink = widget.type == 'link';
//     final currentTheme = ref.watch(themeNotifierProvider);
//     final isLoading = ref.watch(postControllerProvider);
//     final bool isDark = currentTheme.brightness == Brightness.dark;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Create ${widget.type} Post',
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: 12),
//             child: ElevatedButton(
//               onPressed: sharePost,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                   vertical: 10,
//                 ),
//               ),
//               child: const Text('Post', style: TextStyle(color: Colors.white)),
//             ),
//           ),
//         ],
//       ),
//       body:
//           isLoading
//               ? const Loader()
//               : SingleChildScrollView(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Post to',
//                         style: TextStyle(
//                           fontSize: 16,
//                           color:
//                               isDark
//                                   ? Colors.grey.shade400
//                                   : Colors.grey.shade600,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       _buildCommunitySelector(currentTheme),
//                       const SizedBox(height: 24),
//                       TextField(
//                         controller: titleController,
//                         decoration: InputDecoration(
//                           filled: true,
//                           fillColor:
//                               isDark
//                                   ? Colors.grey.shade900
//                                   : Colors.grey.shade100,
//                           hintText: 'Add a title...',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: const BorderSide(color: Colors.grey),
//                           ),
//                           contentPadding: const EdgeInsets.all(16),
//                         ),
//                         style: const TextStyle(fontSize: 18),
//                         maxLength: 30,
//                       ),
//                       const SizedBox(height: 20),
//                       if (isTypeMedia) _buildMediaUploadSection(currentTheme),
//                       if (isTypeText) _buildDescriptionField(currentTheme),
//                       if (isTypeLink) _buildLinkField(currentTheme),
//                     ],
//                   ),
//                 ),
//               ),
//     );
//   }

//   Widget _buildCommunitySelector(ThemeData theme) {
//     final currentTheme = ref.watch(themeNotifierProvider);
//     final bool isDark = currentTheme.brightness == Brightness.dark;

//     return Container(
//       decoration: BoxDecoration(
//         color:
//             isDark
//                 ? Colors.grey.shade900
//                 : const Color.fromARGB(245, 245, 245, 245),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey),
//       ),
//       child: ref
//           .watch(userCommunitiesProvider)
//           .when(
//             data: (data) {
//               communities = data;
//               if (data.isEmpty) {
//                 return const Padding(
//                   padding: EdgeInsets.all(16),
//                   child: Text('No communities available'),
//                 );
//               }
//               return Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 12),
//                 child: DropdownButtonHideUnderline(
//                   child: DropdownButton<Community>(
//                     value: selectedCommunity ?? data[0],
//                     isExpanded: true,
//                     icon: Icon(
//                       Icons.arrow_drop_down,
//                       color: theme.iconTheme.color,
//                     ),
//                     items:
//                         data
//                             .map(
//                               (community) => DropdownMenuItem<Community>(
//                                 value: community,
//                                 child: Row(
//                                   children: [
//                                     CircleAvatar(
//                                       backgroundImage: NetworkImage(
//                                         community.avatar,
//                                       ),
//                                       radius: 16,
//                                     ),
//                                     const SizedBox(width: 12),
//                                     Text(
//                                       community.name,
//                                       style: TextStyle(
//                                         color: theme.textTheme.bodyLarge?.color,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             )
//                             .toList(),
//                     onChanged: (community) {
//                       setState(() {
//                         selectedCommunity = community;
//                       });
//                     },
//                   ),
//                 ),
//               );
//             },
//             error: (error, stackTrace) => ErrorText(error: error.toString()),
//             loading:
//                 () =>
//                     const Padding(padding: EdgeInsets.all(16), child: Loader()),
//           ),
//     );
//   }

//   Widget _buildMediaUploadSection(ThemeData theme) {
//     final currentTheme = ref.watch(themeNotifierProvider);
//     final bool isDark = currentTheme.brightness == Brightness.dark;
//     final isVideo = widget.type == 'video';

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           isVideo ? 'Add video' : 'Add image',
//           style: TextStyle(
//             fontSize: 16,
//             color: theme.textTheme.bodyLarge?.color,
//           ),
//         ),
//         const SizedBox(height: 8),
//         GestureDetector(
//           onTap: isVideo ? selectBannerVideo : selectBannerImage,
//           child: Container(
//             width: double.infinity,
//             height: 200,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12),
//               color:
//                   isDark
//                       ? Colors.grey.shade900
//                       : const Color.fromARGB(245, 245, 245, 245),
//               border: Border.all(color: Colors.grey),
//             ),
//             child:
//                 bannerWebFile != null
//                     ? ClipRRect(
//                       borderRadius: BorderRadius.circular(12),
//                       child: Image.memory(bannerWebFile!, fit: BoxFit.cover),
//                     )
//                     : bannerFile != null
//                     ? ClipRRect(
//                       borderRadius: BorderRadius.circular(12),
//                       child: Image.file(bannerFile!, fit: BoxFit.cover),
//                     )
//                     : Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           isVideo
//                               ? Icons.videocam_outlined
//                               : Icons.image_outlined,
//                           size: 40,
//                           color: theme.iconTheme.color,
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           isVideo
//                               ? 'Tap to upload a video'
//                               : 'Tap to upload an image',
//                           style: TextStyle(color: theme.iconTheme.color),
//                         ),
//                       ],
//                     ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDescriptionField(ThemeData theme) {
//     final currentTheme = ref.watch(themeNotifierProvider);
//     final bool isDark = currentTheme.brightness == Brightness.dark;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Description',
//           style: TextStyle(
//             fontSize: 16,
//             color: theme.textTheme.bodyLarge?.color,
//           ),
//         ),
//         const SizedBox(height: 8),
//         TextField(
//           controller: descriptionController,
//           decoration: InputDecoration(
//             filled: true,
//             fillColor:
//                 isDark
//                     ? Colors.grey.shade900
//                     : const Color.fromARGB(245, 245, 245, 245),
//             hintText: 'What are your thoughts?',
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: const BorderSide(color: Colors.grey),
//             ),
//             contentPadding: const EdgeInsets.all(16),
//           ),
//           maxLines: 8,
//           style: const TextStyle(fontSize: 16),
//         ),
//       ],
//     );
//   }

//   Widget _buildLinkField(ThemeData theme) {
//     final currentTheme = ref.watch(themeNotifierProvider);
//     final bool isDark = currentTheme.brightness == Brightness.dark;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Link URL',
//           style: TextStyle(
//             fontSize: 16,
//             color: theme.textTheme.bodyLarge?.color,
//           ),
//         ),
//         const SizedBox(height: 8),
//         TextField(
//           controller: linkController,
//           decoration: InputDecoration(
//             filled: true,
//             fillColor:
//                 isDark
//                     ? Colors.grey.shade900
//                     : const Color.fromARGB(245, 245, 245, 245),
//             hintText: 'https://example.com',
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: const BorderSide(color: Colors.grey),
//             ),
//             contentPadding: const EdgeInsets.all(16),
//             prefixIcon: Icon(Icons.link, color: theme.iconTheme.color),
//           ),
//           style: const TextStyle(fontSize: 16),
//         ),
//       ],
//     );
//   }
// }

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
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddPostTypeScreenState();
}

class _AddPostTypeScreenState extends ConsumerState<AddPostTypeScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final linkController = TextEditingController();
  File? bannerFile;
  Uint8List? bannerWebFile;
  Uint8List? videoThumbnail; // Added for video thumbnails
  List<Community> communities = [];
  Community? selectedCommunity;
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
        setState(() {
          bannerWebFile = bytes;
        });
      } else {
        setState(() {
          bannerFile = File(pickedFile.path);
        });
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
        // Generate video thumbnail
        final thumbnail = await VideoThumbnail.thumbnailFile(
          video: pickedFile.path,
          imageFormat: ImageFormat.JPEG,
          maxHeight: 200,
          quality: 25,
        );
        if (thumbnail != null) {
          final bytes = await File(thumbnail).readAsBytes();
          setState(() {
            videoThumbnail = bytes;
          });
        }
      }
    }
  }

  void sharePost() {
    if ((widget.type == 'image' || widget.type == 'video') &&
        (bannerFile != null || bannerWebFile != null) &&
        titleController.text.isNotEmpty) {
      if (widget.type == 'video') {
        ref
            .read(postControllerProvider.notifier)
            .shareVideoPost(
              context: context,
              title: titleController.text.trim(),
              selectedCommunity: selectedCommunity ?? communities[0],
              file: bannerFile,
              webFile: bannerWebFile,
            );
      } else {
        ref
            .read(postControllerProvider.notifier)
            .shareImagePost(
              context: context,
              title: titleController.text.trim(),
              selectedCommunity: selectedCommunity ?? communities[0],
              file: bannerFile,
              webFile: bannerWebFile,
            );
      }
    } else if (widget.type == 'text' && titleController.text.isNotEmpty) {
      ref
          .read(postControllerProvider.notifier)
          .shareTextPost(
            context: context,
            title: titleController.text.trim(),
            selectedCommunity: selectedCommunity ?? communities[0],
            description: descriptionController.text.trim(),
          );
    } else if (widget.type == 'link' &&
        titleController.text.isNotEmpty &&
        linkController.text.isNotEmpty) {
      ref
          .read(postControllerProvider.notifier)
          .shareLinkPost(
            context: context,
            title: titleController.text.trim(),
            selectedCommunity: selectedCommunity ?? communities[0],
            link: linkController.text.trim(),
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
    final bool isDark = currentTheme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create ${widget.type} Post',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: sharePost,
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
              child: const Text('Post', style: TextStyle(color: Colors.white)),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Post to',
                        style: TextStyle(
                          fontSize: 16,
                          color:
                              isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildCommunitySelector(currentTheme),
                      const SizedBox(height: 24),
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor:
                              isDark
                                  ? Colors.grey.shade900
                                  : Colors.grey.shade100,
                          hintText: 'Add a title...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        style: const TextStyle(fontSize: 18),
                        maxLength: 30,
                      ),
                      const SizedBox(height: 20),
                      if (isTypeMedia) _buildMediaUploadSection(currentTheme),
                      if (isTypeText) _buildDescriptionField(currentTheme),
                      if (isTypeLink) _buildLinkField(currentTheme),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildCommunitySelector(ThemeData theme) {
    final currentTheme = ref.watch(themeNotifierProvider);
    final bool isDark = currentTheme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color:
            isDark
                ? Colors.grey.shade900
                : const Color.fromARGB(245, 245, 245, 245),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey),
      ),
      child: ref
          .watch(userCommunitiesProvider)
          .when(
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
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: theme.iconTheme.color,
                    ),
                    items:
                        data
                            .map(
                              (community) => DropdownMenuItem<Community>(
                                value: community,
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        community.avatar,
                                      ),
                                      radius: 16,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      community.name,
                                      style: TextStyle(
                                        color: theme.textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (community) {
                      setState(() {
                        selectedCommunity = community;
                      });
                    },
                  ),
                ),
              );
            },
            error: (error, stackTrace) => ErrorText(error: error.toString()),
            loading:
                () =>
                    const Padding(padding: EdgeInsets.all(16), child: Loader()),
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
              color:
                  theme.brightness == Brightness.dark
                      ? Colors.grey.shade900
                      : const Color.fromARGB(245, 245, 245, 245),
              border: Border.all(color: Colors.grey),
            ),
            child:
                isVideo ? _buildVideoPreview(theme) : _buildImagePreview(theme),
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
    if (bannerFile != null) {
      return _buildPlaceholder(theme, isVideo: true);
    }
    return _buildPlaceholder(theme, isVideo: true);
  }

  Widget _buildImagePreview(ThemeData theme) {
    return bannerWebFile != null
        ? ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(bannerWebFile!, fit: BoxFit.cover),
        )
        : bannerFile != null
        ? ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(bannerFile!, fit: BoxFit.cover),
        )
        : _buildPlaceholder(theme);
  }

  Widget _buildPlaceholder(ThemeData theme, {bool isVideo = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          isVideo ? Icons.videocam_outlined : Icons.image_outlined,
          size: 40,
          color: theme.iconTheme.color,
        ),
        const SizedBox(height: 16),
        Text(
          isVideo ? 'Tap to upload a video' : 'Tap to upload an image',
          style: TextStyle(color: theme.iconTheme.color),
        ),
      ],
    );
  }

  Widget _buildLinkField(ThemeData theme) {
    final currentTheme = ref.watch(themeNotifierProvider);
    final bool isDark = currentTheme.brightness == Brightness.dark;

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
            fillColor:
                isDark
                    ? Colors.grey.shade900
                    : const Color.fromARGB(245, 245, 245, 245),
            hintText: 'https://example.com',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
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
    final currentTheme = ref.watch(themeNotifierProvider);
    final bool isDark = currentTheme.brightness == Brightness.dark;

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
            fillColor:
                isDark
                    ? Colors.grey.shade900
                    : const Color.fromARGB(245, 245, 245, 245),
            hintText: 'What are your thoughts?',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          maxLines: 8,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  // ... Keep _buildDescriptionField and _buildLinkField unchanged ...
}
