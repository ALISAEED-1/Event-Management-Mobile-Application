# Event Management Mobile App

A two-sided Flutter mobile app for discovering and managing community events,
built with Firebase Auth and Firestore (accessed via REST to bypass gRPC).

## Features

### User side
- Sign up / sign in with Firebase Auth
- Browse upcoming events with calendar + list views
- Filter events by city, state, and category
- Favorite events (synced to your Firestore profile)
- Vote on community proposals — real-time vote counts
- View group profiles and their event feeds
- Light / dark theme support

### Admin side
- Hardcoded admin login (single-credential demo)
- Create new events (with image, date/time, location, details)
- Create polls / votes for the community
- View all events with the same filtering experience as users
- Persistent admin "favorites" list (in-memory + best-effort Firestore sync)
- Manage the group profile feed

## Tech stack
- **Flutter** (Material 3, Google Fonts)
- **Firebase Auth** for user authentication
- **Cloud Firestore** via REST API (bypasses gRPC for networks where it's blocked)
- `table_calendar`, `smooth_page_indicator`, `image_picker`, `http`, `provider`

## Project structure
- `lib/user/` — user-facing screens (home, features, community, favorites, profile)
- `lib/admin/` — admin screens (home, create event/vote, profile, group)
- `lib/backend/` — models and services (events, votes, users, favorites)
- `lib/backend/services/firestore_rest_service.dart` — shared REST wrapper

## Admin credentials (demo)
- Email: `admin@interntask.com`
- Password: `Admin@1234`
