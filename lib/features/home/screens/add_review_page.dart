import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:manx_mate/core/utils/api/app_url.dart';
import '../../../core/utils/token_service/token_storage_service.dart';

class AddReviewPage extends StatefulWidget {
  final String providerName;
  final String serviceId;

  const AddReviewPage({
    super.key,
    required this.providerName,
    required this.serviceId,
  });

  @override
  State<AddReviewPage> createState() => _AddReviewPageState();
}

class _AddReviewPageState extends State<AddReviewPage> {
  int _rating = 0;
  final TextEditingController _reviewController = TextEditingController();
  bool _isSubmitting = false;

  final SharedPrefService _sharedPrefService = SharedPrefService();

  Future<void> _submitReview() async {
    if (_rating == 0) {
      Get.snackbar(
        'Rating Required',
        'Please select a star rating',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (_reviewController.text.trim().isEmpty) {
      Get.snackbar(
        'Review Required',
        'Please write your review',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // 🔐 Get access token
      final String? accessToken =
      await _sharedPrefService.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        throw 'Authentication required. Please log in again.';
      }

      final Uri url =
      Uri.parse(AppUrl.addReviewsUrl(widget.serviceId));

      final Map<String, dynamic> body = <String, dynamic>{
        'description': _reviewController.text.trim(),
        'rating': _rating,
      };

      final http.Response response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back();
        Get.back();

        Get.snackbar(
          'Thank You!',
          'Your review has been submitted successfully.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        print("Hello");
        print(response.body);
        final Map<String, dynamic> res =
        jsonDecode(response.body);
        throw res['message'] ?? 'Failed to submit review';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Review'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.providerName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Your Rating',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            Row(
              children: List.generate(5, (int index) {
                final int star = index + 1;
                return IconButton(
                  onPressed: () => setState(() => _rating = star),
                  icon: Icon(
                    Icons.star,
                    size: 32,
                    color: star <= _rating
                        ? Colors.amber
                        : Colors.grey.shade400,
                  ),
                );
              }),
            ),

            const SizedBox(height: 24),

            const Text(
              'Write a Review',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _reviewController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Share your experience...',
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text(
                  'Submit Review',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
