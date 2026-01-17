
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/common/widgets/reusable_button.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';
import '../model/user_provider_profile_response_model.dart';

class ProviderBookingBottomSheet extends StatefulWidget {
  final ProviderProfile providerProfile;
  final UserProviderService selectedService;
  final VoidCallback? onSubmitSuccess;

  const ProviderBookingBottomSheet({
    super.key,
    required this.providerProfile,
    required this.selectedService,
    this.onSubmitSuccess,
  });

  @override
  State<ProviderBookingBottomSheet> createState() => _ProviderBookingBottomSheetState();
}

class _ProviderBookingBottomSheetState extends State<ProviderBookingBottomSheet> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedTimeLabel;
  String? _selectedRegion;
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  // Helper to convert opening/closing times (int) to readable slots
  List<String> _getAvailableSlots(AvailabilityDay? availability) {
    if (availability == null || !availability.isAvailable) return [];

    List<String> slots = [];
    int start = availability.openingTime ?? 9; // Fallback to 9 AM
    int end = availability.closingTime ?? 18;  // Fallback to 6 PM

    for (int hour = start; hour < end; hour++) {
      final String period = hour >= 12 ? 'PM' : 'AM';
      final int displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      slots.add('$displayHour:00 $period');
    }
    return slots;
  }

  @override
  Widget build(BuildContext context) {

    final String dayKey = DateFormat('EEEE').format(_selectedDate);
    final AvailabilityDay? availability = widget.providerProfile.availability[dayKey];
    final List<String> slots = _getAvailableSlots(availability);

    return Container(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16, right: 16, top: 16
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Book ${widget.selectedService.name}",
                style: context.txtTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const Divider(height: 30),

            // Horizontal Calendar
            _buildCalendarHeader(),
            const SizedBox(height: 12),
            _buildHorizontalCalendar(),

            const Divider(height: 40),

            Text("Available Slots ($dayKey)", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            if (slots.isEmpty)
              const Center(child: Padding(
                padding: EdgeInsets.all(20),
                child: Text("Provider is closed on this day", style: TextStyle(color: Colors.red)),
              ))
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisExtent: 45,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: slots.length,
                itemBuilder: (context, index) {
                  final time = slots[index];
                  final bool isSelected = _selectedTimeLabel == time;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedTimeLabel = time),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryColor : AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primaryColor),
                      ),
                      child: Text(time, style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 13
                      )),
                    ),
                  );
                },
              ),

            const SizedBox(height: 24),
            Text("Address Details", style: context.txtTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            _buildRegionDropdown(),
            const SizedBox(height: 12),
            _buildCustomTextField(controller: _addressController, label: "Full Address", icon: Icons.location_on_outlined),
            const SizedBox(height: 12),
            _buildCustomTextField(controller: _noteController, label: "Additional Notes", maxLines: 3),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ReusableButton(
                onTap: _submit,
                label: "Confirm Booking",
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildCalendarHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(8)),
      child: Center(child: Text(DateFormat('MMMM yyyy').format(_selectedDate),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
    );
  }

  Widget _buildHorizontalCalendar() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14,
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index));
          final bool isSelected = DateFormat('yyyyMMdd').format(date) == DateFormat('yyyyMMdd').format(_selectedDate);
          return GestureDetector(
            onTap: () => setState(() {
              _selectedDate = date;
              _selectedTimeLabel = null; // Reset time when date changes
            }),
            child: Container(
              width: 60,
              margin: const EdgeInsets.only(right: 10, top: 10, bottom: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryColor),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(DateFormat('E').format(date),
                      style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontSize: 12)),
                  Text(date.day.toString(),
                      style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRegionDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: const Text("Select Region"),
          value: _selectedRegion,
          items: ['north', 'south', 'east', 'west'].map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase()))).toList(),
          onChanged: (v) => setState(() => _selectedRegion = v),
        ),
      ),
    );
  }

  Widget _buildCustomTextField({required TextEditingController controller, required String label, IconData? icon, int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: AppColors.primaryColor) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _submit() {
    if (_selectedTimeLabel == null || _selectedRegion == null || _addressController.text.isEmpty) {
      Get.snackbar("Error", "Please fill all required fields", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    // Call your booking controller here
    widget.onSubmitSuccess?.call();
  }
}