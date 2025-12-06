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
        title: const Text('Set Availability'),
        backgroundColor: Colors.white,
        elevation: 4,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const Text(
            //   'Set Availability',
            //   style: TextStyle(
            //     fontSize: 28,
            //     fontWeight: FontWeight.w600,
            //     color: Color(0xFF2C3E50),
            //   ),
            // ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: 7,
                separatorBuilder: (context, index) => const Divider(
                  height: 1,
                  color: Colors.grey,
                ),
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

                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          // Day Name
                          Expanded(
                            flex: 3,
                            child: Text(
                              day,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF34495E),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Start Time Dropdown
                          Expanded(
                            flex: 3,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey),
                                color: Colors.white,
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _startTime[day],
                                  items: _timeOptions.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _startTime[day] = newValue!;
                                    });
                                  },
                                  isExpanded: true,
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
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey),
                                color: Colors.white,
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _endTime[day],
                                  items: _timeOptions.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _endTime[day] = newValue!;
                                    });
                                  },
                                  isExpanded: true,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
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
                                activeColor: AppColors.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _updateAvailability();
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16,horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  'Update Availability',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
}
