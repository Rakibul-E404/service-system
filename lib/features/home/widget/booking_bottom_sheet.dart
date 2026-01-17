import 'package:flutter/material.dart';
import 'package:manx_mate/core/utils/api/app_url.dart';
import '../../../core/common/widgets/reusable_button.dart';
import '../../../core/common/widgets/time_picker_widget.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/config/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/network/network_caller.dart';
import '../../../core/network/network_response.dart';
import '../../../core/utils/token_service/token_storage_service.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

import '../controllers/user_booking_service_controller.dart';
import '../model/single_service_model.dart';

class BookingBottomSheet extends StatefulWidget {
  const BookingBottomSheet({
    super.key,
    required this.dateTEController,
    required this.timeController,
    required this.additionalNoteTEController,
    required this.service,
    this.onSubmitSuccess,
    this.preSelectedServiceId,
    this.preSelectedDate,
  });

  final TextEditingController dateTEController;
  final TimeController timeController;
  final TextEditingController additionalNoteTEController;
  final SingleServiceModel service;
  final VoidCallback? onSubmitSuccess;
  final String? preSelectedServiceId;
  final DateTime? preSelectedDate;

  @override
  State<BookingBottomSheet> createState() => _BookingBottomSheetState();
}

class _BookingBottomSheetState extends State<BookingBottomSheet> {
  // Initialize the new controller
  final UserBookingServiceController _bookingController = Get.put(UserBookingServiceController());

  DateTime _selectedDate = DateTime.now();
  String? _selectedTimeLabel;
  String? _selectedLocation;
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.preSelectedDate ?? DateTime.now();
    widget.dateTEController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
  }

  List<String> _getAvailableSlots(DayAvailability? availability) {
    if (availability == null || !availability.isAvailable) return [];
    List<String> slots = [];
    int start = availability.openingTime;
    int end = availability.closingTime;

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
    final DayAvailability? availability = widget.service.profileDetails.availability.days[dayKey];
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
            Text("Book services", style: context.txtTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const Divider(height: 30, thickness: 1),

            _buildCalendarHeader(),
            const SizedBox(height: 12),
            _buildHorizontalCalendar(),

            const Divider(height: 40, thickness: 1),

            Text("Available Slots for $dayKey", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (slots.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("No available slots on this day", style: TextStyle(color: Colors.red))))
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
                      child: Text(time, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  );
                },
              ),

            const SizedBox(height: 24),
            Text("Booking Details", style: context.txtTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            _buildRegionDropdown(),
            const SizedBox(height: 12),
            _buildCustomTextField(controller: _addressController, label: "Full Address", icon: Icons.location_on_outlined),
            const SizedBox(height: 12),
            _buildCustomTextField(controller: widget.additionalNoteTEController, label: "Additional Notes", maxLines: 3),

            const SizedBox(height: 24),

            /// --- Integrated Submit Button with Loading State ---
            Obx(() => SizedBox(
              width: double.infinity,
              height: 55,
              child: ReusableButton(
                onTap: _bookingController.isBookingLoading.value ? () {} : _submitBooking,
                label: _bookingController.isBookingLoading.value ? "Processing..." : "Confirm Booking",
              ),
            )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- Methods ---

  Future<void> _submitBooking() async {
    if (_selectedTimeLabel == null || _selectedLocation == null || _addressController.text.isEmpty) {
      Get.snackbar("Required Fields", "Please select a time slot, region, and enter your address.",
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    bool success = await _bookingController.confirmBooking(
      serviceId: widget.service.id,
      details: widget.additionalNoteTEController.text.trim(),
      selectedDate: _selectedDate,
      selectedTimeLabel: _selectedTimeLabel!,
      region: _selectedLocation!,
      location: _addressController.text.trim(),
    );

    if (success) {
      widget.onSubmitSuccess?.call();
    }
  }

  // --- UI Helpers (Calendar and Dropdown from previous steps) ---
  Widget _buildCalendarHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(8)),
      child: Center(child: Text(DateFormat('MMMM yyyy').format(_selectedDate), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
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
          final bool isSelected = date.day == _selectedDate.day && date.month == _selectedDate.month;
          return GestureDetector(
            onTap: () => setState(() {
              _selectedDate = date;
              _selectedTimeLabel = null;
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
                  Text(DateFormat('E').format(date), style: const TextStyle(fontSize: 12)),
                  Text(date.day.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
          value: _selectedLocation,
          items: ['north', 'south', 'east', 'west'].map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase()))).toList(),
          onChanged: (v) => setState(() => _selectedLocation = v),
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
}
