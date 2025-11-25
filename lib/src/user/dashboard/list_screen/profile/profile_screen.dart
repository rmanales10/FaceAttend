import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:app_attend/src/user/api_services/auth_service.dart';
import 'package:app_attend/src/user/dashboard/list_screen/profile/profile_controller.dart';
import 'package:app_attend/src/widgets/color_constant.dart';
import 'package:app_attend/src/widgets/snackbar_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui' as ui;

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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                buildProfileHeader(size),
                buildPersonalDetailsSection(),
                buildActionsSection(),
              ],
            ),
          ),
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
    );
  }

  Widget buildPersonalDetailsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
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
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
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
    showSuccess(message: 'Password reset link has been sent to your email.');
  }

  Future<void> pickImageAndProcess() async {
    final ImagePicker picker = ImagePicker();

    try {
      // Pick an image from gallery with compression settings
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800, // Max width for compression
        maxHeight: 800, // Max height for compression
        imageQuality: 70, // Quality: 0-100 (lower = smaller file)
      );

      if (pickedFile != null) {
        // Check if the platform is Web
        if (kIsWeb) {
          // Web: Compress and process the picked image
          final Uint8List webImageBytes = await pickedFile.readAsBytes();

          // Compress image for web
          final compressedBytes = await _compressImageWeb(webImageBytes);

          setState(() {
            base64Image = base64Encode(compressedBytes);
          });
          await _controller.storeImage(image: base64Image);

          log("Image selected on Web: Original: ${webImageBytes.lengthInBytes} bytes, Compressed: ${compressedBytes.lengthInBytes} bytes");
        } else {
          // Native (Android/iOS): Use File to get image bytes
          final File nativeImageFile = File(pickedFile.path);

          // Ensure that the file exists
          if (await nativeImageFile.exists()) {
            // Get original file size
            final originalSize = await nativeImageFile.length();

            // Compress the image
            final compressedBytes = await _compressImageNative(nativeImageFile);

            setState(() {
              base64Image = base64Encode(compressedBytes);
            });
            await _controller.storeImage(image: base64Image);

            log("Image selected on Native: Original: $originalSize bytes, Compressed: ${compressedBytes.lengthInBytes} bytes");
          } else {
            log("File does not exist: ${pickedFile.path}");
          }
        }
      } else {
        log("No image selected.");
      }
    } catch (e) {
      log("Error picking image: $e");
      showError(message: 'Failed to process image. Please try again.');
    }
  }

  /// Compress image for web platform
  Future<Uint8List> _compressImageWeb(Uint8List imageBytes) async {
    try {
      // Decode the image
      final codec = await ui.instantiateImageCodec(
        imageBytes,
        targetWidth: 800,
        targetHeight: 800,
      );
      final frame = await codec.getNextFrame();

      // Convert to PNG format (better compression for web)
      final byteData =
          await frame.image.toByteData(format: ui.ImageByteFormat.png);
      final compressedBytes = byteData!.buffer.asUint8List();

      // If compressed is larger than original, return original
      if (compressedBytes.lengthInBytes > imageBytes.lengthInBytes) {
        return imageBytes;
      }

      return compressedBytes;
    } catch (e) {
      log("Error compressing image on web: $e");
      // Return original if compression fails
      return imageBytes;
    }
  }

  /// Compress image for native platforms (Android/iOS)
  Future<Uint8List> _compressImageNative(File imageFile) async {
    try {
      // Read original image bytes
      final originalBytes = await imageFile.readAsBytes();

      // Decode the image
      final codec = await ui.instantiateImageCodec(
        originalBytes,
        targetWidth: 800,
        targetHeight: 800,
      );
      final frame = await codec.getNextFrame();

      // Convert to PNG format
      final byteData =
          await frame.image.toByteData(format: ui.ImageByteFormat.png);
      final compressedBytes = byteData!.buffer.asUint8List();

      // If compressed is larger than original, return original
      if (compressedBytes.lengthInBytes > originalBytes.lengthInBytes) {
        return originalBytes;
      }

      return compressedBytes;
    } catch (e) {
      log("Error compressing image on native: $e");
      // Return original if compression fails
      return await imageFile.readAsBytes();
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
