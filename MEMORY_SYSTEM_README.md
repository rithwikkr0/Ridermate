# RiderMate Memory/Journal System

## Overview
The Memory/Journal System allows RiderMate users to capture and share their cycling experiences with photos, captions, location tags, and privacy controls.

## Features

### 1. Memory Creation
- **Photo Upload**: Capture photos with camera or select from gallery
- **Auto Location Tagging**: GPS coordinates automatically captured
- **Captions**: Add descriptive text to memories
- **Tags**: Organize memories with custom tags
- **Privacy Controls**: Set visibility (Public, Friends, Private)
- **Ride Association**: Link memories to specific rides

### 2. Memory Viewing
- **Gallery View**: Grid or list layout with filtering
- **Map View**: See all memories on an interactive map
- **Detail View**: Full-screen image with all metadata
- **Feed View**: Browse memories from friends

### 3. Interaction
- **Likes**: Show appreciation for memories
- **View Tracking**: See how many times a memory has been viewed
- **Editing**: Update captions and privacy settings
- **Deletion**: Remove memories with confirmation

### 4. Privacy System
- **Public**: Visible to all users
- **Friends**: Visible only to accepted friends
- **Private**: Visible only to the owner

## Technical Implementation

### Models
- **MemoryModel**: Core data structure for memories
- **MemoryVisibility**: Enum for privacy levels
- **MemoryInteraction**: Tracks likes and views

### Services
- **MemoryService**: CRUD operations with Firestore
- **PhotoUploadService**: Image upload to Firebase Storage
- **LocationService**: GPS location tracking
- **ImageCompressionService**: Image optimization

### Screens
- **AddMemoryScreen**: Create new memories
- **MemoryGalleryScreen**: Browse user memories
- **MemoryDetailScreen**: View and edit memory details
- **MemoryMapScreen**: Map view of memories
- **MemoryFeedScreen**: Friend activity feed

### Widgets
- **MemoryCard**: Reusable memory display component

## Setup Instructions

### 1. Firebase Configuration
1. Create a Firebase project at https://console.firebase.google.com/
2. Add your Android/iOS app to the project
3. Download configuration files:
   - `google-services.json` → `android/app/`
   - `GoogleService-Info.plist` → `ios/Runner/`

### 2. Enable Firebase Services
- **Firestore Database**: For storing memory metadata
- **Firebase Storage**: For storing images
- **Firebase Authentication**: For user identification

### 3. Security Rules

#### Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /memories/{memoryId} {
      allow read: if resource.data.visibility == 'public' 
                  || resource.data.userId == request.auth.uid
                  || (resource.data.visibility == 'friends' && isFriend(resource.data.userId));
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
      allow update, delete: if resource.data.userId == request.auth.uid;
    }
    
    match /memory_interactions/{interactionId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow delete: if request.auth.uid == resource.data.userId;
    }
    
    function isFriend(userId) {
      return exists(/databases/$(database)/documents/friendships/$(request.auth.uid + '_' + userId))
          || exists(/databases/$(database)/documents/friendships/$(userId + '_' + request.auth.uid));
    }
  }
}
```

#### Storage Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /memories/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null 
                   && request.auth.uid == userId
                   && request.resource.size < 5 * 1024 * 1024;
    }
  }
}
```

### 4. Google Maps Setup
1. Get an API key from Google Cloud Console
2. Enable Maps SDK for Android and iOS
3. Update `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="YOUR_API_KEY_HERE"/>
   ```
4. Update `ios/Runner/AppDelegate.swift` with your API key

### 5. Dependencies
All required dependencies are in `pubspec.yaml`:
- Firebase packages (core, storage, firestore, auth)
- Image handling (image_picker, flutter_image_compress, cached_network_image)
- Location services (geolocator, permission_handler)
- Maps (google_maps_flutter)
- Utilities (provider, uuid, intl, path_provider)

### 6. Permissions
Configured in:
- `android/app/src/main/AndroidManifest.xml`
- `ios/Runner/Info.plist`

Required permissions:
- Camera
- Photo library
- Location (fine and coarse)
- Internet access

## Usage

### Creating a Memory
1. Navigate to Memories tab
2. Tap "Add Memory" button
3. Select or capture a photo
4. Add caption and tags
5. Location is auto-filled (can be refreshed)
6. Set visibility level
7. Tap "Create Memory"

### Viewing Memories
- **Gallery**: Tap "Gallery" button to see all your memories
- **Map**: Tap "Map" to see memories on an interactive map
- **Feed**: Tap "Feed" to see friends' memories

### Managing Memories
- Tap a memory card to view details
- In detail view:
  - Tap menu (⋮) to edit or delete
  - Tap heart icon to like/unlike
  - View statistics (views, likes)

## Data Structure

### Memory Document (Firestore)
```dart
{
  "memoryId": "string",
  "userId": "string",
  "imageUrl": "string",
  "thumbnailUrl": "string",
  "caption": "string",
  "latitude": double,
  "longitude": double,
  "createdAt": Timestamp,
  "visibility": "public" | "friends" | "private",
  "rideId": "string?" (optional),
  "tags": ["string"],
  "viewCount": int,
  "likeCount": int
}
```

### Memory Interaction Document (Firestore)
```dart
{
  "userId": "string",
  "memoryId": "string",
  "action": "like" | "view",
  "timestamp": Timestamp
}
```

## Performance Optimizations

1. **Image Compression**: All images compressed before upload (max 1920x1080, 85% quality)
2. **Thumbnails**: Auto-generated 300x300 thumbnails for gallery view
3. **Lazy Loading**: Images loaded on demand with caching
4. **Pagination**: Gallery supports efficient pagination
5. **CDN**: Firebase Storage provides automatic CDN distribution

## Error Handling

The system includes comprehensive error handling for:
- File upload failures
- Network errors
- Permission denials
- Storage quota exceeded
- Invalid file formats
- File size violations (>5MB)

All errors display user-friendly messages via SnackBar notifications.

## Future Enhancements

Potential additions:
- Comments on memories
- Memory albums/collections
- Advanced search by location radius
- Memory sharing to social media
- Bulk photo upload
- Video support
- Memory stories/slideshow
- Export memories to PDF

## Support

For issues or questions about the Memory/Journal System, please refer to the main RiderMate documentation or contact support.
