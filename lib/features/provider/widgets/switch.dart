
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_colors.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/utils/token_service/token_storage_service.dart';



class ReminderController extends GetxController {
  RxBool isReminderOn = false.obs; // Observable for the switch state

  // Update the availability on the server
  Future<void> updateAvailability(String providerId, bool isAvailable) async {
    final String? providerAccessToken = await SharedPrefService().getAccessToken();

    if (providerAccessToken == null) {
      debugPrint('❌ No provider access token found');
      return;
    }

    try {
      final response = await http.put(
        Uri.parse('https://d7001.sobhoy.com/api/v1/business_profile/$providerId/availability'),
        headers: {
          'Authorization': 'Bearer $providerAccessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'isAvailable': isAvailable,  // Send true/false based on switch state
        }),
      );

      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          debugPrint('✅ Availability updated successfully');
          isReminderOn.value = isAvailable; // Update local state on success
        } else {
          debugPrint('❌ Error: ${responseData['message']}');
        }
      } else {
        debugPrint('❌ Error updating availability: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error: $e');
    }
  }
}




class ReminderSwitch extends StatelessWidget {
  final String label;
  final String providerId;  // Pass the provider ID to update availability

  const ReminderSwitch({
    Key? key,
    required this.label,
    required this.providerId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ReminderController controller = Get.find();

    return Obx(() {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(child: Text(label)),
            Switch(
              value: controller.isReminderOn.value,
              onChanged: (bool newValue) async {
                // Call the API to update the availability
                await controller.updateAvailability(providerId, newValue);
              },
              activeColor: AppColors.primaryColor,
              inactiveThumbColor: AppColors.greyColor,
              inactiveTrackColor: AppColors.whiteColor,
            ),
          ],
        ),
      );
    });
  }
}

