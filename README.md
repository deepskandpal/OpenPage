# OpenPage
AI assisted writing app for macOS

A modern, distraction-free writing application for macOS inspired by the clean design and functionality of Cursor IDE.

## Overview

OpenPage provides a premium writing experience with a clean, focused interface for writers who want to concentrate on their content. It combines elegant design with powerful features that appear only when needed, creating the perfect environment for creative flow.

## Features

- Minimalist, distraction-free writing interface
- Dark/light themes with customizable typography
- Markdown support with live preview
- AI-assisted writing features
- Document organization with tags and folders
- Version history and snapshots
- CloudKit sync across devices
- Export to multiple formats (PDF, DOCX, HTML)
- Command palette for quick actions

## Requirements

- macOS Sonoma 14.0 or later
- Xcode 15 or later
- Swift 5.9 or later

## Getting Started

1. Clone the repository
2. Open `writing_app.xcodeproj` in Xcode
3. Build and run the application

## Technology Stack

- SwiftUI for modern, responsive interface
- SwiftData for document storage and management
- CloudKit for synchronization
- Core ML and OpenAI API for AI features
- Combine framework for reactive programming

## Project Structure

The application follows MVVM architecture with these core components:
- Document Engine for file management and versioning
- UI Layer with customizable editor views
- AI Assistant for writing enhancement
- Theme Engine for personalization
- Data Management with SwiftData and CloudKit 
