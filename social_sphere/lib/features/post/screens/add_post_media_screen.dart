// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:video_thumbnail/video_thumbnail.dart';
// import 'package:social_sphere/core/common/error_text.dart';
// import 'package:social_sphere/core/common/loader.dart';
// import 'package:social_sphere/core/utils.dart';
// import 'package:social_sphere/features/community/controller/community_controller.dart';
// import 'package:social_sphere/features/post/controller/post_controller.dart';
// import 'package:social_sphere/models/community_model.dart';
// import 'package:social_sphere/models/post_model.dart';
// import 'package:social_sphere/theme/pallete.dart';

// class AddPostMediaScreen extends ConsumerStatefulWidget {
//   const AddPostMediaScreen({super.key});

//   @override
//   ConsumerState<AddPostMediaScreen> createState() => _AddPostMediaScreenState();
// }

// class _AddPostMediaScreenState extends ConsumerState<AddPostMediaScreen> {
//   final titleController = TextEditingController();
//   List<File> files = [];
//   List<Uint8List> webFiles = [];
//   List<MediaType> mediaTypes = [];
//   List<Uint8List?> thumbnails = [];
//   List<Community> communities = [];
//   Community? selectedCommunity;
//   bool isAnonymous = false;

//   @override
//   void dispose() {
//     titleController.dispose();
//     super.dispose();
//   }

//   Future<void> pickMedia() async {
//     final result = await FilePicker.platform.pickFiles(
//       allowMultiple: true,
//       type: FileType.media,
//       allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4', 'mov'],
//     );

//     if (result != null) {
//       if (kIsWeb) {
//         webFiles = result.files.map((f) => f.bytes!).toList();
//         mediaTypes =
//             result.files.map((f) {
//               return f.extension == 'mp4' || f.extension == 'mov'
//                   ? MediaType.video
//                   : MediaType.image;
//             }).toList();
//       } else {
//         files = result.paths.map((path) => File(path!)).toList();
//         mediaTypes =
//             result.files.map((f) {
//               return f.extension == 'mp4' || f.extension == 'mov'
//                   ? MediaType.video
//                   : MediaType.image;
//             }).toList();

//         // Generate thumbnails for videos
//         thumbnails = await Future.wait(
//           files.map((file) async {
//             final index = files.indexOf(file);
//             if (mediaTypes[index] == MediaType.video) {
//               final thumbnail = await VideoThumbnail.thumbnailFile(
//                 video: file.path,
//                 imageFormat: ImageFormat.JPEG,
//                 maxHeight: 200,
//                 quality: 25,
//               );
//               return thumbnail != null
//                   ? await File(thumbnail).readAsBytes()
//                   : null;
//             }
//             return null;
//           }),
//         );
//       }
//       setState(() {});
//     }
//   }

//   void sharePost() {
//     if ((files.isNotEmpty || webFiles.isNotEmpty) &&
//         titleController.text.isNotEmpty) {
//       ref
//           .read(postControllerProvider.notifier)
//           .shareMediaPost(
//             context: context,
//             title: titleController.text.trim(),
//             selectedCommunity: selectedCommunity ?? communities[0],
//             files: files,
//             webFiles: webFiles,
//             mediaTypes: mediaTypes,
//             isAnonymous: isAnonymous,
//           );
//     } else {
//       showSnackBar(context, 'Please add media and a title');
//     }
//   }

//   void removeMedia(int index) {
//     setState(() {
//       if (kIsWeb) {
//         webFiles.removeAt(index);
//       } else {
//         files.removeAt(index);
//       }
//       mediaTypes.removeAt(index);
//       if (thumbnails.length > index) {
//         thumbnails.removeAt(index);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final currentTheme = ref.watch(themeNotifierProvider);
//     final isLoading = ref.watch(postControllerProvider);
//     final bool isDark = currentTheme.brightness == Brightness.dark;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Create Media Post'),
//         actions: [TextButton(onPressed: sharePost, child: const Text('Post'))],
//       ),
//       body:
//           isLoading
//               ? const Loader()
//               : Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   children: [
//                     // Community selector
//                     Container(
//                       decoration: BoxDecoration(
//                         color:
//                             isDark
//                                 ? Colors.grey.shade900
//                                 : const Color.fromARGB(245, 245, 245, 245),
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: Colors.grey),
//                       ),
//                       child: ref
//                           .watch(userCommunitiesProvider)
//                           .when(
//                             data: (data) {
//                               communities = data;
//                               if (data.isEmpty) {
//                                 return const Padding(
//                                   padding: EdgeInsets.all(16),
//                                   child: Text('No communities available'),
//                                 );
//                               }
//                               return Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 12,
//                                 ),
//                                 child: DropdownButtonHideUnderline(
//                                   child: DropdownButton<Community>(
//                                     value: selectedCommunity ?? data[0],
//                                     isExpanded: true,
//                                     icon: Icon(
//                                       Icons.arrow_drop_down,
//                                       color: currentTheme.iconTheme.color,
//                                     ),
//                                     items:
//                                         data
//                                             .map(
//                                               (
//                                                 community,
//                                               ) => DropdownMenuItem<Community>(
//                                                 value: community,
//                                                 child: Row(
//                                                   children: [
//                                                     CircleAvatar(
//                                                       backgroundImage:
//                                                           NetworkImage(
//                                                             community.avatar,
//                                                           ),
//                                                       radius: 16,
//                                                     ),
//                                                     const SizedBox(width: 12),
//                                                     Text(
//                                                       community.name,
//                                                       style: TextStyle(
//                                                         color:
//                                                             currentTheme
//                                                                 .textTheme
//                                                                 .bodyLarge
//                                                                 ?.color,
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             )
//                                             .toList(),
//                                     onChanged: (community) {
//                                       setState(() {
//                                         selectedCommunity = community;
//                                       });
//                                     },
//                                   ),
//                                 ),
//                               );
//                             },
//                             error:
//                                 (error, stackTrace) =>
//                                     ErrorText(error: error.toString()),
//                             loading:
//                                 () => const Padding(
//                                   padding: EdgeInsets.all(16),
//                                   child: Loader(),
//                                 ),
//                           ),
//                     ),
//                     const SizedBox(height: 16),

//                     // Title field
//                     TextField(
//                       controller: titleController,
//                       decoration: InputDecoration(
//                         filled: true,
//                         fillColor:
//                             isDark
//                                 ? Colors.grey.shade900
//                                 : Colors.grey.shade100,
//                         hintText: 'Add a title...',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: const BorderSide(color: Colors.grey),
//                         ),
//                         contentPadding: const EdgeInsets.all(16),
//                       ),
//                       style: const TextStyle(fontSize: 18),
//                       maxLength: 30,
//                     ),
//                     const SizedBox(height: 16),

//                     // Anonymous toggle
//                     SwitchListTile(
//                       title: Text(
//                         'Post Anonymously',
//                         style: TextStyle(
//                           color: isDark ? Colors.white : Colors.black,
//                         ),
//                       ),
//                       value: isAnonymous,
//                       activeColor: Pallete.blueColor,
//                       onChanged: (value) => setState(() => isAnonymous = value),
//                     ),
//                     const SizedBox(height: 16),

//                     // Media grid
//                     Expanded(
//                       child: GridView.builder(
//                         gridDelegate:
//                             const SliverGridDelegateWithFixedCrossAxisCount(
//                               crossAxisCount: 3,
//                               crossAxisSpacing: 8,
//                               mainAxisSpacing: 8,
//                             ),
//                         itemCount:
//                             (kIsWeb ? webFiles.length : files.length) + 1,
//                         itemBuilder: (context, index) {
//                           if (index == 0) {
//                             return GestureDetector(
//                               onTap: pickMedia,
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   border: Border.all(color: Colors.grey),
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 child: const Icon(Icons.add, size: 40),
//                               ),
//                             );
//                           }
//                           final mediaIndex = index - 1;
//                           return Stack(
//                             children: [
//                               // Media thumbnail
//                               Container(
//                                 decoration: BoxDecoration(
//                                   border: Border.all(color: Colors.grey),
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 child:
//                                     mediaTypes[mediaIndex] == MediaType.image
//                                         ? kIsWeb
//                                             ? Image.memory(
//                                               webFiles[mediaIndex],
//                                               fit: BoxFit.cover,
//                                             )
//                                             : Image.file(
//                                               files[mediaIndex],
//                                               fit: BoxFit.cover,
//                                             )
//                                         : thumbnails.length > mediaIndex &&
//                                             thumbnails[mediaIndex] != null
//                                         ? Image.memory(
//                                           thumbnails[mediaIndex]!,
//                                           fit: BoxFit.cover,
//                                         )
//                                         : const Center(
//                                           child: Icon(Icons.videocam),
//                                         ),
//                               ),

//                               // Remove button
//                               Positioned(
//                                 top: 4,
//                                 right: 4,
//                                 child: GestureDetector(
//                                   onTap: () => removeMedia(mediaIndex),
//                                   child: Container(
//                                     padding: const EdgeInsets.all(4),
//                                     decoration: BoxDecoration(
//                                       color: Colors.black54,
//                                       shape: BoxShape.circle,
//                                     ),
//                                     child: const Icon(
//                                       Icons.close,
//                                       size: 16,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ),

//                               // Video indicator
//                               if (mediaTypes[mediaIndex] == MediaType.video)
//                                 const Positioned(
//                                   bottom: 4,
//                                   right: 4,
//                                   child: Icon(
//                                     Icons.videocam,
//                                     color: Colors.white,
//                                     size: 20,
//                                   ),
//                                 ),
//                             ],
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//     );
//   }
// }
