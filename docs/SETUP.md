# GymFlow - Quick Setup Guide

## 3-Step Setup for ARUNPRAKASH-12

### Step 1: Create Supabase Database (5 min)
1. Go to https://supabase.com → Sign up → Create project
2. Name: `gymflow`, Password: (save this)
3. Once created → SQL Editor → Paste contents of `database/schema.sql` → Run
4. Go to Project Settings → API → Copy URL & anon key

### Step 2: Deploy Backend (10 min)
1. Push this code to GitHub
2. Go to https://render.com → Sign up → New Web Service
3. Connect your repo → Set root: `gymflow_backend`
4. Add environment variables (from Step 1)
5. Deploy → Get URL like `https://gymflow-api.onrender.com`

### Step 3: Build Mobile App (5 min)
1. Go to https://codemagic.com → Sign up → Add app
2. Connect repo → Set workdir: `gymflow_mobile`
3. Add env vars: `API_BASE_URL`, `SUPABASE_URL`, `SUPABASE_ANON_KEY`
4. Build → Download APK → Install on phone

## Email me when done — I'll help with any issues!

Contact for ROCKFORT PLANET GYM FITNESS:
- Phone: +91 98651 50164
- Address: P-60, J K Nagar, K K Nagar, Tiruchirappalli, Tamil Nadu 620007
