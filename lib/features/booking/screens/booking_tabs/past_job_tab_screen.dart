import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/features/booking/screens/booking_tabs/tab_controllers/past_job_tab_controller.dart';

class PastJobTab extends StatelessWidget {
  final PastJobController controller;
  const PastJobTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
      if (controller.pastJobs.isEmpty) return const Center(child: Text('No past jobs yet'));
      return ListView.builder(
        itemCount: controller.pastJobs.length,
        itemBuilder: (context, index) {
          final item = controller.pastJobs[index];
          return ListTile(
            title: Text(item['service']['name']),
            subtitle: Text(item['service']['description']),
          );
        },
      );
    });
  }
}
