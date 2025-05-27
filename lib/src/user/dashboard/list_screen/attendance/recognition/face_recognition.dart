import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:app_attend/src/admin/main_screen/color_constant.dart';
import 'package:app_attend/src/user/api_services/document_service.dart';
import 'package:app_attend/src/user/dashboard/dashboard.dart';
import 'package:app_attend/src/user/dashboard/list_screen/attendance/attendance_screen/attendance_screen.dart';
import 'package:app_attend/src/user/dashboard/list_screen/attendance/student_list/docx_template.dart';
import 'package:app_attend/src/user/dashboard/list_screen/attendance/student_list/list_controller.dart';
import 'package:app_attend/src/user/dashboard/list_screen/profile/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:math' as math;
import 'dart:convert'; // For Base64 decoding
import 'package:path_provider/path_provider.dart'; // To save decoded images as Files

class FaceComparisonScreen extends StatefulWidget {
  final String subject;
  final String section;
  final String date;
  final String attendanceId;
  final bool isSubmitted;
  final bool isAsynchronous;
  const FaceComparisonScreen({
    super.key,
    required this.subject,
    required this.section,
    required this.date,
    required this.attendanceId,
    required this.isSubmitted,
    required this.isAsynchronous,
  });

  @override
  _FaceComparisonScreenState createState() => _FaceComparisonScreenState();
}

class _FaceComparisonScreenState extends State<FaceComparisonScreen> {
  final _controller = Get.put(ListController());
  final _profileController = Get.put(ProfileController());
  final documentService = Get.put(DocumentService());

  final RxList<Map<String, dynamic>> studentRecord =
      <Map<String, dynamic>>[].obs;

  final RxList<bool> isPresent = <bool>[].obs;

  //////////////////////////////////////////////////////
  File? _userImage; // User-selected image from gallery
  List<Map<String, dynamic>> _results =
      []; // To store results for all detected faces
  late Interpreter _interpreter;
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableLandmarks: true,
      enableClassification: false,
      enableTracking: false,
      minFaceSize: 0.15,
    ),
  );

  // List to store Firestore images and their metadata
  List<Map<String, dynamic>> _firestoreImages = [];

  @override
  void initState() {
    super.initState();
    _loadModel();
    _fetchImagesFromFirestore(); // Fetch all images when the screen loads
  }

  Future<void> _loadModel() async {
    try {
      final options = InterpreterOptions()..threads = 4;
      _interpreter = await Interpreter.fromAsset(
        'assets/mobilefacenet.tflite',
        options: options,
      );
      print('Model loaded successfully');
      print('Input shape: ${_interpreter.getInputTensor(0).shape}');
      print('Output shape: ${_interpreter.getOutputTensor(0).shape}');
    } catch (e) {
      print('Error loading model: $e');
      rethrow;
    }
  }

  // Fetch all images and names from Firestore
  Future<void> _fetchImagesFromFirestore() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('studentData').get();

      List<Map<String, dynamic>> firestoreImages = [];
      for (var doc in snapshot.docs) {
        if (doc.exists && doc['imageBase64'] != null && doc['name'] != null) {
          String base64String = doc['imageBase64'];
          if (base64String.contains(',')) {
            base64String = base64String.split(',')[1];
          }
          Uint8List imageBytes = base64Decode(base64String);
          final tempDir = await getTemporaryDirectory();
          final tempFile = File('${tempDir.path}/${doc.id}.jpg');
          await tempFile.writeAsBytes(imageBytes);

          firestoreImages.add({'file': tempFile, 'name': doc['name']});
        }
      }

      setState(() {
        _firestoreImages = firestoreImages;
      });

      if (_firestoreImages.isEmpty) {
        setState(() {
          _results = [
            {'result': 'No images found in Firestore'},
          ];
        });
      }
    } catch (e) {
      print('Error fetching images from Firestore: $e');
      setState(() {
        _results = [
          {'result': 'Error fetching images: $e'},
        ];
      });
    }
  }

  Future<void> _getUserImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(
      source: source,
    );
    if (pickedFile != null) {
      setState(() {
        _userImage = File(pickedFile.path);
        _results = []; // Clear previous results when a new image is selected
      });
      await _compareFaces(); // Automatically compare faces after image selection
    }
  }

  img.Image _cropFace(img.Image image, Face face) {
    final left = (face.boundingBox.left - 10).clamp(0, image.width.toDouble());
    final top = (face.boundingBox.top - 10).clamp(0, image.height.toDouble());
    final right = (face.boundingBox.right + 10).clamp(
      0,
      image.width.toDouble(),
    );
    final bottom = (face.boundingBox.bottom + 10).clamp(
      0,
      image.height.toDouble(),
    );

    return img.copyCrop(
      image,
      x: left.toInt(),
      y: top.toInt(),
      width: (right - left).toInt(),
      height: (bottom - top).toInt(),
    );
  }

  Future<List<double>> _extractFaceFeatures(img.Image croppedFace) async {
    try {
      final resizedFace = img.copyResize(croppedFace, width: 112, height: 112);
      print('Resized face size: ${resizedFace.width}x${resizedFace.height}');

      final input = _imageToByteList(resizedFace);
      print('Input length: ${input.length}');

      final inputTensor = _interpreter.getInputTensor(0);
      final outputTensor = _interpreter.getOutputTensor(0);

      print('Input shape: ${inputTensor.shape}');
      print('Output shape: ${outputTensor.shape}');

      final reshapedInput = input.reshape(inputTensor.shape);
      final output = List.generate(1, (_) => List<double>.filled(128, 0.0));

      try {
        _interpreter.run(reshapedInput, output);
      } catch (e) {
        print('Error running interpreter: $e');
        rethrow;
      }
      return output[0];
    } catch (e) {
      print('Error in _extractFaceFeatures: $e');
      rethrow;
    }
  }

  Float32List _imageToByteList(img.Image image) {
    final result = Float32List(1 * 112 * 112 * 3);
    var index = 0;
    for (var y = 0; y < 112; y++) {
      for (var x = 0; x < 112; x++) {
        final pixel = image.getPixel(x, y);
        result[index++] = (pixel.r - 127.5) / 128.0;
        result[index++] = (pixel.g - 127.5) / 128.0;
        result[index++] = (pixel.b - 127.5) / 128.0;
      }
    }
    return result;
  }

  double _cosineSimilarity(List<double> a, List<double> b) {
    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;

    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }

    return dotProduct / (math.sqrt(normA) * math.sqrt(normB));
  }

  Future<void> _compareFaces() async {
    List<String> matchedNames = [];

    if (_userImage == null) {
      setState(() {
        _results = [
          {'result': 'Please select an image to compare'},
        ];
      });
      return;
    }

    if (_firestoreImages.isEmpty) {
      setState(() {
        _results = [
          {'result': 'No images available in Firestore to compare'},
        ];
      });
      return;
    }

    try {
      final inputImage = InputImage.fromFilePath(_userImage!.path);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        setState(() {
          _results = [
            {'result': 'No faces detected in the image'},
          ];
        });
        return;
      }

      final image = img.decodeImage(await _userImage!.readAsBytes())!;
      List<Map<String, dynamic>> comparisonResults = [];

      for (int i = 0; i < faces.length; i++) {
        final face = faces[i];
        final croppedFace = _cropFace(image, face);
        final userFeatures = await _extractFaceFeatures(croppedFace);

        double highestSimilarity = -1.0;
        String? matchedName;

        for (var firestoreImage in _firestoreImages) {
          final firestoreImageData =
              img.decodeImage(await firestoreImage['file'].readAsBytes())!;
          final firestoreFaces = await _faceDetector.processImage(
            InputImage.fromFilePath(firestoreImage['file'].path),
          );

          if (firestoreFaces.isNotEmpty) {
            final firestoreFace = firestoreFaces.first;
            final firestoreCroppedFace =
                _cropFace(firestoreImageData, firestoreFace);
            final firestoreFeatures =
                await _extractFaceFeatures(firestoreCroppedFace);

            final similarity =
                _cosineSimilarity(userFeatures, firestoreFeatures);

            if (similarity > highestSimilarity) {
              highestSimilarity = similarity;
              matchedName = firestoreImage['name'];
            }
          }
        }

        if (matchedName != null && highestSimilarity > 0.5) {
          comparisonResults.add({
            // 'result':
            //     'Face ${i + 1} - Match: $matchedName\nSimilarity: ${(highestSimilarity * 100).toStringAsFixed(2)}%',
            'result': 'Successfully Attended: $matchedName',
          });
          matchedNames.add(matchedName);
        } else {
          comparisonResults.add({
            'result': 'Face ${i + 1} - No match found (similarity too low)',
          });
        }
      }

      setState(() {
        _results = comparisonResults;
        for (int i = 0; i < studentRecord.length; i++) {
          if (matchedNames.contains(studentRecord[i]['name'])) {
            isPresent[i] = true;
            studentRecord[i]['present'] = '✓';
          } else {
            isPresent[i] = false;
            studentRecord[i]['present'] = 'X';
          }
        }
      });
    } catch (e) {
      print('Error during face comparison: $e');
      setState(() {
        _results = [
          {'result': 'Error: ${e.toString()}'},
        ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: blue),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                  Text(
                    'Face Recognition',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: blue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildInfoContainer('Subject:', widget.subject),
                      _buildInfoContainer('Section:', widget.section),
                      _buildInfoContainer('Date:', widget.date),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: blue, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _userImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(_userImage!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 50, color: blue),
                          SizedBox(height: 10),
                          Text('Select Image', style: TextStyle(color: blue)),
                        ],
                      ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _getUserImage(ImageSource.camera),
                    icon: Icon(Icons.camera_alt),
                    label: Text('Take Photo'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(width: widget.isAsynchronous ? 20 : 0),
                  widget.isAsynchronous
                      ? ElevatedButton.icon(
                          onPressed: () => _getUserImage(ImageSource.gallery),
                          icon: Icon(Icons.photo_library),
                          label: Text('From Gallery'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        )
                      : SizedBox.shrink(),
                ],
              ),
              // SizedBox(height: 20),
              // ElevatedButton(
              //   onPressed: _compareFaces,
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: blue,
              //     padding: EdgeInsets.symmetric(vertical: 15),
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(10),
              //     ),
              //   ),
              //   child:
              //       Text('Take Attendance', style: TextStyle(fontSize: 18)),
              // ),
              SizedBox(height: 20),
              ..._results.map(
                (result) => Card(
                  elevation: 2,
                  margin: EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      result['result'],
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                height: size.height * 0.4,
                child: Obx(() {
                  _controller.getStudentsList(
                      section: widget.section, subject: widget.subject);
                  final studentList = _controller.studentList;

                  if (isPresent.isEmpty) {
                    isPresent.addAll(
                        List.generate(studentList.length, (_) => false));
                  }

                  _controller.printAttendanceStudentRecord(
                      attendanceId: widget.attendanceId);
                  final Map<String, dynamic> printList =
                      _controller.attendaceStudentRecord;

                  if (printList.containsKey('student_record') &&
                      printList['student_record'] != null) {
                    final List<dynamic> rawStudentList =
                        printList['student_record'];
                    final List<Map<String, dynamic>> studentPrintList =
                        rawStudentList
                            .map((e) => Map<String, dynamic>.from(e as Map))
                            .toList();

                    if (widget.isSubmitted) {
                      return _buildScrollableTable(studentPrintList, size);
                    }
                  }
                  return _buildScrollableTable(studentList, size);
                }),
              ),
              SizedBox(height: 10),
              Text(
                !widget.isSubmitted
                    ? 'Note! You can only submit once'
                    : 'Note! Generate to Word only',
                style:
                    TextStyle(fontStyle: FontStyle.italic, color: Colors.red),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: !widget.isSubmitted
                    ? () async {
                        await _profileController.fetchUserInfo();
                        await _controller.addAttendanceStudentRecord(
                          attendanceId: widget.attendanceId,
                          code: widget.subject.split(' ')[0],
                          datenow: widget.date,
                          room: '',
                          schedule: widget.date,
                          studentRecord: studentRecord,
                          subject: widget.subject,
                          teacher: _profileController.userInfo['fullname'],
                          section: widget.section,
                        );
                        await _controller.isSubmitted(
                            attendanceId: widget.attendanceId);
                        populateWordTemplate();
                        Get.off(() => Dashboard(
                              initialIndex: 1,
                            ));
                        Get.snackbar('Success',
                            'Attendance has been submitted successfully');
                      }
                    : () async {
                        _onReportSelected(attendanceId: widget.attendanceId);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: blue,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  !widget.isSubmitted ? 'Submit' : 'Generate Report',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _interpreter.close();
    _faceDetector.close();
    // Clean up temporary files
    for (var image in _firestoreImages) {
      (image['file'] as File).delete();
    }
    super.dispose();
  }

  Widget _buildScrollableTable(List<Map<String, dynamic>> data, Size size) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: DataTable(
            columns: [
              DataColumn(label: Text('No.')),
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Present ✓')),
            ],
            rows: data.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> student = entry.value;

              if (studentRecord.length < data.length) {
                studentRecord.add({
                  'name': student['full_name'] ?? student['name'],
                  'present': isPresent[index] ? '✓' : 'X',
                });
              }

              return DataRow(cells: [
                DataCell(Text('${index + 1}')),
                DataCell(
                    Text(student['full_name'] ?? student['name'] ?? 'N/A')),
                DataCell(widget.isSubmitted
                    ? Text(
                        student['present'] ?? 'N/A',
                        style: TextStyle(
                            color: student['present'] == '✓'
                                ? Colors.green
                                : Colors.red),
                      )
                    : Checkbox(
                        value: isPresent[index],
                        onChanged: (value) {
                          setState(() {
                            isPresent[index] = value ?? false;
                            studentRecord[index]['present'] =
                                isPresent[index] ? '✓' : 'X';
                          });
                        },
                      )),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoContainer(String label, String value) {
    return Container(
      width: 130, // Slightly increased width
      margin: EdgeInsets.symmetric(horizontal: 5),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 6),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: blue, width: 1),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: blue,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _onReportSelected({required attendanceId}) async {
    _controller.printAttendanceStudentRecord(attendanceId: attendanceId);
    final generate = _controller.attendaceStudentRecord;
    final record = _controller.studentPrintList;
    final List recorded = [];
    int index = 1;
    for (var records in record) {
      var data = {
        "index": '${index++}',
        "name": records['name'],
        "section": generate['section'],
        "present": '${records['present']}',
      };
      recorded.add(data);
    }
    log('$recorded');
    log('Exporting to PDF...');

    try {
      await _profileController.fetchUserInfo();
      final response = await documentService.generateDocument(
        record: recorded,
        subject: generate['subject'],
        datenow: generate['datenow'],
        code: widget.subject.split(' ')[0],
        teacher: _profileController.userInfo['fullname'],
      );

      if (response.statusCode == 200) {
        final String downloadLink = response.body['data'];
        await _controller.storedUrl(
          attendanceId: attendanceId,
          subject: generate['subject'],
          section: generate['section'],
          date: generate['datenow'],
          type: 'Docx',
          url: downloadLink,
        );
        Get.back();
        Get.snackbar('Success', 'Report generated successfully!');
      }
    } catch (e) {
      log('Error $e');
    }
  }
}
