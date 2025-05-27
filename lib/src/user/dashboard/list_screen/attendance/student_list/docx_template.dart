import 'dart:developer';
import 'dart:io';
import 'package:docx_template/docx_template.dart';

void populateWordTemplate() async {
  // Load the Word template
  final File templateFile = File('assets/StudentRecord.docx');
  final DocxTemplate docxTemplate =
      await DocxTemplate.fromBytes(await templateFile.readAsBytes());

  // Check if the template loaded successfully
  // ignore: unnecessary_null_comparison
  if (docxTemplate == null) {
    log("Error loading the template.");
    return;
  }

  // Prepare content to replace placeholders
  final content = Content();

  content
    ..add(TextContent('subject', 'Mathematics 101'))
    ..add(TextContent('schedule', 'Monday & Wednesday, 10:00 AM - 11:30 AM'))
    ..add(TextContent('code', 'MATH101'))
    ..add(TextContent('room', 'Room 305'))
    ..add(TextContent('teacher', 'Prof. Alex Johnson'))
    ..add(TextContent('datenow', '2024-12-04'));

  // Add rows to a table (if applicable)
  content.add(TableContent(
    'record',
    [
      RowContent()
        ..add(TextContent('index', '1'))
        ..add(TextContent('name', 'John Doe'))
        ..add(TextContent('section', 'BSCS 2-A'))
        ..add(TextContent('present', '✔')),
      RowContent()
        ..add(TextContent('index', '2'))
        ..add(TextContent('name', 'Jane Smith'))
        ..add(TextContent('section', 'BSCS 2-A'))
        ..add(TextContent('present', '✔')),
    ],
  ));

  // Generate the Word file
  final generatedFileBytes = await docxTemplate.generate(content);

  // Save the generated file
  if (generatedFileBytes != null) {
    final outputFile = File('assets/generated.docx');
    await outputFile.writeAsBytes(generatedFileBytes);
    log("Document generated: ${outputFile.path}");
  } else {
    log("Failed to generate the document.");
  }
}
