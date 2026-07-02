# GymFlow - Multi-Gym Management Platform

A production-ready gym management application built for **ROCKFORT PLANET GYM FITNESS** and designed as a scalable multi-gym SaaS platform.

## Architecture

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Flutter Mobile │     │  React Admin    │     │  Node.js API    │
│  App (Android)  │────▶│  Dashboard      │────▶│  (Express)      │
│                 │     │  (future)       │     │                 │
└─────────────────┘     └─────────────────┘     └────────┬────────┘
                                                          │
                                                          ▼
                                                 ┌─────────────────┐
                                                 │    Supabase     │
                                                 │  (PostgreSQL +  │
                                                 │   Auth + Store) │
                                                 └─────────────────┘
```

## Project Structure

```
E:\GymApp\
├── database/             # SQL schema & migrations
│   └── schema.sql        # Complete DB schema (13 tables, RLS, triggers)
├── gymflow_backend/      # Node.js + Express API
│   ├── src/
│   │   ├── config/       # Supabase, Razorpay init
│   │   ├── middleware/    # Auth, validation, file upload
│   │   ├── routes/       # 15 route modules
│   │   ├── controllers/  # Business logic
│   │   └── services/     # External integrations
│   ├── package.json
│   └── .env.example
├── gymflow_mobile/       # Flutter Android App
│   ├── lib/
│   │   ├── config/       # Theme, routes, constants
│   │   ├── models/       # User, Member, Payment, Workout, etc.
│   │   ├── providers/    # Riverpod state management
│   │   ├── services/     # API client
│   │   ├── screens/      # 25+ screens (auth, admin, trainer, member)
│   │   └── widgets/      # Reusable components
│   └── pubspec.yaml
└── docs/                 # Documentation
```

## Features Implemented

### Authentication & Multi-Gym
- Email/password login & registration
- Role-based access (Admin, Trainer, Member, Super Admin)
- Forgot password flow
- Gym selection on login
- User profile management

### Admin Module
- Dashboard with 6 stat cards (members, attendance, revenue, trainers)
- Member CRUD with search & status filters
- Trainer CRUD with specialization & assignment
- Membership plans management
- Attendance logs with check-in/out tracking
- Payment history with revenue overview
- Reports (revenue breakdown by month & plan)
- Notification viewer & sender

### Trainer Module
- Dashboard with assigned members & today's schedule
- View assigned members with membership status
- Create workout plans with exercise library
- Create diet plans with meal scheduling
- Mark workouts complete

### Member Module
- Dashboard with membership card & progress overview
- View attendance history
- View & complete workouts
- View diet plans with meal details
- Track progress (weight, BMI, body measurements)
- View membership details & renew

## Tech Stack

| Component | Technology |
|-----------|------------|
| Mobile App | Flutter + Riverpod + GoRouter |
| Backend API | Node.js + Express.js |
| Database | Supabase (PostgreSQL) |
| Authentication | Supabase Auth |
| File Storage | Supabase Storage |
| Payments | Razorpay |
| State Management | Riverpod (Flutter) |

## Setup Guide

### 1. Supabase Setup
1. Create a free account at [supabase.com](https://supabase.com)
2. Create a new project
3. Go to SQL Editor → paste contents of `database/schema.sql` → Run
4. Copy your project URL and anon key from Settings → API
5. Create storage buckets: `profile-photos`, `exercise-videos`

### 2. Backend Setup
```bash
cd gymflow_backend
cp .env.example .env
# Edit .env with your Supabase credentials
npm install
npm run dev
```

### 3. Mobile App Setup
```bash
cd gymflow_mobile
# Edit lib/config/constants.dart with your API URL
flutter pub get
flutter run
```

### 4. Build APK (via Codemagic)
1. Push code to GitHub
2. Connect repo to [codemagic.com](https://codemagic.com)
3. Add environment variables (API_BASE_URL, SUPABASE_URL, SUPABASE_ANON_KEY)
4. Build Android APK/AAB
5. Download and install on phone

## API Endpoints

### Auth
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login, returns JWT + gyms
- `POST /api/auth/forgot-password` - Send reset email

### Dashboard
- `GET /api/dashboard/admin` - Admin stats & charts
- `GET /api/dashboard/trainer` - Trainer stats & schedule
- `GET /api/dashboard/member` - Member stats & progress

### Members
- `GET /api/members` - List members (admin)
- `GET /api/members/:id` - Member detail with attendance/payments
- `POST /api/members` - Create member
- `PUT /api/members/:id` - Update member
- `POST /api/members/:id/renew` - Renew membership

### Attendance
- `POST /api/attendance/check-in` - Check in (QR or manual)
- `PUT /api/attendance/:id/check-out` - Check out
- `GET /api/attendance/today` - Today's attendance log
- `GET /api/attendance/mine` - User's attendance history
- `GET /api/attendance/qr` - Generate QR code

### Payments
- `POST /api/payments/create-order` - Create Razorpay order
- `POST /api/payments/verify` - Verify Razorpay payment
- `POST /api/payments` - Record manual payment
- `GET /api/payments` - List payments (admin)
- `GET /api/payments/mine` - User's payment history

### Workouts & Diet
- `POST /api/workouts` - Create workout
- `GET /api/workouts` - List workouts
- `PUT /api/workouts/:id/complete` - Mark complete
- `POST /api/diet-plans` - Create diet plan
- `GET /api/diet-plans` - List diet plans
- `GET /api/workouts/exercises/list` - Exercise library

### Progress
- `POST /api/progress` - Log progress
- `GET /api/progress/mine` - My progress history

### Notifications
- `GET /api/notifications` - My notifications
- `PUT /api/notifications/:id/read` - Mark read
- `POST /api/notifications` - Send notification (admin)
- `POST /api/notifications/bulk` - Bulk send (admin)

## Deployment

### Backend (Render)
1. Push to GitHub
2. Create Web Service on Render → connect repo
3. Set root directory: `gymflow_backend`
4. Build command: `npm install`
5. Start command: `npm start`
6. Add env vars from `.env.example`

### Mobile (Codemagic)
1. Connect GitHub repo to Codemagic
2. Set working directory: `gymflow_mobile`
3. Add environment secrets
4. Build triggers: on push to main
5. Download APK from Codemagic artifacts

## License
Private - ROCKFORT PLANET GYM FITNESS
