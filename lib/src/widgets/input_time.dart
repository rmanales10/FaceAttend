import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeInputField extends StatefulWidget {
  const TimeInputField({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TimeInputFieldState createState() => _TimeInputFieldState();
}

class _TimeInputFieldState extends State<TimeInputField> {
  final TextEditingController _controller = TextEditingController();
  final DateFormat _timeFormat = DateFormat("hh:mm a");

  @override
  void initState() {
    super.initState();
    // Set the initial time to the current time
    _controller.text = _timeFormat.format(DateTime.now());
  }

  void _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final now = DateTime.now();
      final selectedTime =
          DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
      _controller.text = _timeFormat.format(selectedTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: TextInputType.datetime,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Time',
        suffixIcon: IconButton(
          icon: Icon(Icons.access_time),
          onPressed: _selectTime,
        ),
      ),
      onTap: () {
        if (_controller.text.isEmpty) {
          final now = DateTime.now();
          _controller.text = _timeFormat.format(now);
        }
      },
    );
  }
}
