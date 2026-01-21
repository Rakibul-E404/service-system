/**
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import 'package:get/get.dart';
import '../controllers/availability_controller.dart';
import '../controllers/provider_profile_controller.dart';

class ProviderAvailabilityScreen extends StatefulWidget {
  const ProviderAvailabilityScreen({super.key});

  @override
  State<ProviderAvailabilityScreen> createState() =>
      _ProviderAvailabilityScreenState();
}

class _ProviderAvailabilityScreenState extends State<ProviderAvailabilityScreen> {
  final AvailabilityController _controller = Get.put(AvailabilityController());
  final ProviderProfileController _profileCtrl = Get.find<ProviderProfileController>();

  late Map<String, bool> _availability;
  late Map<String, String> _startTime;
  late Map<String, String> _endTime;

  // Added time options list to match your h:00a formatting
  final List<String> _timeOptions = [
    '12:00am', '1:00am', '2:00am', '3:00am', '4:00am', '5:00am', '6:00am', '7:00am', '8:00am', '9:00am', '10:00am', '11:00am',
    '12:00pm', '1:00pm', '2:00pm', '3:00pm', '4:00pm', '5:00pm', '6:00pm', '7:00pm', '8:00pm', '9:00pm', '10:00pm', '11:00pm'
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  void _loadCurrentSettings() {
    _availability = {};
    _startTime = {};
    _endTime = {};

    // Match the order of your JSON response days
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    for (var day in days) {
      final existing = _profileCtrl.availability[day];
      if (existing != null) {
        _availability[day] = existing.isAvailable;
        _startTime[day] = _formatIntToTime(existing.openingTime);
        _endTime[day] = _formatIntToTime(existing.closingTime);
      } else {
        // Fallback defaults
        _availability[day] = false;
        _startTime[day] = '10:00am';
        _endTime[day] = '6:00pm';
      }
    }
  }

  // Converts integer (e.g., 14) to string (e.g., "2:00pm") to match dropdown options
  String _formatIntToTime(int hour) {
    // Handle edge case for 24
    final actualHour = hour >= 24 ? 0 : hour;
    final tempDate = DateTime(2026, 1, 1, actualHour);
    return DateFormat('h:00a').format(tempDate).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Set Availability', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
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
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                day,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isEnabled ? Colors.black : Colors.grey,
                ),
              ),
            ),
            _buildTimeDropdown(day, isEnabled, isStart: true),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text("-", style: TextStyle(color: Colors.grey)),
            ),
            _buildTimeDropdown(day, isEnabled, isStart: false),
            const SizedBox(width: 8),
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
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
            color: Colors.grey[50],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: isStart ? _startTime[day] : _endTime[day],
              isDense: true,
              dropdownColor: Colors.white,
              style: const TextStyle(fontSize: 12, color: Colors.black),
              items: _timeOptions.map((v) => DropdownMenuItem(
                value: v,
                child: Text(v),
              )).toList(),
              onChanged: isEnabled ? (val) {
                if (val != null) {
                  setState(() => isStart ? _startTime[day] = val : _endTime[day] = val);
                }
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
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _controller.isLoading.value
            ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
        )
            : const Text(
          'Update Availability',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    ));
  }
}
*/





///
///
///
/// todo::: fixing the data pass correctly
///
///
///






import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:manx_mate/core/config/app_colors.dart';
import '../controllers/availability_controller.dart';
import '../controllers/provider_profile_controller.dart';

class ProviderAvailabilityScreen extends StatefulWidget {
  const ProviderAvailabilityScreen({super.key});

  @override
  State<ProviderAvailabilityScreen> createState() =>
      _ProviderAvailabilityScreenState();
}

class _ProviderAvailabilityScreenState extends State<ProviderAvailabilityScreen> {
  final AvailabilityController _controller = Get.put(AvailabilityController());
  final ProviderProfileController _profileCtrl = Get.find<ProviderProfileController>();

  late Map<String, bool> _availability;
  late Map<String, String> _startTime;
  late Map<String, String> _endTime;

  final List<String> _timeOptions = [
    '12:00am','1:00am','2:00am','3:00am','4:00am','5:00am','6:00am','7:00am','8:00am','9:00am','10:00am','11:00am',
    '12:00pm','1:00pm','2:00pm','3:00pm','4:00pm','5:00pm','6:00pm','7:00pm','8:00pm','9:00pm','10:00pm','11:00pm'
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  void _loadCurrentSettings() {
    _availability = {};
    _startTime = {};
    _endTime = {};
    final days = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];

    for (var day in days) {
      final existing = _profileCtrl.availability[day];
      if (existing != null) {
        _availability[day] = existing.isAvailable;
        _startTime[day] = _formatIntToTime(existing.openingTime);
        _endTime[day] = _formatIntToTime(existing.closingTime);
      } else {
        _availability[day] = false;
        _startTime[day] = '10:00am';
        _endTime[day] = '6:00pm';
      }
    }
  }

  // Convert int (0-23) to string like "2:00pm"
  String _formatIntToTime(int hour) {
    final tempDate = DateTime(2026,1,1,hour >= 24 ? 0 : hour);
    return DateFormat('h:00a').format(tempDate).toLowerCase();
  }

  // Converts time string to int hour
  int _convertTimeStringToInt(String timeStr) {
    String cleanStr = timeStr.toLowerCase().replaceAll(' ', '');
    int hour = int.parse(cleanStr.split(':')[0]);
    if (cleanStr.contains('pm') && hour != 12) hour += 12;
    if (cleanStr.contains('am') && hour == 12) hour = 0;
    return hour;
  }

  // Validate that closingTime is after openingTime
  bool _isValidTime(String start, String end) {
    return _convertTimeStringToInt(end) > _convertTimeStringToInt(start);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
            'Set Availability',
            style: TextStyle(color: Colors.black,fontSize:18,fontWeight: FontWeight.bold)
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children:[
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: _availability.keys.length,
                itemBuilder: (context,index){
                  final day = _availability.keys.elementAt(index);
                  return _buildDayCard(day);
                },
              ),
            ),
            const SizedBox(height:16),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCard(String day) {
    bool isEnabled = _availability[day]!;
    return Card(
      elevation:0,
      margin: const EdgeInsets.symmetric(vertical:6),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[300]!, width:1)
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal:12, vertical:10),
        child: Row(
          children:[
            Expanded(
              flex:3,
              child: Text(
                day,
                style: TextStyle(
                    fontSize:15,
                    fontWeight: FontWeight.w600,
                    color: isEnabled ? Colors.black : Colors.grey
                ),
              ),
            ),
            _buildTimeDropdown(day, isEnabled, isStart:true),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal:4),
              child: Text("-", style: TextStyle(color:Colors.grey)),
            ),
            _buildTimeDropdown(day, isEnabled, isStart:false),
            const SizedBox(width:8),
            Switch(
              value: isEnabled,
              activeColor: AppColors.primaryColor,
              onChanged:(val)=>setState(()=>_availability[day]=val),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeDropdown(String day,bool isEnabled,{required bool isStart}) {
    return Expanded(
      flex:3,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal:6, vertical:2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
            color: Colors.grey[50],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: isStart ? _startTime[day] : _endTime[day],
              isDense:true,
              dropdownColor: Colors.white,
              style: const TextStyle(fontSize:12,color:Colors.black),
              items: _timeOptions.map((v)=>DropdownMenuItem(value:v,child:Text(v))).toList(),
              onChanged: isEnabled ? (val){
                if(val==null) return;
                setState(() {
                  if(isStart) _startTime[day] = val;
                  else _endTime[day] = val;
                });
              } : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Obx(()=>SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _controller.isLoading.value ? null : (){
          // Validate times
          for(final day in _availability.keys){
            if(_availability[day]! && !_isValidTime(_startTime[day]!, _endTime[day]!)){
              Get.snackbar('Invalid Time', '$day: Closing time must be after opening time',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM
              );
              return;
            }
          }

          // Call controller to update backend
          _controller.updateBusinessAvailability(
            availability: _availability,
            startTimes: _startTime,
            endTimes: _endTime,
          );
        },
        style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
            elevation:0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
        ),
        child: _controller.isLoading.value ? const SizedBox(
            width:20, height:20,
            child: CircularProgressIndicator(color: Colors.white, strokeWidth:2)
        ) : const Text(
            'Update Availability',
            style: TextStyle(fontSize:16,fontWeight: FontWeight.bold)
        ),
      ),
    ));
  }
}
