// import 'package:flutter/material.dart';
// import '../../../core/config/app_colors.dart';
// import '../../../core/config/app_sizes.dart';
//
// class BookASlotScreen extends StatefulWidget {
//   const BookASlotScreen({super.key});
//
//   @override
//   State<BookASlotScreen> createState() => _BookASlotScreenState();
// }
//
// class _BookASlotScreenState extends State<BookASlotScreen> {
//   String? _selectedCategory;
//   String? _selectedSubCategory;
//   String? _selectedLocation;
//   final TextEditingController _additionalNoteController = TextEditingController();
//
//   @override
//   void dispose() {
//     _additionalNoteController.dispose();
//     super.dispose();
//   }
//
//   void _onSendPressed() {
//     // Simple validation and submission
//     if (_selectedCategory == null ||
//         _selectedSubCategory == null ||
//         _selectedLocation == null ||
//         _additionalNoteController.text.isEmpty) {
//       _showSnackBar('Please fill all fields', isError: true);
//       return;
//     }
//
//     _showSnackBar('Booking submitted successfully');
//
//     // Clear form
//     setState(() {
//       _selectedCategory = null;
//       _selectedSubCategory = null;
//       _selectedLocation = null;
//     });
//     _additionalNoteController.clear();
//   }
//
//   void _showSnackBar(String message, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? Colors.red : Colors.green,
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: <Widget>[
//           // CATEGORY DROPDOWN
//           _buildDropdown(
//             value: _selectedCategory,
//             onChanged: (String? newValue) {
//               setState(() {
//                 _selectedCategory = newValue;
//               });
//             },
//             items: const ['Electronics', 'Furniture', 'Clothing', 'Books'],
//             hint: 'Select Category',
//           ),
//
//           const SizedBox(height: AppSizes.md),
//
//           // SUB-CATEGORY DROPDOWN
//           _buildDropdown(
//             value: _selectedSubCategory,
//             onChanged: (String? newValue) {
//               setState(() {
//                 _selectedSubCategory = newValue;
//               });
//             },
//             items: const ['Mobile', 'Laptop', 'Tablet', 'Accessories'],
//             hint: 'Select Sub-Category',
//           ),
//
//           const SizedBox(height: AppSizes.md),
//
//           // LOCATION DROPDOWN
//           _buildDropdown(
//             value: _selectedLocation,
//             onChanged: (String? newValue) {
//               setState(() {
//                 _selectedLocation = newValue;
//               });
//             },
//             items: const ['North', 'South', 'East', 'West'],
//             hint: 'Location',
//           ),
//
//           const SizedBox(height: AppSizes.md),
//
//           // ADDITIONAL NOTE
//           Container(
//             width: double.infinity,
//             decoration: BoxDecoration(
//               color: AppColors.whiteColor,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: AppColors.primaryColor, width: 1.8),
//             ),
//             child: TextFormField(
//               controller: _additionalNoteController,
//               textInputAction: TextInputAction.done,
//               maxLines: 5,
//               decoration: const InputDecoration(
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(12)),
//                   borderSide: BorderSide(color: Colors.transparent),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(12)),
//                   borderSide: BorderSide(color: Colors.transparent),
//                 ),
//                 hintText: "Additional note",
//                 contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
//               ),
//             ),
//           ),
//
//           const SizedBox(height: AppSizes.md),
//
//           // SEND BUTTON
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               onPressed: _onSendPressed,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.primaryColor,
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: const Text(
//                 'Send',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDropdown({
//     required String? value,
//     required Function(String?) onChanged,
//     required List<String> items,
//     required String hint,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.whiteColor,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppColors.primaryColor, width: 1.8),
//       ),
//       child: DropdownButtonFormField<String>(
//         value: value,
//         onChanged: onChanged,
//         items: [
//           DropdownMenuItem<String>(
//             value: null,
//             child: Text(
//               hint,
//               style: TextStyle(color: Colors.grey.shade600),
//             ),
//           ),
//           ...items.map<DropdownMenuItem<String>>((String item) {
//             return DropdownMenuItem<String>(
//               value: item,
//               child: Text(item),
//             );
//           }).toList(),
//         ],
//         decoration: const InputDecoration(
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.all(Radius.circular(12)),
//             borderSide: BorderSide.none,
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.all(Radius.circular(12)),
//             borderSide: BorderSide.none,
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.all(Radius.circular(12)),
//             borderSide: BorderSide.none,
//           ),
//           contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         ),
//       ),
//     );
//   }
// }