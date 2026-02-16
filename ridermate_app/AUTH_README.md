# RiderMate Authentication & User Profile System

This document provides an overview of the authentication and user profile system implemented in RiderMate.

## Features

### Authentication
- ✅ Email/Password sign-up and login
- ✅ Google Sign-In (OAuth)
- ✅ Anonymous mode (guest access)
- ✅ Password reset via email
- ✅ Email verification
- ✅ Password strength validation (minimum 8 characters with uppercase, lowercase, and number)
- ✅ Session management with Firebase
- ✅ Persistent login
- ✅ Secure token management

### User Profile
- ✅ Complete user data model with:
  - Basic info (name, email, photo, bio, phone)
  - Privacy settings (public/friends-only/private)
  - Riding statistics (rides, distance, points, safety score, streak)
  - Preferences (language, notifications)
- ✅ Profile photo upload and management
- ✅ Edit profile functionality
- ✅ Account settings management

### Privacy System
- ✅ Three privacy modes: Public, Friends-Only, Private
- ✅ Location sharing controls
- ✅ Memory visibility settings
- ✅ Friend request settings
- ✅ Block list management
- ✅ Privacy-based data filtering

### UI Components

#### Authentication Screens
1. **LoginPage** - Email/password login with Google Sign-In option
2. **SignUpPage** - Registration with password strength meter
3. **PasswordResetPage** - Password recovery flow
4. **AuthGuard/AuthWrapper** - Route protection

#### Profile Screens
1. **UserProfilePage** - Display user info and statistics
2. **EditProfilePage** - Update profile information and privacy
3. **SettingsPage** - Comprehensive settings management including:
   - Account settings (password, email)
   - Privacy settings
   - Notification preferences
   - App preferences (theme, language, units)
   - Account deletion

### Services

#### AuthenticationService
Handles all Firebase Authentication operations:
- User registration and login
- Google authentication
- Anonymous sign-in
- Password management
- Email verification
- Token management

#### UserProfileService
Manages user data in Firestore:
- CRUD operations for user profiles
- Settings management
- Privacy settings
- Profile photo uploads
- User statistics updates

#### PrivacyService
Enforces privacy rules:
- Permission checking
- Data filtering based on privacy settings
- Block list management
- Location sharing controls

#### AuthProvider
State management for authentication:
- Reactive auth state
- User profile synchronization
- Error handling
- Loading states

## File Structure

```
lib/
├── models/
│   ├── user_model.dart           # User data model
│   ├── user_settings.dart        # User preferences model
│   └── privacy_settings.dart     # Privacy configuration model
├── services/
│   ├── authentication_service.dart   # Firebase Auth operations
│   ├── user_profile_service.dart    # Firestore user operations
│   ├── privacy_service.dart         # Privacy enforcement
│   └── auth_provider.dart           # State management
├── screens/
│   ├── login_page.dart             # Login UI
│   ├── signup_page.dart            # Registration UI
│   ├── password_reset_page.dart    # Password recovery UI
│   ├── user_profile_page.dart      # Profile display
│   ├── edit_profile_page.dart      # Profile editing
│   └── settings_page.dart          # Settings management
├── guards/
│   └── auth_guard.dart             # Route protection
└── utils/
    └── validation_utils.dart       # Form validation helpers
```

## Security Features

### Firebase Security Rules
- Users can only read/write their own data
- Public profiles visible to all authenticated users
- Friend-only data requires friendship verification
- Private data only visible to owner
- Profile photos size-limited to 5MB
- Only image uploads allowed for photos

### Validation
- Email format validation
- Password strength requirements:
  - Minimum 8 characters
  - At least one uppercase letter
  - At least one lowercase letter
  - At least one number
- Phone number format validation
- Input sanitization to prevent XSS

### Authentication Security
- Email verification required for full access
- Secure password storage (handled by Firebase)
- Session timeout management
- JWT token refresh
- Rate limiting (Firebase built-in)

## Usage

### Basic Authentication Flow

```dart
// Sign up
final authProvider = Provider.of<AuthProvider>(context, listen: false);
await authProvider.signUpWithEmailPassword(
  email: email,
  password: password,
  name: name,
);

// Sign in
await authProvider.signInWithEmailPassword(
  email: email,
  password: password,
);

// Google Sign-In
await authProvider.signInWithGoogle();

// Sign out
await authProvider.signOut();
```

### Profile Management

```dart
// Update profile
await authProvider.updateProfile({
  'name': 'New Name',
  'bio': 'Updated bio',
  'privacyMode': 'friends-only',
});

// Upload profile photo
final photoUrl = await userProfileService.uploadProfilePhoto(userId, imageFile);
```

### Privacy Checks

```dart
// Check if user can view profile
final canView = await privacyService.canViewProfile(
  targetUserId: targetUserId,
  requestingUserId: currentUserId,
);

// Check location sharing permission
final canViewLocation = await privacyService.canViewLocation(
  targetUserId: targetUserId,
  requestingUserId: currentUserId,
);
```

## Protected Routes

All authenticated routes are protected by the `AuthGuard`:

```dart
home: AuthWrapper(),  // Automatically routes to login if not authenticated
```

Protected pages include:
- Home/Dashboard
- Ride tracking
- User profile
- Settings
- History
- Memories
- Friends

## Error Handling

The system handles various error scenarios:
- Invalid email format
- Weak password
- Email already exists
- User not found
- Incorrect password
- Network errors
- Firebase errors
- Session expiration

All errors are displayed with user-friendly messages.

## Testing Checklist

- [ ] Email/password registration
- [ ] Email/password login
- [ ] Google Sign-In
- [ ] Anonymous login
- [ ] Password reset email
- [ ] Email verification
- [ ] Profile viewing
- [ ] Profile editing
- [ ] Photo upload
- [ ] Privacy settings
- [ ] Notification settings
- [ ] Password change
- [ ] Email update
- [ ] Account deletion
- [ ] Logout
- [ ] Route protection

## Future Enhancements

- Two-factor authentication
- Biometric authentication
- Social media login (Facebook, Apple)
- Profile verification badges
- Advanced privacy controls
- Activity logs
- Session management UI
- Security notifications
