# TrackMyAttendance

The Attendance App is a mobile application built with Flutter to streamline attendance tracking. Users can sign up, take a photo, and capture their check-in/check-out location and time. The app also provides a history view, attendance insights, and monthly reports, making it an ideal solution for individuals and businesses looking to enhance attendance management.

## Features

**• User Sign-Up & Profile Management:** Allows users to sign up, upload their profile picture, and store contact details for easy account access.  
**• Attendance Tracking:** Users can check in and out daily, capturing their location, timestamp, and a verification photo.  
**• Attendance History:** Provides an 11-day history view, showing if the user was late, worked overtime, and total working hours for each day. Users can search for attendance by specific dates.  
**• Monthly Attendance Report:** Visual representation of attendance in a pie chart format.  
**• Location Mapping:** Displays check-in/check-out locations on a map with a red pin marker.  
**• Secure Data Storage:** All data is stored securely using Firebase.

## Technologies Used

**• Flutter:** Cross-platform framework for the app’s UI and functionality.  
**• Firebase:** Backend storage and authentication.  
**• Geolocator:** For capturing user location.  
**• Image Picker:** To capture user photos during check-in and check-out.  
**• Flutter Map:** To visualize user locations on a map.  
**• fl_chart:** For creating pie charts that visualize attendance data.  

## Installation
To get a local copy up and running, follow these steps:

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-username/attendance-app.git
   
2. **Navigate to the project directory**:
   ```bash
   cd attendance-app  
  
3. **Install dependencies**:
   ```bash
   flutter pub get
   
4. **Run the app**:
   ```bash
   flutter run


## Usage

1. **Sign Up**: Register as a new user with a profile picture.  
2. **Check-In/Check-Out:** Tap the attendance button to record check-in or check-out time, location, and a photo.  
3. **View Attendance History:** Access the history screen to review attendance over the last week or by specific dates.  
4. **View Monthly Report:** Check monthly attendance trends displayed in a pie chart.  
5. **Sign Out:** Sign out securely from the settings screen.

## Contributing 
Contributions are welcome! If you have ideas or suggestions, please fork the repository and create a pull request. You can also open an issue with the tag "enhancement".

To contribute:

Fork the Project
Create a Feature Branch:
bash
Copy code
git checkout -b feature/AmazingFeature
Commit Your Changes:
bash
Copy code
git commit -m 'Add some AmazingFeature'
Push to the Branch:
bash
Copy code
git push origin feature/AmazingFeature
Open a Pull Request
