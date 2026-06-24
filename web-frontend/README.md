# RiderMate GPS Ride Tracking System - Web Frontend

A real-time GPS ride tracking web application built with React, TypeScript, and Leaflet.

## Features

### 1. GPS Tracking Hook (`useGPSTracking`)
- Uses `navigator.geolocation.watchPosition()` for real-time location tracking
- Tracks latitude, longitude, speed, timestamp, and accuracy
- Update frequency: 1-3 seconds (configurable)
- Handles permission requests and errors
- Returns current location, location history, and accuracy

### 2. Ride Tracking Service (`useRideTracking`)
- **Start Ride**: Initialize tracking session with start time
- **Pause Ride**: Stop distance accumulation while maintaining session
- **Resume Ride**: Continue tracking without resetting metrics
- **End Ride**: Finalize all metrics and save session data

#### Calculated Metrics:
- Distance using Haversine formula (km)
- Duration (current time - start time, excluding paused time)
- Current speed, average speed, maximum speed (km/h)
- Overspeed detection (>60 km/h threshold)

### 3. Leaflet Map Component
- OpenStreetMap tiles integration
- Real-time current location marker (blue)
- Start point marker (green)
- End point marker (red)
- Live route polyline visualization
- Auto-centering on current location
- Built-in zoom controls
- Responsive design
- Map legend

### 4. Ride Tracking UI
- **Start Ride** button (with GPS acquisition status)
- **Pause/Resume** buttons (conditionally shown)
- **End Ride** button
- Real-time metrics display:
  - Current Speed (primary metric, large display)
  - Distance Traveled
  - Time Elapsed
  - Average Speed
  - Max Speed
  - Overspeed Count
- Map container with full tracking visualization
- Status indicators (Ready, Tracking, Paused, Completed)
- GPS accuracy indicator
- Error display banners

### 5. Utility Functions
- `calculateHaversineDistance()`: Accurate distance calculation between GPS coordinates
- `mpsToKmh()`: Speed conversion from m/s to km/h
- `isValidCoordinate()`: Coordinate validation
- `isAccurateLocation()`: Accuracy threshold checking
- `formatDuration()`: Time formatting (MM:SS)
- `getGPSErrorMessage()`: User-friendly error messages
- `convertGeolocationError()`: Error type conversion
- `calculateAverageSpeed()`: Average speed from location history

### 6. TypeScript Types
```typescript
- LocationPoint: { latitude, longitude, speed, timestamp, accuracy }
- RideMetrics: { distance, duration, currentSpeed, avgSpeed, maxSpeed, overspeeds }
- RideState: IDLE | TRACKING | PAUSED | COMPLETED
- GPSErrorType: PERMISSION_DENIED | POSITION_UNAVAILABLE | TIMEOUT | UNSUPPORTED | UNKNOWN
- GPSError: { type, message }
- RideSession: Complete ride session data structure
```

### 7. Error Handling
- GPS permission denied - Clear instructions to enable location
- GPS timeout - Retry suggestions
- Position unavailable - GPS settings check
- Inaccurate location - Validation and filtering
- Network issues - Graceful degradation
- User-friendly error messages with icons
- Visual error banners

## Installation

```bash
cd web-frontend
npm install
```

## Development

```bash
npm run dev
```

The application will start on http://localhost:5173

## Build

```bash
npm run build
```

## Technologies Used

- **React 18**: UI framework
- **TypeScript**: Type-safe development
- **Vite**: Build tool and dev server
- **Leaflet**: Map visualization
- **React-Leaflet**: React bindings for Leaflet
- **OpenStreetMap**: Map tiles provider

## Project Structure

```
src/
├── types/
│   └── index.ts              # TypeScript type definitions
├── hooks/
│   ├── useGPSTracking.ts     # GPS tracking hook
│   └── useRideTracking.ts    # Ride session management hook
├── utils/
│   └── gpsUtils.ts           # Utility functions for GPS calculations
├── components/
│   └── MapComponent.tsx      # Leaflet map component
├── pages/
│   ├── RideTrackingPage.tsx  # Main ride tracking page
│   └── RideTrackingPage.css  # Page styles
├── App.tsx                   # Main app component
└── main.tsx                  # App entry point
```

## Usage

1. **Starting a Ride**:
   - Click "Start Ride" button
   - Allow location permissions when prompted
   - Wait for GPS signal acquisition
   - Ride tracking begins automatically

2. **During a Ride**:
   - View real-time metrics on screen
   - Monitor current speed and distance
   - Track route on map
   - Receive overspeed warnings when exceeding 60 km/h

3. **Pausing/Resuming**:
   - Click "Pause" to temporarily stop tracking
   - Distance accumulation stops but session is maintained
   - Click "Resume" to continue tracking
   - Paused time is excluded from duration calculations

4. **Ending a Ride**:
   - Click "End Ride" when finished
   - View final statistics
   - Session data is logged (ready for backend integration)

## Browser Compatibility

- Chrome/Edge: ✅ Full support
- Firefox: ✅ Full support
- Safari: ✅ Full support (requires HTTPS)
- Mobile browsers: ✅ Supported (requires HTTPS)

**Note**: GPS tracking requires HTTPS in production environments and user permission.

## Future Enhancements

- Backend integration for ride history storage
- User authentication
- Social features (share rides, leaderboards)
- Route planning and navigation
- Offline mode with local storage
- Advanced statistics and analytics
- Export ride data (GPX, KML formats)
