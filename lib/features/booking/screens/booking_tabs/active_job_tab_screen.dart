import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/features/booking/screens/booking_tabs/tab_controllers/active_job_tab_controller.dart';


class ActiveJobTab extends StatelessWidget {
  final ActiveJobController controller;
  const ActiveJobTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.activeJobs.isEmpty) {
        return const Center(child: Text('No active jobs yet'));
      }
      return ListView.builder(
        itemCount: controller.activeJobs.length,
        itemBuilder: (BuildContext context, int index) {
          final Map<String, dynamic> item = controller.activeJobs[index];
          return ListTile(
            title: Text(item['service']['name']),
            subtitle: Text(item['service']['description']),
          );
        },
      );
    });
  }
}
