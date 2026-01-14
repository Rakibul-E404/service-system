
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/utils/api/app_url.dart';
import '../controllers/add_list_controller.dart';
import '../controllers/create_add_controller.dart';


class PublishAdvertisementScreen extends StatelessWidget {
  const PublishAdvertisementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AdsListController adsController = Get.put(AdsListController());
    final CreateAdController createController = Get.put(CreateAdController());

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(), // Close the overlay
        ),
        title: const Text("Create Advertisement"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /// 🔹 Banner Image / Placeholder / Selected Image
              Obx(() {
                if (createController.selectedImage.value != null) {
                  return _localBanner(createController.selectedImage.value!);
                }
                if (adsController.isLoading.value) {
                  return _loadingBanner();
                }
                if (adsController.adsList.isNotEmpty &&
                    adsController.adsList.first.content.isNotEmpty) {
                  final content = adsController.adsList.first.content;
                  final imageUrl = content.startsWith('http')
                      ? content
                      : '${AppUrl.imageBaseUrl}/$content';

                  return _bannerImage(imageUrl);
                }
                return _placeholderBanner();
              }),

              const SizedBox(height: 16),

              /// 🔹 Pick Image Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => createController.pickAdImage(
                          source: ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text("Gallery"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          createController.pickAdImage(source: ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("Camera"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              /// 🔹 Publish Advertisement Button
              Obx(() {
                return SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: createController.isLoading.value
                        ? null
                        : () => createController
                        .createAdvertisement()
                        .then((_) => adsController.fetchSelfAds())
                        .then((_) => Get.back()), // Navigate back after successful creation
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[600],
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: createController.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      "Publish Advertisement",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  /// ---------------- Widgets ----------------

  Widget _loadingBanner() {
    return Container(
      height: 180,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const CircularProgressIndicator(),
    );
  }

  Widget _bannerImage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholderBanner(),
      ),
    );
  }

  Widget _localBanner(File imageFile) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(
        imageFile,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _placeholderBanner() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.image_outlined, size: 50, color: Colors.grey),
          SizedBox(height: 8),
          Text(
            "Banner Image Placeholder",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
