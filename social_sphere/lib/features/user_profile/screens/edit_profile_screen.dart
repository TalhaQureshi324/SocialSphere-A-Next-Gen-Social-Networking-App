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
  final _formKey = GlobalKey<FormState>();
  bool _isEditingName = false;
  bool _isEditingUsername = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider)!;
    nameController = TextEditingController(text: user.name);
    usernameController = TextEditingController(text: user.username);
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
    if (_formKey.currentState!.validate()) {
      ref.read(userProfileControllerProvider.notifier).editCommunity(
        profileFile: profileFile,
        bannerFile: bannerFile,
        context: context,
        name: nameController.text.trim(),
        username: usernameController.text.trim(),
        bannerWebFile: bannerWebFile,
        profileWebFile: profileWebFile,
      );
    }
  }

  void _toggleNameEditing() {
    setState(() {
      _isEditingName = !_isEditingName;
      if (!_isEditingName) {
        // Save logic when done editing
      }
    });
  }

  void _toggleUsernameEditing() {
    setState(() {
      _isEditingUsername = !_isEditingUsername;
      if (!_isEditingUsername) {
        // Save logic when done editing
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(userProfileControllerProvider);
    final currentTheme = ref.watch(themeNotifierProvider);
    final isDark = currentTheme.brightness == Brightness.dark;

    return ref.watch(getUserDataProvider(widget.uid)).when(
      data: (user) => Scaffold(
        backgroundColor: currentTheme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text(
            'Edit Profile',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          iconTheme: IconThemeData(
            color: currentTheme.iconTheme.color,
          ),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Banner Image Section
                    _buildBannerSection(user, isDark),
                    const SizedBox(height: 24),

                    // Profile Image Section
                    _buildProfileSection(user, isDark),
                    const SizedBox(height: 32),

                    // Profile Information Section with editable fields
                    _buildProfileInfoSection(currentTheme),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),

            // Save Button at Bottom
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
                  onPressed: save,
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
                    'Save Changes',
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
      ),
      loading: () => const Loader(),
      error: (error, stackTrace) => ErrorText(error: error.toString()),
    );
  }

  Widget _buildBannerSection(user, bool isDark) {
    return Stack(
      children: [
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildBannerImage(user),
          ),
        ),
        Positioned(
          bottom: 12,
          right: 12,
          child: FloatingActionButton.small(
            onPressed: selectBannerImage,
            backgroundColor: Colors.purple.shade600,
            elevation: 2,
            child: const Icon(
              Icons.camera_alt,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        if (_buildBannerImage(user) is! Image)
          Center(
            child: Icon(
              Icons.photo_library_outlined,
              size: 50,
              color: Theme.of(context).iconTheme.color?.withOpacity(0.3),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileSection(user, bool isDark) {
    return Center(
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade400,
                  Colors.purple.shade600,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: CircleAvatar(
                radius: 56,
                backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                backgroundImage: _buildProfileImage(user),
                child: _buildProfileImage(user) == null
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),
            ),
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: GestureDetector(
              onTap: selectProfileImage,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.shade400,
                  border: Border.all(
                    color: isDark ? Colors.grey.shade800 : Colors.white,
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.all(6),
                child: const Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfoSection(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile Information',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Editable Name Field
          _buildEditableInfoRow(
            icon: Icons.person,
            label: 'Name',
            value: nameController.text,
            isEditing: _isEditingName,
            onEditPressed: _toggleNameEditing,
            controller: nameController,
            theme: theme,
          ),
          const SizedBox(height: 12),

          // Editable Username Field
          _buildEditableInfoRow(
            icon: Icons.badge_outlined,
            label: 'Username',
            value: usernameController.text,
            isEditing: _isEditingUsername,
            onEditPressed: _toggleUsernameEditing,
            controller: usernameController,
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildEditableInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isEditing,
    required VoidCallback onEditPressed,
    required TextEditingController controller,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.iconTheme.color?.withOpacity(0.7),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 2),
              if (isEditing)
                TextFormField(
                  controller: controller,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                )
              else
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(
            isEditing ? Icons.check : Icons.edit,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          onPressed: onEditPressed,
          splashRadius: 20,
        ),
      ],
    );
  }

  Widget? _buildBannerImage(user) {
    if (bannerWebFile != null) return Image.memory(bannerWebFile!, fit: BoxFit.cover);
    if (bannerFile != null) return Image.file(bannerFile!, fit: BoxFit.cover);
    if (user.banner.isNotEmpty && user.banner != Constants.bannerDefault) {
      return Image.network(user.banner, fit: BoxFit.cover);
    }
    return null;
  }



  ImageProvider? _buildProfileImage(user) {
    if (profileWebFile != null) return MemoryImage(profileWebFile!);
    if (profileFile != null) return FileImage(profileFile!);
    if (user.profilePic.isNotEmpty && user.profilePic != Constants.avatarDefault) {
      return NetworkImage(user.profilePic);
    }
    return null;
  }
}