# RiderMate Authentication System Architecture

## System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        RiderMate App                              │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                     UI Layer                              │  │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐   │  │
│  │  │  Login   │ │  SignUp  │ │ Password │ │  Profile │   │  │
│  │  │   Page   │ │   Page   │ │  Reset   │ │   Page   │   │  │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘   │  │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐               │  │
│  │  │   Edit   │ │ Settings │ │   Home   │               │  │
│  │  │ Profile  │ │   Page   │ │  Screen  │               │  │
│  │  └──────────┘ └──────────┘ └──────────┘               │  │
│  └────────────────────┬─────────────────────────────────────┘  │
│                       │                                         │
│  ┌────────────────────▼─────────────────────────────────────┐  │
│  │              State Management (Provider)                  │  │
│  │  ┌──────────────────────────────────────────────────┐   │  │
│  │  │            AuthProvider                          │   │  │
│  │  │  - Authentication State                          │   │  │
│  │  │  - User Profile State                            │   │  │
│  │  │  - Loading & Error States                        │   │  │
│  │  └──────────────────────────────────────────────────┘   │  │
│  └────────────────────┬─────────────────────────────────────┘  │
│                       │                                         │
│  ┌────────────────────▼─────────────────────────────────────┐  │
│  │                  Service Layer                            │  │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐        │  │
│  │  │    Auth     │ │   Profile   │ │   Privacy   │        │  │
│  │  │   Service   │ │   Service   │ │   Service   │        │  │
│  │  └─────────────┘ └─────────────┘ └─────────────┘        │  │
│  └────────────────────┬─────────────────────────────────────┘  │
│                       │                                         │
│  ┌────────────────────▼─────────────────────────────────────┐  │
│  │                  Guards & Utils                           │  │
│  │  ┌─────────────┐ ┌─────────────────────────────────┐    │  │
│  │  │  AuthGuard  │ │   Validation Utils              │    │  │
│  │  │  (Routes)   │ │   - Email, Password, Phone      │    │  │
│  │  └─────────────┘ └─────────────────────────────────┘    │  │
│  └────────────────────┬─────────────────────────────────────┘  │
│                       │                                         │
└───────────────────────┼─────────────────────────────────────────┘
                        │
        ┌───────────────┴───────────────┐
        │                               │
        ▼                               ▼
┌───────────────┐              ┌──────────────────┐
│   Firebase    │              │    Firebase      │
│     Auth      │              │    Firestore     │
│               │              │                  │
│ • Email/Pass  │              │ • users/         │
│ • Google      │              │ • user_settings/ │
│ • Anonymous   │              │ • user_privacy/  │
│ • Tokens      │              │                  │
└───────────────┘              └──────────────────┘
        │                               │
        └───────────────┬───────────────┘
                        │
                        ▼
                ┌──────────────────┐
                │    Firebase      │
                │    Storage       │
                │                  │
                │ • Profile Photos │
                │ • Memory Photos  │
                │ • Ride Photos    │
                └──────────────────┘
```

## Data Flow Diagrams

### 1. Sign Up Flow
```
User Input → SignUpPage → Validation
              ↓
        AuthProvider.signUpWithEmailPassword()
              ↓
        AuthenticationService.signUpWithEmailPassword()
              ↓
        Firebase Auth (Create User)
              ↓
        UserProfileService.createUserProfile()
              ↓
        Firestore (Create Documents)
              ├── users/{userId}
              ├── user_settings/{userId}
              └── user_privacy/{userId}
              ↓
        Email Verification Sent
              ↓
        Redirect to Home
```

### 2. Login Flow
```
User Input → LoginPage → Validation
              ↓
        AuthProvider.signInWithEmailPassword()
              ↓
        AuthenticationService.signInWithEmailPassword()
              ↓
        Firebase Auth (Verify Credentials)
              ↓
        UserProfileService.getUserProfile()
              ↓
        Firestore (Fetch User Data)
              ↓
        AuthProvider (Update State)
              ↓
        Redirect to Home
```

### 3. Profile Update Flow
```
User Input → EditProfilePage → Validation
              ↓
        Image Selected? → UserProfileService.uploadProfilePhoto()
              ↓                    ↓
        AuthProvider.updateProfile()  Firebase Storage
              ↓                    ↓
        UserProfileService.updateUserProfile()
              ↓
        Firestore (Update Document)
              ↓
        AuthProvider.loadUserProfile()
              ↓
        UI Updates (Reactive)
```

### 4. Privacy Check Flow
```
Request → PrivacyService.canViewProfile()
              ↓
        Get Privacy Settings from Firestore
              ↓
        Check Permission Rules:
              ├── Is Owner? → Allow
              ├── Is Public? → Allow
              ├── Is Friends-Only? → Check Friendship
              └── Is Private? → Deny
              ↓
        Return Permission Result
```

## Component Dependencies

```
main.dart
    └── Initializes Firebase
    └── Creates AuthProvider
    └── Launches AuthWrapper
            ├── Not Authenticated → LoginPage
            │       ├── SignUpPage
            │       └── PasswordResetPage
            │
            └── Authenticated → HomeScreen
                    ├── UserProfilePage
                    │       └── EditProfilePage
                    └── SettingsPage
```

## Security Architecture

```
┌────────────────────────────────────────────────────┐
│              Client (Flutter App)                   │
│                                                     │
│  ┌──────────────────────────────────────────────┐ │
│  │  Input Validation (Client-side)              │ │
│  │  - Email format                              │ │
│  │  - Password strength                         │ │
│  │  - Phone number format                       │ │
│  │  - Input sanitization                        │ │
│  └──────────────────────────────────────────────┘ │
│                      │                             │
└──────────────────────┼─────────────────────────────┘
                       │
                       ▼
┌────────────────────────────────────────────────────┐
│            Firebase Authentication                  │
│                                                     │
│  • Password hashing                                │
│  • Token generation                                │
│  • Session management                              │
│  • Email verification                              │
│  • Rate limiting                                   │
└──────────────────┬───────────────────────────────┘
                   │
                   ▼
┌────────────────────────────────────────────────────┐
│            Firestore Security Rules                 │
│                                                     │
│  match /users/{userId} {                           │
│    allow read: if isOwner(userId)                  │
│             || isPublicProfile(userId);            │
│    allow write: if isOwner(userId);                │
│  }                                                  │
│                                                     │
│  match /user_settings/{userId} {                   │
│    allow read, write: if isOwner(userId);          │
│  }                                                  │
└──────────────────┬───────────────────────────────┘
                   │
                   ▼
┌────────────────────────────────────────────────────┐
│            Storage Security Rules                   │
│                                                     │
│  match /profile_photos/{userId}.{ext} {            │
│    allow read: if true;                            │
│    allow write: if isOwner(userId)                 │
│              && isImage()                          │
│              && isValidSize();                     │
│  }                                                  │
└────────────────────────────────────────────────────┘
```

## Model Relationships

```
User
├── userId (Primary Key)
├── email
├── name
├── profilePhoto → Firebase Storage
├── bio
├── phoneNumber
├── dateOfJoined
├── privacyMode → PrivacySettings
├── statistics (totalRides, totalDistance, etc.)
└── preferences → UserSettings

UserSettings
├── userId (Foreign Key to User)
├── notifications (email, push, frequency)
├── theme (light, dark, auto)
├── language
├── units (km, miles)
└── preferredMapStyle

PrivacySettings
├── userId (Foreign Key to User)
├── profileVisibility (public, friends, private)
├── locationSharing (everyone, friends, none)
├── memoryVisibilityDefault
├── friendRequestSettings
├── blockList []
└── locationSharingWith []
```

## Authentication States

```
┌──────────────┐
│ Not          │
│ Authenticated│
└──────┬───────┘
       │
       │ Sign Up / Login / Google / Anonymous
       │
       ▼
┌──────────────┐
│ Authenticated│
│ (No Profile) │
└──────┬───────┘
       │
       │ Create Profile
       │
       ▼
┌──────────────┐
│ Authenticated│
│ (Profile OK) │──────┐
└──────┬───────┘      │
       │              │
       │ Logout       │ Session Timeout
       │              │
       ▼              │
┌──────────────┐      │
│ Signed Out   │◄─────┘
└──────────────┘
```

## Error Handling Flow

```
User Action
    ↓
Try Operation
    ├── Success → Update State → Update UI
    │
    └── Error → Catch Exception
                    ↓
              Map to User-Friendly Message
                    ↓
              Show SnackBar / Dialog
                    ↓
              Log Error (if needed)
                    ↓
              Reset Loading State
```

## File Organization

```
lib/
├── models/                 # Data Models
│   ├── user_model.dart
│   ├── user_settings.dart
│   └── privacy_settings.dart
│
├── services/              # Business Logic
│   ├── authentication_service.dart
│   ├── user_profile_service.dart
│   ├── privacy_service.dart
│   └── auth_provider.dart
│
├── screens/               # UI Pages
│   ├── login_page.dart
│   ├── signup_page.dart
│   ├── password_reset_page.dart
│   ├── user_profile_page.dart
│   ├── edit_profile_page.dart
│   ├── settings_page.dart
│   └── home_screen.dart
│
├── guards/                # Route Protection
│   └── auth_guard.dart
│
├── utils/                 # Utilities
│   └── validation_utils.dart
│
└── main.dart             # Entry Point
```

---

This architecture provides:
✅ Clear separation of concerns
✅ Scalable structure
✅ Secure authentication
✅ Reactive state management
✅ Comprehensive error handling
✅ Privacy enforcement
✅ Modular design
