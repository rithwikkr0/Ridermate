// Firebase configuration file
// To use this app with Firebase:
// 1. Create a Firebase project at https://console.firebase.google.com/
// 2. Add your Android/iOS app to the project
// 3. Download google-services.json (Android) and GoogleService-Info.plist (iOS)
// 4. Place them in the respective directories:
//    - android/app/google-services.json
//    - ios/Runner/GoogleService-Info.plist
// 5. Enable Firebase Storage and Firestore in the Firebase console
// 6. Set up security rules for Firestore and Storage

// Example Firestore Security Rules:
/*
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /memories/{memoryId} {
      // Allow read if:
      // - Memory is public
      // - User is the owner
      // - Memory is friends-only and user is a friend
      allow read: if resource.data.visibility == 'public' 
                  || resource.data.userId == request.auth.uid
                  || (resource.data.visibility == 'friends' && isFriend(resource.data.userId));
      
      // Allow create if authenticated
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
      
      // Allow update/delete if owner
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
*/

// Example Storage Security Rules:
/*
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /memories/{userId}/{allPaths=**} {
      // Allow read based on authentication
      allow read: if request.auth != null;
      
      // Allow write only to own directory, with size limit
      allow write: if request.auth != null 
                   && request.auth.uid == userId
                   && request.resource.size < 5 * 1024 * 1024; // 5MB limit
    }
  }
}
*/
