import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:app_attend/src/user/api_services/auth_service.dart';
import 'package:app_attend/src/user/dashboard/list_screen/profile/profile_controller.dart';
import 'package:app_attend/src/widgets/color_constant.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final AuthService _auth = Get.put(AuthService());
  final _controller = Get.put(ProfileController());
  late final String base64Image;
  final isEdit = false.obs;

  @override
  void initState() {
    super.initState();
    initProfile();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildProfileHeader(size),
            buildPersonalDetailsSection(),
            buildActionsSection(),
          ],
        ),
      ),
    );
  }

  Widget buildProfileHeader(Size size) {
    return Container(
      width: size.width,
      height: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [blue, blue.withOpacity(0.7)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Obx(() {
                  _controller.fetchUserInfo();
                  final imageString = _controller.userInfo['base64image'];
                  Uint8List? profileImageBytes;

                  if (imageString != null && imageString.isNotEmpty) {
                    try {
                      profileImageBytes = base64Decode(imageString);
                    } catch (e) {
                      log('Error decoding image string: $e');
                    }
                  }

                  return Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: profileImageBytes == null
                          ? Icon(
                              Icons.person,
                              size: 80,
                              color: Colors.white,
                            )
                          : Image.memory(
                              profileImageBytes,
                              fit: BoxFit.cover,
                              gaplessPlayback: true,
                            ),
                    ),
                  );
                }),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: pickImageAndProcess,
                      icon: Icon(
                        Icons.camera_alt,
                        color: blue,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Obx(() {
              _controller.fetchUserInfo();
              return Text(
                '${_controller.userInfo['fullname'] ?? ''}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            }),
            const SizedBox(height: 5),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Instructor',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPersonalDetailsSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Personal Details',
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold, color: blue),
                  ),
                  Obx(() => TextButton(
                        onPressed: () async {
                          isEdit.value = !isEdit.value;
                          if (!isEdit.value) {
                            await _controller.updateUserInfo(
                              fullname: fullnameController.text,
                              phoneNumber: phoneController.text,
                            );
                          }
                        },
                        child: Text(
                          isEdit.value ? 'Save' : 'Edit',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      )),
                ],
              ),
              const SizedBox(height: 20),
              Obx(() => Column(
                    children: [
                      buildLabeledField('Name & Surname', Icons.person,
                          fullnameController, isEdit.value),
                      const SizedBox(height: 15),
                      buildLabeledField(
                          'Email Address', Icons.email, emailController, false),
                      const SizedBox(height: 15),
                      buildLabeledField('Phone Number', Icons.phone,
                          phoneController, isEdit.value),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLabeledField(
    String label,
    IconData icon,
    TextEditingController controller,
    bool isEdit,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[100],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: TextField(
        enabled: isEdit,
        controller: controller,
        style: TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: Icon(icon, color: blue),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget buildActionsSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildActionButton(
            onPressed: _resetPassword,
            icon: Icons.lock_reset,
            label: 'Reset Password',
            color: blue,
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            onPressed: () => _auth.signOut(),
            icon: Icons.logout,
            label: 'Sign Out',
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  Widget _buildLabeledField(
    String label,
    IconData icon,
    TextEditingController controller,
    bool isEdit,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey[200],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: Colors.grey[600]),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  enabled: isEdit,
                  controller: controller,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration.collapsed(
                    hintText: '',
                    border: InputBorder.none, // Removes the default underline
                  ),
                  keyboardType: TextInputType.text,
                  maxLines: 1, // Use multi-line if you want
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _resetPassword() {
    _controller.resetPass(email: emailController.text);
    Get.snackbar(
      'Reset Password',
      'Password reset link has been sent to your email.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blueAccent,
      colorText: Colors.white,
    );
  }

  Future<void> pickImageAndProcess() async {
    final ImagePicker picker = ImagePicker();

    try {
      // Pick an image from gallery
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        // Check if the platform is Web
        if (kIsWeb) {
          // Web: Use 'readAsBytes' to process the picked image
          final Uint8List webImageBytes = await pickedFile.readAsBytes();

          setState(() {
            base64Image = base64Encode(webImageBytes);
          });
          await _controller.storeImage(image: base64Image);

          log("Image selected on Web: ${webImageBytes.lengthInBytes} bytes");
        } else {
          // Native (Android/iOS): Use File to get image bytes
          final File nativeImageFile = File(pickedFile.path);

          // Ensure that the file exists
          if (await nativeImageFile.exists()) {
            final Uint8List nativeImageBytes =
                await nativeImageFile.readAsBytes();

            setState(() {
              base64Image = base64Encode(nativeImageBytes);
            });
            await _controller.storeImage(image: base64Image);

            log("Image selected on Native: ${nativeImageFile.path}");
          } else {
            log("File does not exist: ${pickedFile.path}");
          }
        }
      } else {
        log("No image selected.");
      }
    } catch (e) {
      log("Error picking image: $e");
    }
  }

  Future<void> initProfile() async {
    await _controller.fetchUserInfo();
    setState(() {
      fullnameController.text = _controller.userInfo['fullname'];
      emailController.text = _controller.userInfo['email'];
      phoneController.text = _controller.userInfo['phone'];
    });
  }
}
