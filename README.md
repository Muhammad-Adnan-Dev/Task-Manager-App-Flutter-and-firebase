<div align="center">

Task Manager App (Flutter + Firebase)

A full-stack mobile Task Manager application demonstrating real-time sync, CRUD operations, and cloud state management.

</div>

Project Overview

The objective of this project is to provide a clean and efficient interface for managing daily tasks. It connects to a backend database to ensure data persists across sessions and synchronizes instantly between devices.

Features

Real-Time Synchronization: Tasks update instantly across all devices using Firestore Streams.

Create Tasks: Add new tasks with a title, detailed description, and a specific due date.

Edit Tasks: Modify existing task details.

Delete Tasks: Permanently remove tasks from the database.

Status Management: Mark tasks as "Completed" or "Pending" using a checkbox interface.

Cross-Platform Support: Optimized for both Android and Web.

Tech Stack

Component

Technology

Frontend

Flutter (Dart)

Backend

Firebase Cloud Firestore (NoSQL)

State Management

Streams & setState

Dependencies

firebase_core: Initialization of Firebase services.

cloud_firestore: Database management.

intl: Date formatting and handling.

Installation and Setup

Follow these steps to run the project locally.

1. Clone the Repository

git clone [https://github.com/Muhammad-Adnan-Dev/Task-Manager-App-Flutter-and-firebase.git](https://github.com/Muhammad-Adnan-Dev/Task-Manager-App-Flutter-and-firebase.git)
cd Task-Manager-App-Flutter-and-firebase


2. Install Dependencies

flutter pub get


3. Firebase Configuration

For Android:

Create a project in the Firebase Console.

Add an Android app with your package name (found in android/app/build.gradle).

Download the google-services.json file.

Place the file in the android/app/ directory.

Ensure your Firestore Database is set to "Test Mode" for development access.

For Web:
The application code includes configuration keys for the web interface in main.dart. No additional file setup is required for the web version in this specific build.

4. Run the Application

To run on an Android Emulator:

flutter run


To run on Chrome (Web):

flutter run -d chrome


Folder Structure

lib/main.dart: Contains the entry point and all screen logic (Home Screen, Add/Edit Screen).

pubspec.yaml: Manages project dependencies.

android/: Contains Android-specific configuration files.

License

This project is open-source and available under the MIT License.