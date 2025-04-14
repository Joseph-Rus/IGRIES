# IGRIS

![IGRIS Knight](https://github.com/yourusername/igris/raw/main/Screenshots/igris_logo.png)

## Your College Companion

IGRIS is a powerful, beautifully designed productivity application built specifically for college students. Manage tasks, sync with Blackboard, track your academic progress, and stay motivated with a modern, sleek dark-mode interface.

## Features

### Task Management
- **Create & Organize Tasks**: Add deadlines, descriptions, and course information
- **Smart Dashboard**: Get a quick overview of your day with visual progress indicators
- **Todo List**: Prioritize important tasks and track completion
- **Progress Tracking**: Visualize your daily productivity with elegant progress charts

### LMS Integration
- **Blackboard Calendar Sync**: Automatically import assignments from Blackboard
- **ICS Calendar Support**: Connect to your institution's calendar feed
- **Course Association**: Tasks automatically tagged with the right course

### User Experience
- **Modern Dark Interface**: Eye-friendly design with purple accents
- **Intuitive Navigation**: Streamlined, distraction-free workflow
- **Daily Motivation**: Inspirational quotes to keep you focused
- **Cloud Sync**: Access your tasks across all your devices

## Screenshots

<div align="center">
    <img src="[https://github.com/yourusername/igris/raw/main/Screenshots/dashboard.png](https://github.com/user-attachments/assets/a1af8b96-ca5e-4159-a449-1f8596864236)" width="30%" alt="Dashboard">
Integration">



</div>

## Technical Details

### Built With
- **SwiftUI**: Modern declarative UI framework
- **Firebase**: Authentication, Firestore database, and cloud storage
- **Custom Theme Engine**: Dynamic UI styling with ThemeManager
- **ICS Parser**: Calendar integration with educational platforms

### Architecture
- **MVVM Pattern**: Clean separation of concerns
- **Theme Management**: Consistent styling throughout the app
- **Notification System**: Smart reminders for upcoming deadlines

## Installation

### Requirements
- iOS 15.0+
- Xcode 13.0+
- Active Firebase account

### Setup
1. Clone the repository
```bash
git clone https://github.com/yourusername/igris.git
```

2. Install CocoaPods dependencies
```bash
cd igris
pod install
```

3. Open the workspace
```bash
open IGRIS.xcworkspace
```

4. Configure Firebase
   - Create a Firebase project
   - Add your iOS app to the Firebase project
   - Download the `GoogleService-Info.plist` file
   - Add it to the project root

5. Build and run

## Usage Guide

### Getting Started
1. Create an account or sign in
2. Explore the dashboard to see your daily tasks and progress
3. Add tasks through the "+" button on the home screen
4. Connect to Blackboard using the Calendar Help feature

### Blackboard Calendar Integration
1. Log in to your Blackboard account
2. Navigate to Calendar in the sidebar
3. Access calendar settings via the gear icon
4. Select "Share Calendar" from the dropdown menu
5. Copy the ICS URL
6. In IGRIS, go to Tasks → Calendar Feed and paste the URL

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- The amazing Swift and SwiftUI community
- Firebase team for their excellent documentation
- All college students whose feedback shaped this app

---

Built with ❤️ for students by students
