# Attendance Flow Implementation

## Overview
This document explains the attendance flow integration between the Flutter app and Next.js face recognition web app using the `classAttendance` collection.

## Flow Description

### 1. Attendance Records Screen
When a user taps on an attendance record card in the Attendance Records screen, a dialog appears with two options:

- **Manual**: Opens the traditional student list screen for manual attendance marking
- **Face to Face**: Opens a webview with the Next.js face recognition interface

### 2. Face Recognition Integration
When "Face to Face" is selected:
- The app passes the `attendanceId` (from `classAttendance` collection) to the webview
- Opens a webview that loads the Next.js **PUBLIC** face recognition page (no authentication required)
- Passes the `attendanceId` as a URL parameter: `?attendanceId={attendanceId}&autostart=true`

### 3. Next.js Face Recognition (Public Route)
The Next.js face recognition page (`/face-recognition-public`):
- Receives the `attendanceId` via URL parameter
- Loads the `classAttendance` document from Firestore
- Extracts the class schedule from the `class_schedule` field in the attendance document
- Automatically loads students based on department and year level
- Starts face recognition scanning (with `autostart=true`)
- Allows teachers to mark attendance using facial recognition

### 4. Saving Attendance
When the teacher clicks "Save Attendance":
- If `attendanceId` exists: **Updates** the existing `classAttendance` document with face recognition results
- If no `attendanceId`: **Creates** a new `classAttendance` document (standalone face recognition mode)
- Marks all recognized students as "present" with their confidence scores
- Updates statistics (present_count, absent_count, total_students)

## Files Modified

### Flutter App
1. **`FaceAttend/lib/src/user/dashboard/list_screen/attendance/attendance_screen/attendance_screen.dart`**
   - Added `_showAttendanceMethodDialog()` method
   - Added `_buildAttendanceMethodButton()` widget
   - Modified attendance card `onTap` to show dialog instead of direct navigation
   - Passes `attendanceId` to face recognition page
   - Imported face recognition page

2. **`FaceAttend/lib/src/user/dashboard/list_screen/attendance/face_recognition/face_recognition.dart`**
   - Changed from `scheduleId` to `attendanceId` parameter
   - Updated `_loadFaceRecognitionApp()` to pass `attendanceId` in URL with parameter name `?attendanceId=`

3. **`FaceAttend/lib/src/user/dashboard/list_screen/attendance/student_list/list_of_students.dart`**
   - Updated face recognition button to pass `attendanceId`
   - Removed `scheduleId` parameter (no longer needed)

### Next.js App
1. **`faceattendweb/src/lib/firestore.ts`**
   - Added `getClassAttendanceById()` function to load a specific attendance document

2. **`faceattendweb/src/app/face-recognition-public/page.tsx`** (NEW PUBLIC ROUTE)
   - **Created a public route** that does NOT require authentication
   - Changed from `scheduleId` to `attendanceId` parameter
   - Added `attendanceId` and `attendanceData` state variables
   - Modified `fetchSchedules()` to load attendance document and extract schedule
   - Updated `saveAttendance()` to:
     - Update existing attendance record if `attendanceId` is provided
     - Create new attendance record if no `attendanceId` (standalone mode)
   - **No login required** - can be accessed directly from Flutter webview

## Configuration

### Important: Update the Base URL
In `face_recognition.dart`, update the base URL to match your environment:

```dart
final baseUrl = 'http://192.168.254.104:3001'; // Update this URL
```

**For Production:**
- Replace with your deployed Next.js URL (e.g., `https://yourdomain.com`)

**For Local Development:**
- Use your local IP address (currently set to `192.168.254.104:3001`)
- Ensure your Next.js dev server is running on port 3001

## Testing

1. **Start Next.js Server:**
   ```bash
   cd faceattendweb
   npm run dev
   ```

2. **Run Flutter App:**
   ```bash
   cd FaceAttend
   flutter run
   ```

3. **Test Flow:**
   - Navigate to Attendance Records
   - Tap on any attendance record
   - Select "Face to Face" from the dialog
   - Verify webview opens with face recognition page
   - Check that the schedule is automatically selected

## Troubleshooting

### Issue: Webview shows login page instead of camera
- **Solution**: Use the public route `/face-recognition-public` instead of `/dashboard/face-recognition`
- The public route does NOT require authentication

### Issue: Webview shows blank page
- **Solution**: Ensure Next.js server is running and accessible from your device
- Check the URL in browser first: `https://face-attend-web.vercel.app/face-recognition-public`

### Issue: "Attendance ID not found" error
- **Solution**: Ensure the attendance document exists in the `classAttendance` collection
- Check that the document ID is correctly passed from Flutter

### Issue: Camera permission denied
- **Solution**: Grant camera permission when prompted
- For Android: Check app permissions in device settings

## Next Steps

1. **Deploy Next.js App**: Deploy to Vercel, Netlify, or your preferred hosting
2. **Update Base URL**: Change the URL in `face_recognition.dart` to production URL
3. **SSL Certificate**: Ensure HTTPS is enabled for camera access in production
4. **Testing**: Test on real devices with different network conditions

## Camera Permissions

The face recognition webview requires camera permissions:
- Automatically requested on first launch
- Users can grant permission through the permission dialog
- Required for face detection functionality

