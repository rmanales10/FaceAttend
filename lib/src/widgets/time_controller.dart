import 'dart:async';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TimeController extends GetxController {
  var currentTime = ''.obs;
  var timeOfDay = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _updateTimeAndGreeting();
    // Update the time and greeting every second
    Timer.periodic(Duration(seconds: 1), (timer) {
      _updateTimeAndGreeting();
    });
  }

  void _updateTimeAndGreeting() {
    final now = DateTime.now()
        .toUtc()
        .add(Duration(hours: 8)); // Adjusting to UTC+8 for Philippines
    currentTime.value = DateFormat('h:mm:ssa')
        .format(now)
        .toLowerCase(); // Format as 6:15:30p or 6:15:30am
    timeOfDay.value = _getTimeOfDay(now.hour);
  }

//lage
  String _getTimeOfDay(int hour) {
    if (hour >= 5 && hour < 12) {
      return 'Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Afternoon';
    } else if (hour >= 17 && hour < 20) {
      return 'Evening';
    } else {
      return 'Night';
    }
  }
}
