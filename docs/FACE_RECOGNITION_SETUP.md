# Face Recognition Integration Setup

This guide explains how to integrate your local face recognition server (running on port 3000) with your Flutter app.

## Flutter App Changes Made

### 1. New Face Recognition Screen
- Created `lib/src/user/dashboard/list_screen/attendance/face_recognition/face_recognition.dart`
- Features:
  - WebView integration for real-time camera feed
  - HTTP API communication with your server
  - Connection status monitoring
  - Start/Stop recognition controls
  - Recognition results display

### 2. Updated Dependencies
- Added `webview_flutter: ^4.4.4` to `pubspec.yaml`
- Run `flutter pub get` to install the new dependency

### 3. Connected Face Recognition Button
- Updated the "Face Recognition" button in `list_of_students.dart`
- Now navigates to the new FaceRecognitionScreen

## Local Server Setup

### 1. Install Node.js Dependencies
```bash
# In your project root directory
npm install
```

### 2. Start the Server
```bash
# Start the server
npm start

# Or for development with auto-restart
npm run dev
```

The server will run on `http://localhost:3000`

### 3. Server Endpoints

#### GET `/` - Main Interface
- Serves the camera interface with real-time face recognition
- Displays video feed and recognition controls

#### GET `/health` - Health Check
- Returns server status
- Used by Flutter app to check connection

#### POST `/api/recognize` - Recognition API
- Accepts base64 encoded images
- Returns recognition results in JSON format

## API Format

### Request to `/api/recognize`
```json
{
  "image": "base64_encoded_image_data",
  "timestamp": 1234567890123
}
```

### Response from `/api/recognize`
```json
{
  "success": true,
  "student": "John Doe",
  "studentId": "001",
  "confidence": 0.95,
  "timestamp": 1234567890123
}
```

## Flutter App Usage

1. **Start the Local Server**
   - Run `npm start` in your project directory
   - Server should be accessible at `http://localhost:3000`

2. **Use Face Recognition in Flutter**
   - Navigate to the attendance screen
   - Click the "Face Recognition" button
   - The app will open the face recognition screen
   - Click "Start Recognition" to begin face detection
   - Recognition results will appear above the camera feed

## Customization

### Server URL Configuration
- Default server URL is `http://localhost:3000`
- Can be changed in the Flutter app using the settings button
- For Android emulator, use `http://10.0.2.2:3000`
- For iOS simulator, use `http://localhost:3000`

### Integrating with Your Existing Server
If you already have a face recognition server:

1. **Update the server endpoints** in `face_recognition.dart`:
   ```dart
   // Change these URLs to match your server
   final RxString serverUrl = 'http://your-server-url:3000'.obs;
   ```

2. **Modify the API format** to match your server's response format

3. **Update the WebView URL** to point to your camera interface

## Troubleshooting

### Connection Issues
- Make sure your server is running on port 3000
- Check firewall settings
- For Android emulator, use `10.0.2.2` instead of `localhost`

### Camera Permission
- The Flutter app will request camera permissions
- Make sure to grant camera access when prompted

### WebView Issues
- Ensure `webview_flutter` package is properly installed
- Run `flutter clean` and `flutter pub get` if needed

## Next Steps

1. **Replace Mock Recognition**: Update the server's `/api/recognize` endpoint with your actual face recognition logic
2. **Add Student Database**: Connect to your student database for real recognition results
3. **Improve UI**: Customize the camera interface to match your app's design
4. **Add Error Handling**: Implement better error handling for network issues

## Files Created/Modified

- ✅ `lib/src/user/dashboard/list_screen/attendance/face_recognition/face_recognition.dart` (new)
- ✅ `lib/src/user/dashboard/list_screen/attendance/student_list/list_of_students.dart` (modified)
- ✅ `pubspec.yaml` (modified - added webview_flutter)
- ✅ `server_example.js` (example server)
- ✅ `package.json` (server dependencies)

Your Flutter app is now ready to work with your local face recognition server!
