import 'package:flutter/material.dart';

class ReusableDatePickerField extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final Color? color;

  const ReusableDatePickerField({
    Key? key,
    required this.hintText,
    this.controller,
    this.validator,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.color = Colors.white,
  }) : super(key: key);

  @override
  _ReusableDatePickerFieldState createState() =>
      _ReusableDatePickerFieldState();
}

class _ReusableDatePickerFieldState extends State<ReusableDatePickerField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // Use provided controller or create a new one.
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    // Dispose only if we created it.
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _selectDate() async {
    DateTime now = DateTime.now();
    final DateTime initial = widget.initialDate ?? now;
    final DateTime first = widget.firstDate ?? DateTime(1900);
    final DateTime last = widget.lastDate ?? DateTime(2100);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
    );

    if (pickedDate != null) {
      // Format the date as DD-MM-YYYY.
      final String formattedDate =
          "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
      setState(() {
        _controller.text = formattedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: GestureDetector(
        onTap: _selectDate,
        child: AbsorbPointer(
          child: TextFormField(
            controller: _controller,
            validator: widget.validator,
            decoration: InputDecoration(
              hintText: widget.hintText,
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}
