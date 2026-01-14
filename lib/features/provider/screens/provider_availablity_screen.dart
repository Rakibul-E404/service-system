/**
import 'package:flutter/material.dart';

class ProviderAvailabilityScreen extends StatefulWidget {
  const ProviderAvailabilityScreen({Key? key}) : super(key: key);

  @override
  State<ProviderAvailabilityScreen> createState() =>
      _ProviderAvailabilityScreenState();
}

class _ProviderAvailabilityScreenState
    extends State<ProviderAvailabilityScreen> {
  // Store availability data
  final Map<String, bool> _availability = {
    'Monday': true,
    'Tuesday': true,
    'Wednesday': true,
    'Thursday': true,
    'Friday': true,
    'Saturday': true,
    'Sunday': true,
  };

  final Map<String, String> _startTime = {
    'Monday': '10:00am',
    'Tuesday': '10:00am',
    'Wednesday': '10:00am',
    'Thursday': '10:00am',
    'Friday': '10:00am',
    'Saturday': '10:00am',
    'Sunday': '10:00am',
  };

  final Map<String, String> _endTime = {
    'Monday': '11:00am',
    'Tuesday': '11:00am',
    'Wednesday': '11:00am',
    'Thursday': '11:00am',
    'Friday': '11:00am',
    'Saturday': '11:00am',
    'Sunday': '11:00am',
  };

  // Time options for dropdowns
  final List<String> _timeOptions = [
    '8:00am',
    '9:00am',
    '10:00am',
    '11:00am',
    '12:00pm',
    '1:00pm',
    '2:00pm',
    '3:00pm',
    '4:00pm',
    '5:00pm',
    '6:00pm',
    '7:00pm',
    '8:00pm',
    '9:00pm',
    '10:00pm',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Set Availability',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: 7,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final days = [
                    'Monday',
                    'Tuesday',
                    'Wednesday',
                    'Thursday',
                    'Friday',
                    'Saturday',
                    'Sunday'
                  ];
                  final day = days[index];

                  return Row(
                    children: [
                      // Day Name
                      Expanded(
                        flex: 2,
                        child: Text(
                          day,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Start Time Dropdown
                      Expanded(
                        flex: 3,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _startTime[day],
                              items: _timeOptions.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _startTime[day] = newValue!;
                                });
                              },
                              isExpanded: true,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // End Time Dropdown
                      Expanded(
                        flex: 3,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _endTime[day],
                              items: _timeOptions.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _endTime[day] = newValue!;
                                });
                              },
                              isExpanded: true,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Toggle Switch
                      Expanded(
                        flex: 1,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Switch(
                            value: _availability[day]!,
                            onChanged: (value) {
                              setState(() {
                                _availability[day] = value;
                              });
                            },
                            activeColor: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _updateAvailability();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700), // Yellow color
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Update time',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateAvailability() {
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Availability updated successfully!')),
    );

    // Optional: Log data
    print('Updated Availability:');
    print(_availability);
    print(_startTime);
    print(_endTime);
  }
}*/





import 'package:flutter/material.dart';
import 'package:manx_mate/core/config/app_colors.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/config/app_colors.dart';

import '../controllers/availability_controller.dart'; // Adjust import based on your project

class ProviderAvailabilityScreen extends StatefulWidget {
  const ProviderAvailabilityScreen({Key? key}) : super(key: key);

  @override
  State<ProviderAvailabilityScreen> createState() =>
      _ProviderAvailabilityScreenState();
}

class _ProviderAvailabilityScreenState extends State<ProviderAvailabilityScreen> {
  // Initialize Controller
  final AvailabilityController _controller = Get.put(AvailabilityController());

  final Map<String, bool> _availability = {
    'Monday': true, 'Tuesday': true, 'Wednesday': true, 'Thursday': true,
    'Friday': true, 'Saturday': true, 'Sunday': true,
  };

  final Map<String, String> _startTime = {
    'Monday': '10:00am', 'Tuesday': '10:00am', 'Wednesday': '10:00am', 'Thursday': '10:00am',
    'Friday': '10:00am', 'Saturday': '10:00am', 'Sunday': '10:00am',
  };

  final Map<String, String> _endTime = {
    'Monday': '6:00pm', 'Tuesday': '6:00pm', 'Wednesday': '6:00pm', 'Thursday': '6:00pm',
    'Friday': '6:00pm', 'Saturday': '6:00pm', 'Sunday': '6:00pm',
  };

  final List<String> _timeOptions = [
    '8:00am', '9:00am', '10:00am', '11:00am', '12:00pm', '1:00pm', '2:00pm',
    '3:00pm', '4:00pm', '5:00pm', '6:00pm', '7:00pm', '8:00pm', '9:00pm', '10:00pm',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Set Availability', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _availability.keys.length,
                itemBuilder: (context, index) {
                  final day = _availability.keys.elementAt(index);
                  return _buildDayCard(day);
                },
              ),
            ),
            const SizedBox(height: 16),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCard(String day) {
    bool isEnabled = _availability[day]!;
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(day, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
            // Start Time Dropdown
            _buildTimeDropdown(day, isEnabled, isStart: true),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text("-"),
            ),
            // End Time Dropdown
            _buildTimeDropdown(day, isEnabled, isStart: false),
            // Toggle
            Switch(
              value: isEnabled,
              activeColor: AppColors.primaryColor,
              onChanged: (val) => setState(() => _availability[day] = val),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeDropdown(String day, bool isEnabled, {required bool isStart}) {
    return Expanded(
      flex: 3,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: isStart ? _startTime[day] : _endTime[day],
              isDense: true,
              items: _timeOptions.map((v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontSize: 12)))).toList(),
              onChanged: isEnabled ? (val) {
                setState(() => isStart ? _startTime[day] = val! : _endTime[day] = val!);
              } : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Obx(() => SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _controller.isLoading.value
            ? null
            : () => _controller.updateBusinessAvailability(
          availability: _availability,
          startTimes: _startTime,
          endTimes: _endTime,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _controller.isLoading.value
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Update Availability', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    ));
  }
}
