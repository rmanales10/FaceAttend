import 'dart:developer';

import 'package:get/get.dart';

class DocumentService extends GetConnect {
  Future<Response> generateDocument({
    required var record,
    required var subject,
    required var datenow,
    required var code,
    required var teacher,
  }) async {
    final data = {
      "document": "5m96F11aCQpwQu8QAvge",
      "apiKey": "BVJDP7Q-2RTEZJA-SVIHCXQ-3PE25CA",
      "format": "docx",
      "data": {
        "subject": subject,
        "schedule": "",
        "code": code,
        "room": "",
        "date": datenow,
        "record": record,
        "teacher": teacher,
        "datenow": datenow
      }
    };

    final response = await post('https://app.documentero.com/api', data);

    if (response.statusCode == 200) {
      log('Document generated successfully!');
      log('$response');
      return response;
    } else {
      log('Failed to generate document: ${response.statusText}');
      throw Exception('Failed to generate document');
    }
  }
}
