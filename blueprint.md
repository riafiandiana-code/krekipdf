# Project Blueprint

## Overview

A Flutter application for viewing PDF files. Users can open PDFs shared from other apps, received via system intents, or by selecting them directly from their device's local storage.

## Style and Design

- Simple and clean UI.
- Main screen displays the PDF.
- An "Open PDF" button is available on the initial screen if no PDF is loaded.
- An "Open PDF" icon is present in the `AppBar` for quick access.

## Features

- **Default PDF Viewer**: Handles intents to open PDF files from the Android system.
- **Local File Picker**: Allows users to select PDF files from their device's storage.
- **PDF Display**: Renders PDF documents using `flutter_pdfview`.
- **Vertical Scrolling**: PDF pages are scrolled vertically for a natural reading experience.

## Implementation Plan

1.  **Add Dependencies**: Add `flutter_pdfview`, `receive_sharing_intent`, and `file_picker` to the `pubspec.yaml` file.
2.  **Configure Android Manifest**: Modify `android/app/src/main/AndroidManifest.xml` to set the app as the default PDF handler.
3.  **Update `main.dart`**:
    *   Implement PDF viewing with vertical scrolling.
    *   Handle incoming PDF file intents from `receive_sharing_intent`.
    *   Add a button and `AppBar` icon to trigger the `file_picker`.
    *   Load and display the file selected via `file_picker`.
4.  **Error Checking and Validation**: Ensure the app runs without errors, correctly opens PDFs from all sources, and handles build configuration issues (like JVM target compatibility).
