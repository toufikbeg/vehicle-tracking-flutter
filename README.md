# GPS Vehicle Tracking System - Flutter App

## Overview
Flutter mobile application for GPS based vehicle tracking system.
Consumes FastAPI backend APIs to display real time vehicle location.

## Tech Stack
- Flutter (Dart)
- Provider for State Management
- Dio for HTTP requests
- Flutter Secure Storage for token storage
- Google Maps Flutter for map view

## Features
- Login Screen with JWT authentication
- Home Screen with route and vehicle details
- Live GPS location display
- Vehicle status display
- Auto refresh every 5 seconds
- Error handling and loading states

## Setup and Run

### Requirements
- Flutter SDK
- Android Studio or VS Code

### Steps
git clone https://github.com/toufikbeg/vehicle-tracking-flutter
cd vehicle-tracking-flutter/gps_tracking_app
flutter pub get
flutter run

## Test Users
Username: user_a | Password: password123 | Route: City Center to Airport | Vehicle: BUS-001
Username: user_b | Password: password123 | Route: University to Tech Park | Vehicle: BUS-002

## App Flow
1. User opens app
2. Login screen appears
3. User enters credentials
4. Backend validates and returns JWT token
5. Home screen shows assigned route and vehicle
6. GPS location updates every 5 seconds
7. User can logout anytime

## Backend Connection
Update lib/config/app_config.dart with your backend URL

static const String baseUrl = 'YOUR_BACKEND_URL/api';

## Screens
- Login Screen - Authenticate with username and password
- Home Screen - View assigned route vehicle and GPS location

## Security
- JWT token stored securely
- Token sent with every API request
- User can only see their assigned route and vehicle
- Backend enforces all authorization