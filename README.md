# PadelApp

A comprehensive iOS application for padel court booking and player matchmaking, built with SwiftUI and Firebase.

## Overview

PadelApp is a full-featured mobile platform that connects padel players, enables court reservations, and facilitates match creation. The app features a complete user management system with skill assessment, real-time booking functionality, and social matchmaking capabilities.

## Features

### User Management
- **Firebase Authentication** - Secure email/password authentication
- **Comprehensive User Profiles** - Personal information, playing preferences, and skill ratings
- **Player Assessment System** - Automated skill rating calculation based on experience and playing frequency
- **Profile Customization** - Playing hand, court position preferences, and experience levels

### Court Booking System
- **Real-time Availability** - Dynamic time slot checking with conflict detection
- **Flexible Duration Selection** - 30-minute to 3-hour booking options
- **Booking Management** - View, modify, and cancel reservations
- **Facility Integration** - Multiple venue support with detailed facility information

### Social Features
- **Open Match Creation** - Create matches and invite players
- **Match Discovery** - Browse and join available matches
- **Player Matching** - Filter matches by skill level, gender preferences, and match type
- **Team Formation** - Automated player grouping for doubles matches

### User Experience
- **SwiftUI Interface** - Modern, responsive design with smooth animations
- **Intuitive Navigation** - Tab-based architecture with contextual navigation flows
- **Real-time Updates** - Live synchronization of booking status and match information
- **Form Validation** - Comprehensive input validation and error handling

## Technical Architecture

### Frontend
- **SwiftUI** - Declarative UI framework for iOS 15+
- **Navigation** - Custom navigation patterns with sheet presentations and programmatic navigation
- **State Management** - Reactive data flow using @State, @Binding, and @ObservedObject
- **UI Components** - Custom reusable components for consistent design

### Backend Integration
- **Firebase Authentication** - User registration, login, and session management
- **Firestore Database** - NoSQL document database for real-time data synchronization
- **Data Modeling** - Structured collections for users, facilities, courts, bookings, and matches
- **Security Rules** - User-based access control and data validation

### Key Components
- **ContentView** - Main app coordinator handling authentication state
- **HomeView** - Dashboard with feature navigation and user statistics
- **BookingView** - Complex booking interface with time slot selection and conflict resolution
- **UserProfileView** - Comprehensive profile management with editing capabilities
- **OpenMatchesView** - Social features for match creation and discovery

## Installation

1. Clone the repository
```bash
git clone https://github.com/AliTaha00/PadelApp.git
cd PadelApp
```

2. Open in Xcode
```bash
open PadelApp.xcodeproj
```

3. Configure Firebase
   - Add your `GoogleService-Info.plist` file to the project
   - Ensure Firebase Authentication and Firestore are enabled in your Firebase console

4. Build and run on iOS Simulator or device (iOS 15.0+)

## Dependencies

- iOS 15.0+
- Xcode 13.0+
- Firebase SDK
  - Firebase Authentication
  - Firebase Firestore

## Data Models

### User
- Personal information and preferences
- Skill rating system with automatic calculation
- Playing style and experience tracking

### Facility & Court
- Venue information with operating hours
- Court specifications and pricing
- Availability management

### Booking
- Time slot reservations with conflict detection
- Status tracking (confirmed, pending, cancelled, completed)
- Price calculation and payment summary

### OpenMatch
- Match creation with player preferences
- Social discovery and joining functionality
- Real-time match status updates

## Future Enhancements

- Push notifications for booking confirmations and match updates
- In-app messaging between players
- Rating and review system for facilities
- Payment integration for seamless transactions
- Advanced analytics and player statistics

## Screenshots

*Add screenshots here showing key app screens*

## Contributing

This is a personal project developed as part of my Computer Science studies at Florida Atlantic University.

## Contact

**Ali Taha**   
Email: alitaha0302@gmail.com  
LinkedIn: [Ali Taha](https://linkedin.com/in/ali-taha-9b6115251)  
GitHub: [AliTaha00](https://github.com/AliTaha00)

---

*Built with SwiftUI and Firebase • Developed December 2024*
