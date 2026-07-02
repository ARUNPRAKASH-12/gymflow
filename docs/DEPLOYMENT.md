# GymFlow Deployment Guide

## Prerequisites
- GitHub account
- Supabase account (free)
- Render account (free)
- Codemagic account (free, for APK build)
- Razorpay account (for payments)

## Step 1: GitHub Repository

```bash
# Initialize and push to GitHub
cd E:\GymApp
git init
git add .
git commit -m "Initial commit: GymFlow multi-gym management platform"
git branch -M main
git remote add origin https://github.com/ARUNPRAKASH-12/gymflow.git
git push -u origin main
```

## Step 2: Supabase Setup

1. Go to https://supabase.com → Sign up → Create project
2. Choose region closest to India (Mumbai, Singapore)
3. Once created, go to SQL Editor
4. Open `database/schema.sql` from this repo
5. Copy entire contents → Paste → Run
6. Go to Project Settings → API → Copy:
   - Project URL (SUPABASE_URL)
   - anon public key (SUPABASE_ANON_KEY)
   - service_role key (SUPABASE_SERVICE_KEY)
7. Go to Storage → Create buckets:
   - `profile-photos` (public)
   - `exercise-videos` (public)
8. Go to Authentication → Settings → Confirm email verification is enabled

## Step 3: Razorpay Setup

1. Go to https://razorpay.com → Sign up
2. Get API keys from Settings → API Keys
3. Copy Key ID and Key Secret

## Step 4: Backend Deployment (Render)

1. Go to https://render.com → Sign up with GitHub
2. Click "New +" → "Web Service"
3. Connect your gymflow repo
4. Configure:
   - Name: `gymflow-api`
   - Root Directory: `gymflow_backend`
   - Runtime: Node
   - Build Command: `npm install`
   - Start Command: `npm start`
   - Plan: Free
5. Add Environment Variables (click Advanced):
   ```
   SUPABASE_URL=<your-supabase-url>
   SUPABASE_ANON_KEY=<your-anon-key>
   SUPABASE_SERVICE_KEY=<your-service-key>
   RAZORPAY_KEY_ID=<your-razorpay-key>
   RAZORPAY_KEY_SECRET=<your-razorpay-secret>
   JWT_SECRET=<any-random-string>
   NODE_ENV=production
   FRONTEND_URL=*
   PORT=3000
   ```
6. Click "Create Web Service"
7. Wait for deploy (5-10 min)
8. Your API URL will be: `https://gymflow-api.onrender.com`

## Step 5: Mobile App Build (Codemagic)

1. Go to https://codemagic.com → Sign up with GitHub
2. Click "Add application" → Select gymflow repo
3. Configure:
   - Project type: Flutter App
   - Working directory: `gymflow_mobile`
   - Flutter version: 3.22+
4. Environment variables (encrypted):
   ```
   API_BASE_URL=https://gymflow-api.onrender.com/api
   SUPABASE_URL=<your-supabase-url>
   SUPABASE_ANON_KEY=<your-anon-key>
   ```
5. Build triggers: "On every push"
6. Go to Build → Build for Android
7. Artifacts after first build:
   - `app-release.apk` (install directly on phone)
   - `app-release.aab` (for Play Store)

## Step 6: Test on Phone

1. Download APK from Codemagic artifacts
2. Allow installation from unknown sources on your Android phone
3. Install and open GymFlow
4. Register as admin → Login → Select gym → Start managing!

## Step 7: Google Play Store (Final)

When ready for production release:
1. Generate signed AAB via Codemagic (add keystore)
2. Prepare Play Store listing:
   - App icon: 512x512 PNG
   - Feature graphic: 1024x500 PNG
   - Screenshots: 6-8 (phone screenshots)
   - Description, category (Health & Fitness)
3. Create developer account ($25 one-time)
4. Upload AAB → Fill store listing → Publish
