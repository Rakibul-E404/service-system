import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/features/booking/screens/booking_tabs/tab_controllers/ongoing_job_tab_controller.dart';

class OngoingJobTab extends StatelessWidget {
  final OngoingJobController controller;
  const OngoingJobTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
      if (controller.ongoingJobs.isEmpty) return const Center(child: Text('No ongoing jobs yet'));
      return ListView.builder(
        itemCount: controller.ongoingJobs.length,
        itemBuilder: (context, index) {
          final item = controller.ongoingJobs[index];
          return ListTile(
            title: Text(item['service']['name']),
            subtitle: Text(item['service']['description']),
          );
        },
      );
    });
  }
}
