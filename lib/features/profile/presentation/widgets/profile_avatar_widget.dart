import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';

class ProfileAvatarWidget extends StatefulWidget {
  final String defaultAvatarAsset;
  final String name;
  final String roleTitle;
  final ValueChanged<XFile?>? onImagePicked;

  const ProfileAvatarWidget({
    super.key,
    this.defaultAvatarAsset = 'assets/images/CogniCare-logo.png',
    required this.name,
    required this.roleTitle,
    this.onImagePicked,
  });

  @override
  State<ProfileAvatarWidget> createState() => _ProfileAvatarWidgetState();
}

class _ProfileAvatarWidgetState extends State<ProfileAvatarWidget> {
  XFile? _imageFile;
  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageFile = pickedFile;
          _imageBytes = bytes;
        });

        if (widget.onImagePicked != null) {
          widget.onImagePicked!(pickedFile);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Profile Picture',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.titleNavy,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.photo_library_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  title: const Text(
                    'Choose from Gallery',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.titleNavy,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  title: const Text(
                    'Take a Photo',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.titleNavy,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                if (_imageBytes != null || _imageFile != null)
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFEE2E2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.red,
                      ),
                    ),
                    title: const Text(
                      'Remove Photo',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _imageFile = null;
                        _imageBytes = null;
                      });
                      if (widget.onImagePicked != null) {
                        widget.onImagePicked!(null);
                      }
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar Stack with Edit Badge
        Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Outer Mint Ring Background
              Container(
                width: 110,
                height: 110,
                decoration: const BoxDecoration(
                  color: Color(0xFFD2F0E2),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ClipOval(
                    child: _imageBytes != null
                        ? Image.memory(
                            _imageBytes!,
                            width: 102,
                            height: 102,
                            fit: BoxFit.cover,
                          )
                        : _buildDefaultAvatar(),
                  ),
                ),
              ),

              // Edit Camera/Pencil Badge Button
              Positioned(
                right: -2,
                bottom: 2,
                child: GestureDetector(
                  onTap: _showImagePickerModal,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A3967),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.edit_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // User Name
        Text(
          widget.name,
          style: const TextStyle(
            color: AppColors.titleNavy,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),

        // Role Chip Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFE6F7F0),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            widget.roleTitle,
            style: const TextStyle(
              color: AppColors.brandTeal,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: const Color(0xFFD2F0E2),
      child: const Center(
        child: Icon(
          Icons.face_rounded,
          size: 68,
          color: Color(0xFF1DB978),
        ),
      ),
    );
  }
}
