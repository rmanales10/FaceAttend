import 'dart:convert';
import 'dart:io';
import 'package:app_attend/src/user/dashboard/list_screen/student_data/student_controller.dart';
import 'package:app_attend/src/widgets/color_constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class Student extends StatefulWidget {
  const Student({super.key});

  @override
  State<Student> createState() => _StudentState();
}

class StudentInfo {
  String name;
  String imageUrl;

  StudentInfo({
    required this.name,
    required this.imageUrl,
  });
}

class _StudentState extends State<Student> {
  final _controller = Get.put(StudentController());

  String selectedClass = 'BSIT 3D';
  List<String> classes = ['BSIT 3D', 'BSIT 3A', 'BSIT 3B', 'BSIT 3C'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Student Information',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: blue,
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedClass,
                          isExpanded: true,
                          icon: Icon(Icons.arrow_drop_down, color: blue),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          items: classes.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedClass = newValue!;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showAddStudentModal(),
                    icon: Icon(Icons.add, color: Colors.white),
                    label: Text('Add Student',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      elevation: 2,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Expanded(
                child: Obx(() {
                  _controller.fetchStudentData(selectedClass);
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: GridView.builder(
                      padding: EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _controller.studentData.length,
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: blue.withOpacity(0.1),
                                child: ClipOval(
                                  child: _controller.studentData[index]
                                                  ['imageBase64'] !=
                                              null &&
                                          _controller.studentData[index]
                                              ['imageBase64'] is String
                                      ? Image.memory(
                                          base64Decode(
                                              _controller.studentData[index]
                                                  ['imageBase64'] as String),
                                          fit: BoxFit.cover,
                                          width: 90,
                                          height: 90,
                                          gaplessPlayback: true,
                                        )
                                      : Image.asset(
                                          'assets/logo.png',
                                          fit: BoxFit.cover,
                                          width: 90,
                                          height: 90,
                                        ),
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                _controller.studentData[index]['name'] ??
                                    'Unknown',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                selectedClass,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddStudentModal() {
    String fullName = '';
    File? imageFile;
    String? imageBase64;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: EdgeInsets.all(24),
                constraints: BoxConstraints(maxWidth: 400),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Add New Student',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: blue,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24),
                      GestureDetector(
                        onTap: () async {
                          try {
                            final picker = ImagePicker();
                            final pickedFile = await picker.pickImage(
                              source: ImageSource.gallery,
                              maxWidth: 800,
                              maxHeight: 600,
                              imageQuality: 70,
                            );
                            if (pickedFile != null) {
                              final bytes = await pickedFile.readAsBytes();
                              setState(() {
                                imageFile = File(pickedFile.path);
                                imageBase64 = base64Encode(bytes);
                              });
                            }
                          } catch (e) {
                            print('Error picking image: $e');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Failed to pick image. Please try again.')),
                            );
                          }
                        },
                        child: Container(
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: blue.withOpacity(0.5)),
                          ),
                          child: imageFile != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child:
                                      Image.file(imageFile!, fit: BoxFit.cover),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_photo_alternate,
                                        size: 50, color: blue),
                                    SizedBox(height: 8),
                                    Text('Add Image',
                                        style: TextStyle(color: blue)),
                                  ],
                                ),
                        ),
                      ),
                      SizedBox(height: 24),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          hintText: 'Enter student\'s full name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: blue),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: blue, width: 2),
                          ),
                          prefixIcon: Icon(Icons.person, color: blue),
                        ),
                        onChanged: (value) {
                          fullName = value;
                        },
                      ),
                      SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('Cancel',
                                style: TextStyle(color: Colors.red)),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              if (fullName.isNotEmpty && imageBase64 != null) {
                                final saved =
                                    await _controller.saveStudentToFirestore(
                                        fullName, imageBase64!, selectedClass);
                                if (saved) {
                                  Navigator.of(context).pop();
                                  Get.snackbar(
                                      'Success', 'Student added successfully',
                                      backgroundColor: Colors.green,
                                      colorText: Colors.white);
                                } else {
                                  Get.snackbar('Error', 'Failed to add student',
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white);
                                }
                              } else {
                                Get.snackbar('Error', 'Please fill all fields',
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                            child: Text('Add Student',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
