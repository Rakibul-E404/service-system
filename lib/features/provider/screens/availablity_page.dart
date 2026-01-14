import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/config/app_sizes.dart';

import '../controllers/availability_controller.dart';

// Main Availability Page
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// class ProviderAvailabilityPage extends GetView<AvailabilityController> {
//   const ProviderAvailabilityPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     // Ensure the controller is initialized
//     Get.put(AvailabilityController());
//
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 1,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
//           onPressed: () => Get.back(),
//         ),
//         title: const Text(
//           'Set ',
//           style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
//         ),
//         centerTitle: true,
//         actions: <Widget>[
//           TextButton(
//             onPressed: () => controller.clearAll(),
//             child: const Text('Clear', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             // 24/7 Option
//             _build24HourOption(controller),
//
//             const SizedBox(height: 20),
//
//             // Quick Setup (only when not 24/7)
//             Obx(() => !controller.isAlwaysAvailable.value
//                 ? _buildQuickSetup(controller)
//                 : const SizedBox()),
//
//             Obx(() => !controller.isAlwaysAvailable.value
//                 ? const SizedBox(height: 20)
//                 : const SizedBox()),
//
//             // Days Selection (only when not 24/7)
//             Obx(() => !controller.isAlwaysAvailable.value
//                 ? _buildDaysSection(controller)
//                 : const SizedBox()),
//
//             const SizedBox(height: 24),
//
//             // Summary of what will be sent to the API
//             _buildSummary(controller),
//
//             const SizedBox(height: 24),
//
//             // Save Button with Loading State
//             _buildSaveButton(controller),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _build24HourOption(AvailabilityController controller) {
//     return Obx(
//           () => GestureDetector(
//         onTap: () => controller.toggleAlwaysAvailable(),
//         child: Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(
//               color: controller.isAlwaysAvailable.value ? Colors.green : Colors.grey[300]!,
//               width: controller.isAlwaysAvailable.value ? 2 : 1,
//             ),
//           ),
//           child: Row(
//             children: <Widget>[
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: controller.isAlwaysAvailable.value ? Colors.green[50] : Colors.grey[50],
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(
//                   Icons.access_time,
//                   color: controller.isAlwaysAvailable.value ? Colors.green[600] : Colors.grey[600],
//                   size: 24,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: <Widget>[
//                     Text(
//                       'Always Available (24/7)',
//                       style: TextStyle(
//                         fontWeight: FontWeight.w600,
//                         fontSize: 16,
//                         color: controller.isAlwaysAvailable.value ? Colors.green[700] : Colors.black87,
//                       ),
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       'Available all days, all hours',
//                       style: TextStyle(color: Colors.grey[600], fontSize: 14),
//                     ),
//                   ],
//                 ),
//               ),
//               Switch(
//                 value: controller.isAlwaysAvailable.value,
//                 onChanged: (bool value) => controller.toggleAlwaysAvailable(),
//                 activeColor: Colors.green,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildQuickSetup(AvailabilityController controller) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           Row(
//             children: <Widget>[
//               Icon(Icons.flash_on, color: Colors.amber[600], size: 20),
//               const SizedBox(width: 8),
//               const Text(
//                 'Quick Setup',
//                 style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton.icon(
//               onPressed: () => controller.setWeekdaySchedule(),
//               icon: const Icon(Icons.work, size: 18),
//               label: const Text('Set Weekdays 9 AM - 5 PM'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue[50],
//                 foregroundColor: Colors.blue[700],
//                 elevation: 0,
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                   side: BorderSide(color: Colors.blue[200]!),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDaysSection(AvailabilityController controller) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           Row(
//             children: <Widget>[
//               Icon(Icons.calendar_today, color: Colors.blue[600], size: 20),
//               const SizedBox(width: 8),
//               const Text(
//                 'Custom Schedule',
//                 style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
//               ),
//               const Spacer(),
//               Obx(() => Text(
//                 '${controller.selectedDaysCount} days selected',
//                 style: TextStyle(color: Colors.grey[600], fontSize: 12),
//               )),
//             ],
//           ),
//           const SizedBox(height: 16),
//           ...controller.weekDays.map((String day) {
//             return Obx(() => _buildDayCard(controller, day));
//           }).toList(),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDayCard(AvailabilityController controller, String day) {
//     final bool isSelected = controller.isDaySelected(day);
//     final String timeDisplay = controller.getTimeDisplayForDay(day);
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: () => controller.toggleDay(day),
//           borderRadius: BorderRadius.circular(8),
//           child: Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: isSelected ? Colors.blue[50] : Colors.grey[50],
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: isSelected ? Colors.blue[200]! : Colors.grey[300]!),
//             ),
//             child: Column(
//               children: <Widget>[
//                 Row(
//                   children: <Widget>[
//                     Container(
//                       width: 20,
//                       height: 20,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: isSelected ? Colors.blue : Colors.transparent,
//                         border: Border.all(
//                           color: isSelected ? Colors.blue : Colors.grey[400]!,
//                           width: 2,
//                         ),
//                       ),
//                       child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 12) : null,
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Text(
//                         day,
//                         style: TextStyle(
//                           fontWeight: FontWeight.w500,
//                           fontSize: 15,
//                           color: isSelected ? Colors.blue[700] : Colors.grey[700],
//                         ),
//                       ),
//                     ),
//                     if (isSelected && timeDisplay.isNotEmpty)
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                         decoration: BoxDecoration(
//                           color: Colors.blue[100],
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Text(
//                           timeDisplay,
//                           style: TextStyle(fontSize: 11, color: Colors.blue[700], fontWeight: FontWeight.w500),
//                         ),
//                       ),
//                   ],
//                 ),
//                 if (isSelected) ...<Widget>[
//                   const SizedBox(height: 12),
//                   Row(
//                     children: <Widget>[
//                       const SizedBox(width: 32),
//                       Expanded(
//                         child: Wrap(
//                           spacing: 6,
//                           runSpacing: 6,
//                           children: <Widget>[
//                             ...controller.quickTimeSlots.map((String slot) {
//                               return _buildTimeSlotChip(
//                                 label: slot,
//                                 onTap: () => controller.setTimeForDay(day, slot),
//                               );
//                             }).toList(),
//                             _buildTimeSlotChip(
//                               label: 'Custom',
//                               onTap: () => _showCustomTimePicker(controller, day),
//                               isCustom: true,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTimeSlotChip({required String label, required VoidCallback onTap, bool isCustom = false}) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//         decoration: BoxDecoration(
//           color: isCustom ? Colors.amber[100] : Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: isCustom ? Colors.amber[300]! : Colors.grey[300]!),
//         ),
//         child: Text(
//           label,
//           style: TextStyle(
//             fontSize: 10,
//             color: isCustom ? Colors.amber[700] : Colors.grey[700],
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSummary(AvailabilityController controller) {
//     return Obx(() {
//       if (controller.isAlwaysAvailable.value) {
//         return _statusBox(Icons.check_circle, Colors.green, 'You are available 24/7');
//       }
//
//       if (!controller.hasAnySelection) {
//         return _statusBox(Icons.warning_amber, Colors.orange, 'Please set your availability');
//       }
//
//       return Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.blue[50],
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: Colors.blue[200]!),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             Row(
//               children: <Widget>[
//                 Icon(Icons.schedule, color: Colors.blue[600]),
//                 const SizedBox(width: 8),
//                 Text(
//                   'Your Schedule (${controller.selectedDaysCount} days)',
//                   style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.blue[700]),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             ...controller.selectedDays.map((String day) {
//               return Padding(
//                 padding: const EdgeInsets.only(bottom: 4),
//                 child: Row(
//                   children: <Widget>[
//                     SizedBox(width: 80, child: Text(day, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
//                     Text(controller.getTimeDisplayForDay(day), style: const TextStyle(fontSize: 13)),
//                   ],
//                 ),
//               );
//             }).toList(),
//           ],
//         ),
//       );
//     });
//   }
//
//   Widget _statusBox(IconData icon, Color color, String text) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: color.withOpacity(0.2)),
//       ),
//       child: Row(
//         children: <Widget>[
//           Icon(icon, color: color),
//           const SizedBox(width: 12),
//           Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15))),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSaveButton(AvailabilityController controller) {
//     return Obx(
//           () => SizedBox(
//         width: double.infinity,
//         child: ElevatedButton(
//           onPressed: (controller.hasAnySelection && !controller.isLoading.value) ? () => controller.saveAvailability() : null,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: controller.hasAnySelection ? Colors.amber[600] : Colors.grey[300],
//             foregroundColor: controller.hasAnySelection ? Colors.black : Colors.grey[600],
//             padding: const EdgeInsets.symmetric(vertical: 16),
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//             elevation: 0,
//           ),
//           child: controller.isLoading.value
//               ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
//               : Text(
//             controller.hasAnySelection ? 'Save Availability' : 'Select Your Availability',
//             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _showCustomTimePicker(AvailabilityController controller, String day) {
//     TimeOfDay? startTime;
//     TimeOfDay? endTime;
//
//     Get.dialog(
//       AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         title: Text('Custom Time for $day'),
//         content: StatefulBuilder(
//           builder: (context, setState) => Column(
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: () async {
//                         final time = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 9, minute: 0));
//                         if (time != null) setState(() => startTime = time);
//                       },
//                       child: Text(startTime?.format(context) ?? 'Start Time'),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: () async {
//                         final time = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 17, minute: 0));
//                         if (time != null) setState(() => endTime = time);
//                       },
//                       child: Text(endTime?.format(context) ?? 'End Time'),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//         actions: <Widget>[
//           TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
//           ElevatedButton(
//             onPressed: () {
//               if (startTime != null && endTime != null) {
//                 controller.setCustomTime(day, startTime!.format(Get.context!), endTime!.format(Get.context!));
//                 Get.back();
//               }
//             },
//             child: const Text('Set Time'),
//           ),
//         ],
//       ),
//     );
//   }
// }