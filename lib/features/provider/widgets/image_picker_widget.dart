import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';

// Simple Image Picker Widget
class ImagePickerWidget extends StatelessWidget {
  final Function(File)? onImageSelected;
  final String? title;
  final String? subtitle;
  final String? buttonText;
  final Color? buttonColor;
  final Color? borderColor;
  final double? height;
  final double? width;
  final IconData? uploadIcon;
  final bool showBorder;

  const ImagePickerWidget({
    super.key,
    this.onImageSelected,
    this.title,
    this.subtitle,
    this.buttonText,
    this.buttonColor,
    this.borderColor,
    this.height,
    this.width,
    this.uploadIcon,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: showBorder
            ? Border.all(
          color: borderColor ?? Colors.amber[300]!,
          width: 2,
          style: BorderStyle.solid,
        )
            : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Upload Icon
          Icon(
            uploadIcon ?? Icons.cloud_upload_outlined,
            size: 40,
            color: Colors.grey[600],
          ),

          const SizedBox(height: 12),

          // Title
          Text(
            title ?? 'Drop file or browse',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 4),

          // Subtitle
          Text(
            subtitle ?? 'Format: jpeg, png & Max file size: 25 MB',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Browse Button
          ElevatedButton(
            onPressed: () => _showImagePicker(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor ?? Colors.amber[600],
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              elevation: 0,
            ),
            child: Text(
              buttonText ?? 'Browse',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Image',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPickerOption(
                  context: context,
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () => _pickFromGallery(context),
                ),
                _buildPickerOption(
                  context: context,
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () => _pickFromCamera(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 30,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _pickFromGallery(BuildContext context) {
    Navigator.pop(context);

    // Demo implementation - Replace with actual ImagePicker
    // final picker = ImagePicker();
    // final image = await picker.pickImage(source: ImageSource.gallery);
    // if (image != null && onImageSelected != null) {
    //   onImageSelected!(File(image.path));
    // }

    // For demo purposes
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gallery selected (Demo - implement ImagePicker)'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _pickFromCamera(BuildContext context) {
    Navigator.pop(context);

    // Demo implementation - Replace with actual ImagePicker
    // final picker = ImagePicker();
    // final image = await picker.pickImage(source: ImageSource.camera);
    // if (image != null && onImageSelected != null) {
    //   onImageSelected!(File(image.path));
    // }

    // For demo purposes
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Camera selected (Demo - implement ImagePicker)'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

// Enhanced Image Picker with Preview
class ImagePickerWithPreview extends StatefulWidget {
  final Function(File?)? onImageChanged;
  final String? title;
  final String? subtitle;
  final String? buttonText;
  final Color? buttonColor;
  final File? initialImage;

  const ImagePickerWithPreview({
    super.key,
    this.onImageChanged,
    this.title,
    this.subtitle,
    this.buttonText,
    this.buttonColor,
    this.initialImage,
  });

  @override
  State<ImagePickerWithPreview> createState() => _ImagePickerWithPreviewState();
}

class _ImagePickerWithPreviewState extends State<ImagePickerWithPreview> {
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    selectedImage = widget.initialImage;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.amber[300]!,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: selectedImage != null
          ? _buildImagePreview()
          : _buildUploadArea(),
    );
  }

  Widget _buildUploadArea() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.cloud_upload_outlined,
          size: 40,
          color: Colors.grey[600],
        ),
        const SizedBox(height: 12),
        Text(
          widget.title ?? 'Drop file or browse',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          widget.subtitle ?? 'Format: jpeg, png & Max file size: 25 MB',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _showImagePicker,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.buttonColor ?? Colors.amber[600],
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            elevation: 0,
          ),
          child: Text(
            widget.buttonText ?? 'Browse',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  selectedImage!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: _removeImage,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _showImagePicker,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[600],
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 0,
                ),
                child: const Text(
                  'Change Image',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _removeImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[100],
                foregroundColor: Colors.red[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 0,
              ),
              child: const Icon(Icons.delete, size: 18),
            ),
          ],
        ),
      ],
    );
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Image',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPickerOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: _pickFromGallery,
                ),
                _buildPickerOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: _pickFromCamera,
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 30,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _pickFromGallery() {
    Navigator.pop(context);
    // Demo - Replace with actual ImagePicker implementation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gallery selected (Demo)')),
    );
  }

  void _pickFromCamera() {
    Navigator.pop(context);
    // Demo - Replace with actual ImagePicker implementation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Camera selected (Demo)')),
    );
  }

  void _removeImage() {
    setState(() {
      selectedImage = null;
    });
    if (widget.onImageChanged != null) {
      widget.onImageChanged!(null);
    }
  }
}

// Example Usage Screen
class ImagePickerExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Picker Demo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Image Picker',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Basic Image Picker
            ImagePickerWidget(
              onImageSelected: (file) {
                print('Image selected: ${file.path}');
              },
            ),

            const SizedBox(height: 32),

            const Text(
              'Custom Styled Image Picker',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Custom Image Picker
            ImagePickerWidget(
              title: 'Upload Profile Picture',
              subtitle: 'JPG, PNG up to 10MB',
              buttonText: 'Choose File',
              buttonColor: Colors.blue,
              borderColor: Colors.blue[300],
              height: 180,
              uploadIcon: Icons.person_add_alt_1,
              onImageSelected: (file) {
                print('Profile image selected: ${file.path}');
              },
            ),

            const SizedBox(height: 32),

            const Text(
              'Image Picker with Preview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Image Picker with Preview
            ImagePickerWithPreview(
              title: 'Business Logo',
              subtitle: 'Upload your business logo',
              onImageChanged: (file) {
                print('Business logo changed: ${file?.path ?? "removed"}');
              },
            ),

            const SizedBox(height: 32),

            // Usage Information
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Usage:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Basic: Simple upload widget\n'
                        '• Custom: Fully customizable styling\n'
                        '• Preview: Shows selected image with edit options\n'
                        '• Add image_picker package for real functionality',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}