-- ============================================================
-- GYMFLOW - Complete Supabase Schema
-- Multi-gym SaaS Platform
-- ============================================================

-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- ENUMS
-- ============================================================
CREATE TYPE user_role AS ENUM ('admin', 'trainer', 'member', 'superadmin');
CREATE TYPE membership_status AS ENUM ('active', 'expired', 'cancelled', 'pending');
CREATE TYPE attendance_method AS ENUM ('qr', 'manual');
CREATE TYPE payment_status AS ENUM ('pending', 'completed', 'failed', 'refunded');
CREATE TYPE payment_method AS ENUM ('cash', 'razorpay', 'upi', 'card', 'bank_transfer');
CREATE TYPE diet_type AS ENUM ('weight_loss', 'muscle_gain', 'maintenance');
CREATE TYPE exercise_category AS ENUM ('chest', 'back', 'legs', 'shoulder', 'biceps', 'triceps', 'cardio', 'abs');
CREATE TYPE notification_type AS ENUM ('membership_expiry', 'payment_reminder', 'workout', 'announcement', 'promotional');
CREATE TYPE gender_enum AS ENUM ('male', 'female', 'other');

-- ============================================================
-- TABLES
-- ============================================================

-- 1. Gyms
CREATE TABLE public.gyms (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  address TEXT,
  city TEXT,
  state TEXT,
  pincode TEXT,
  phone TEXT,
  email TEXT,
  logo_url TEXT,
  cover_url TEXT,
  working_hours JSONB DEFAULT '{"monday":"6:00 AM - 9:00 AM, 4:00 PM - 9:00 PM","tuesday":"6:00 AM - 9:00 AM, 4:00 PM - 9:00 PM","wednesday":"6:00 AM - 9:00 AM, 4:00 PM - 9:00 PM","thursday":"6:00 AM - 9:00 AM, 4:00 PM - 9:00 PM","friday":"6:00 AM - 9:00 AM, 4:00 PM - 9:00 PM","saturday":"6:00 AM - 9:00 AM, 4:00 PM - 9:00 PM","sunday":"6:00 AM - 9:00 AM"}',
  closed_days TEXT[] DEFAULT '{}',
  is_active BOOLEAN DEFAULT true,
  subscription_plan TEXT DEFAULT 'free',
  settings JSONB DEFAULT '{"enable_qr":true,"enable_razorpay":true,"enable_notifications":true}',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 2. Users (extends Supabase auth.users)
CREATE TABLE public.users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE NOT NULL,
  phone TEXT,
  role user_role NOT NULL DEFAULT 'member',
  avatar_url TEXT,
  is_verified BOOLEAN DEFAULT false,
  selected_gym_id UUID REFERENCES public.gyms(id) ON DELETE SET NULL,
  is_active BOOLEAN DEFAULT true,
  last_login TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 3. User Profiles
CREATE TABLE public.user_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE UNIQUE,
  full_name TEXT NOT NULL,
  dob DATE,
  gender gender_enum,
  address TEXT,
  emergency_contact_name TEXT,
  emergency_contact_phone TEXT,
  medical_conditions TEXT,
  allergies TEXT,
  blood_group TEXT,
  photo_url TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 4. User-Gym Association (which users belong to which gyms)
CREATE TABLE public.user_gyms (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  gym_id UUID REFERENCES public.gyms(id) ON DELETE CASCADE,
  role user_role NOT NULL,
  is_active BOOLEAN DEFAULT true,
  joined_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, gym_id)
);

-- 5. Membership Plans
CREATE TABLE public.membership_plans (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  gym_id UUID REFERENCES public.gyms(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  duration_days INTEGER NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  discounted_price DECIMAL(10,2),
  description TEXT,
  features JSONB DEFAULT '[]',
  color TEXT DEFAULT '#FF6B35',
  is_active BOOLEAN DEFAULT true,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 6. Members
CREATE TABLE public.members (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE UNIQUE,
  gym_id UUID REFERENCES public.gyms(id) ON DELETE CASCADE,
  membership_plan_id UUID REFERENCES public.membership_plans(id) ON DELETE SET NULL,
  start_date DATE,
  end_date DATE,
  status membership_status DEFAULT 'pending',
  assigned_trainer_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
  join_date DATE DEFAULT CURRENT_DATE,
  referral_source TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 7. Trainers
CREATE TABLE public.trainers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE UNIQUE,
  gym_id UUID REFERENCES public.gyms(id) ON DELETE CASCADE,
  specialization TEXT,
  qualifications TEXT[],
  hire_date DATE,
  salary DECIMAL(10,2),
  schedule JSONB DEFAULT '{}',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 8. Attendance
CREATE TABLE public.attendance (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  gym_id UUID REFERENCES public.gyms(id) ON DELETE CASCADE,
  check_in TIMESTAMPTZ NOT NULL,
  check_out TIMESTAMPTZ,
  date DATE NOT NULL DEFAULT CURRENT_DATE,
  method attendance_method DEFAULT 'manual',
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 9. Payments
CREATE TABLE public.payments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  gym_id UUID REFERENCES public.gyms(id) ON DELETE CASCADE,
  membership_plan_id UUID REFERENCES public.membership_plans(id) ON DELETE SET NULL,
  amount DECIMAL(10,2) NOT NULL,
  method payment_method NOT NULL DEFAULT 'cash',
  transaction_id TEXT,
  razorpay_order_id TEXT,
  razorpay_payment_id TEXT,
  razorpay_signature TEXT,
  status payment_status DEFAULT 'pending',
  invoice_url TEXT,
  invoice_number TEXT,
  payment_date TIMESTAMPTZ DEFAULT now(),
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 10. Exercise Library
CREATE TABLE public.exercise_library (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  gym_id UUID REFERENCES public.gyms(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  category exercise_category NOT NULL,
  description TEXT,
  video_url TEXT,
  image_url TEXT,
  sets_reps JSONB DEFAULT '[]',
  equipment_needed TEXT[],
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 11. Workouts
CREATE TABLE public.workouts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  gym_id UUID REFERENCES public.gyms(id) ON DELETE CASCADE,
  trainer_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
  member_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  day_of_week TEXT,
  schedule_date DATE,
  exercises JSONB NOT NULL DEFAULT '[]',
  is_completed BOOLEAN DEFAULT false,
  completed_at TIMESTAMPTZ,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 12. Diet Plans
CREATE TABLE public.diet_plans (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  gym_id UUID REFERENCES public.gyms(id) ON DELETE CASCADE,
  trainer_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
  member_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  type diet_type NOT NULL,
  target_calories INTEGER,
  meals JSONB NOT NULL DEFAULT '[]',
  notes TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 13. Progress Logs
CREATE TABLE public.progress_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  member_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  gym_id UUID REFERENCES public.gyms(id) ON DELETE CASCADE,
  date DATE NOT NULL DEFAULT CURRENT_DATE,
  weight DECIMAL(5,2),
  bmi DECIMAL(4,2),
  body_fat DECIMAL(4,2),
  chest_cm DECIMAL(5,2),
  waist_cm DECIMAL(5,2),
  arms_cm DECIMAL(5,2),
  thighs_cm DECIMAL(5,2),
  calves_cm DECIMAL(5,2),
  shoulders_cm DECIMAL(5,2),
  photo_urls TEXT[],
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 14. Notifications
CREATE TABLE public.notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  gym_id UUID REFERENCES public.gyms(id) ON DELETE CASCADE,
  sender_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
  recipient_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  type notification_type DEFAULT 'announcement',
  is_read BOOLEAN DEFAULT false,
  read_at TIMESTAMPTZ,
  action_link TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 15. QR Codes (for daily attendance QR)
CREATE TABLE public.qr_codes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  gym_id UUID REFERENCES public.gyms(id) ON DELETE CASCADE,
  code TEXT NOT NULL,
  date DATE NOT NULL DEFAULT CURRENT_DATE,
  is_active BOOLEAN DEFAULT true,
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 16. Audit Logs
CREATE TABLE public.audit_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  gym_id UUID REFERENCES public.gyms(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
  action TEXT NOT NULL,
  entity_type TEXT,
  entity_id UUID,
  changes JSONB,
  ip_address TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- INDEXES
-- ============================================================
CREATE INDEX idx_users_email ON public.users(email);
CREATE INDEX idx_users_role ON public.users(role);
CREATE INDEX idx_user_gyms_user ON public.user_gyms(user_id);
CREATE INDEX idx_user_gyms_gym ON public.user_gyms(gym_id);
CREATE INDEX idx_members_gym ON public.members(gym_id);
CREATE INDEX idx_members_status ON public.members(status);
CREATE INDEX idx_members_trainer ON public.members(assigned_trainer_id);
CREATE INDEX idx_attendance_gym_date ON public.attendance(gym_id, date);
CREATE INDEX idx_attendance_user_date ON public.attendance(user_id, date);
CREATE INDEX idx_payments_gym ON public.payments(gym_id);
CREATE INDEX idx_payments_user ON public.payments(user_id);
CREATE INDEX idx_payments_status ON public.payments(status);
CREATE INDEX idx_workouts_member ON public.workouts(member_id);
CREATE INDEX idx_workouts_trainer ON public.workouts(trainer_id);
CREATE INDEX idx_diet_plans_member ON public.diet_plans(member_id);
CREATE INDEX idx_progress_logs_member_date ON public.progress_logs(member_id, date);
CREATE INDEX idx_notifications_recipient ON public.notifications(recipient_id);
CREATE INDEX idx_notifications_gym ON public.notifications(gym_id);

-- ============================================================
-- TRIGGER: Auto-create user record when auth user is created
-- ============================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, phone, role, is_verified)
  VALUES (
    NEW.id,
    NEW.email,
    NEW.raw_user_meta_data->>'phone',
    COALESCE(
      (NEW.raw_user_meta_data->>'role')::user_role,
      'member'
    ),
    NEW.email_confirmed_at IS NOT NULL
  );

  INSERT INTO public.user_profiles (user_id, full_name)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', '')
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================================
-- TRIGGER: Auto-update updated_at columns
-- ============================================================
CREATE OR REPLACE FUNCTION public.update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON public.users
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER update_user_profiles_updated_at
  BEFORE UPDATE ON public.user_profiles
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER update_members_updated_at
  BEFORE UPDATE ON public.members
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER update_trainers_updated_at
  BEFORE UPDATE ON public.trainers
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER update_gyms_updated_at
  BEFORE UPDATE ON public.gyms
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER update_workouts_updated_at
  BEFORE UPDATE ON public.workouts
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER update_diet_plans_updated_at
  BEFORE UPDATE ON public.diet_plans
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

-- ============================================================
-- FUNCTIONS
-- ============================================================

-- Get admin dashboard stats
CREATE OR REPLACE FUNCTION public.get_admin_dashboard_stats(p_gym_id UUID)
RETURNS JSONB AS $$
DECLARE
  result JSONB;
BEGIN
  SELECT jsonb_build_object(
    'total_members', (SELECT COUNT(*) FROM public.members WHERE gym_id = p_gym_id),
    'active_members', (SELECT COUNT(*) FROM public.members WHERE gym_id = p_gym_id AND status = 'active'),
    'expired_members', (SELECT COUNT(*) FROM public.members WHERE gym_id = p_gym_id AND status = 'expired'),
    'today_attendance', (SELECT COUNT(*) FROM public.attendance WHERE gym_id = p_gym_id AND date = CURRENT_DATE),
    'monthly_revenue', (SELECT COALESCE(SUM(amount), 0) FROM public.payments WHERE gym_id = p_gym_id AND status = 'completed' AND EXTRACT(MONTH FROM payment_date) = EXTRACT(MONTH FROM CURRENT_DATE) AND EXTRACT(YEAR FROM payment_date) = EXTRACT(YEAR FROM CURRENT_DATE)),
    'total_trainers', (SELECT COUNT(*) FROM public.trainers WHERE gym_id = p_gym_id AND is_active = true),
    'pending_payments', (SELECT COUNT(*) FROM public.payments WHERE gym_id = p_gym_id AND status = 'pending'),
    'expiring_next_7_days', (SELECT COUNT(*) FROM public.members WHERE gym_id = p_gym_id AND status = 'active' AND end_date BETWEEN CURRENT_DATE AND CURRENT_DATE + 7)
  ) INTO result;
  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Get trainer dashboard stats
CREATE OR REPLACE FUNCTION public.get_trainer_dashboard_stats(p_user_id UUID, p_gym_id UUID)
RETURNS JSONB AS $$
DECLARE
  result JSONB;
BEGIN
  SELECT jsonb_build_object(
    'assigned_members', (SELECT COUNT(*) FROM public.members WHERE assigned_trainer_id = p_user_id AND gym_id = p_gym_id AND status = 'active'),
    'today_workouts', (SELECT COUNT(*) FROM public.workouts WHERE trainer_id = p_user_id AND gym_id = p_gym_id AND schedule_date = CURRENT_DATE),
    'total_workouts_created', (SELECT COUNT(*) FROM public.workouts WHERE trainer_id = p_user_id AND gym_id = p_gym_id)
  ) INTO result;
  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Get member dashboard stats
CREATE OR REPLACE FUNCTION public.get_member_dashboard_stats(p_user_id UUID, p_gym_id UUID)
RETURNS JSONB AS $$
DECLARE
  result JSONB;
  mem RECORD;
BEGIN
  SELECT * INTO mem FROM public.members WHERE user_id = p_user_id AND gym_id = p_gym_id;

  SELECT jsonb_build_object(
    'membership_status', mem.status,
    'start_date', mem.start_date,
    'end_date', mem.end_date,
    'days_remaining', CASE WHEN mem.end_date IS NOT NULL THEN (mem.end_date - CURRENT_DATE) ELSE 0 END,
    'this_month_attendance', (SELECT COUNT(*) FROM public.attendance WHERE user_id = p_user_id AND gym_id = p_gym_id AND EXTRACT(MONTH FROM date) = EXTRACT(MONTH FROM CURRENT_DATE) AND EXTRACT(YEAR FROM date) = EXTRACT(YEAR FROM CURRENT_DATE)),
    'today_workout', (SELECT COUNT(*) FROM public.workouts WHERE member_id = p_user_id AND schedule_date = CURRENT_DATE),
    'last_progress_log', (SELECT row_to_json(pl.*) FROM public.progress_logs pl WHERE member_id = p_user_id ORDER BY date DESC LIMIT 1)
  ) INTO result;
  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================

-- Enable RLS on all tables
ALTER TABLE public.gyms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_gyms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.membership_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trainers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exercise_library ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workouts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.diet_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.progress_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.qr_codes ENABLE ROW LEVEL SECURITY;

-- Users: can read own record, admins read all, trainers read assigned
CREATE POLICY users_select_own ON public.users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY users_select_admin ON public.users
  FOR SELECT USING (
    auth.uid() IN (SELECT id FROM public.users WHERE role IN ('admin', 'superadmin'))
  );

CREATE POLICY users_update_own ON public.users
  FOR UPDATE USING (auth.uid() = id);

-- Members: admins see all, trainers see assigned, members see own
CREATE POLICY members_select_admin ON public.members
  FOR SELECT USING (
    auth.uid() IN (SELECT id FROM public.users WHERE role IN ('admin', 'superadmin'))
  );

CREATE POLICY members_select_trainer ON public.members
  FOR SELECT USING (
    assigned_trainer_id = auth.uid()
  );

CREATE POLICY members_select_own ON public.members
  FOR SELECT USING (user_id = auth.uid());

-- Attendance: admins see all, users see own
CREATE POLICY attendance_select_admin ON public.attendance
  FOR SELECT USING (
    auth.uid() IN (SELECT id FROM public.users WHERE role IN ('admin', 'superadmin'))
  );

CREATE POLICY attendance_select_own ON public.attendance
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY attendance_insert_own ON public.attendance
  FOR INSERT WITH CHECK (user_id = auth.uid());

-- Payments: admins see all, users see own
CREATE POLICY payments_select_admin ON public.payments
  FOR SELECT USING (
    auth.uid() IN (SELECT id FROM public.users WHERE role IN ('admin', 'superadmin'))
  );

CREATE POLICY payments_select_own ON public.payments
  FOR SELECT USING (user_id = auth.uid());

-- Workouts: trainers see created, members see assigned
CREATE POLICY workouts_select_trainer ON public.workouts
  FOR SELECT USING (trainer_id = auth.uid());

CREATE POLICY workouts_select_member ON public.workouts
  FOR SELECT USING (member_id = auth.uid());

-- Progress: members see own, trainers see assigned
CREATE POLICY progress_select_own ON public.progress_logs
  FOR SELECT USING (member_id = auth.uid());

CREATE POLICY progress_insert_own ON public.progress_logs
  FOR INSERT WITH CHECK (member_id = auth.uid());

CREATE POLICY progress_select_trainer ON public.progress_logs
  FOR SELECT USING (
    member_id IN (SELECT user_id FROM public.members WHERE assigned_trainer_id = auth.uid())
  );

-- Notifications: see own
CREATE POLICY notifications_select_own ON public.notifications
  FOR SELECT USING (recipient_id = auth.uid());

-- ============================================================
-- SEED DATA: Default gym (ROCKFORT PLANET GYM FITNESS)
-- ============================================================
INSERT INTO public.gyms (name, slug, address, city, state, pincode, phone, email)
VALUES (
  'ROCKFORT PLANET GYM FITNESS',
  'rockfort-planet-gym',
  'P-60, J K Nagar, K K Nagar',
  'Tiruchirappalli',
  'Tamil Nadu',
  '620007',
  '+91 98651 50164',
  'rockfortplanet@gmail.com'
);

-- ============================================================
-- SEED DATA: Default membership plans for the gym
-- ============================================================
INSERT INTO public.membership_plans (gym_id, name, duration_days, price, description, features, color, sort_order)
VALUES
  ((SELECT id FROM public.gyms WHERE slug = 'rockfort-planet-gym'), 'Monthly Plan', 30, 999.00, 'Basic monthly membership with full gym access', '["Full gym access","Locker facility","Basic fitness assessment","Free Wi-Fi"]'::JSONB, '#2563EB', 1),
  ((SELECT id FROM public.gyms WHERE slug = 'rockfort-planet-gym'), 'Quarterly Plan', 90, 2499.00, '3 months membership with trainer guidance', '["Full gym access","Locker facility","Personal trainer (2 sessions/week)","Fitness assessment","Diet consultation"]'::JSONB, '#FF6B35', 2),
  ((SELECT id FROM public.gyms WHERE slug = 'rockfort-planet-gym'), 'Half-Yearly Plan', 180, 4499.00, '6 months membership with premium benefits', '["Full gym access","Locker & towel","Personal trainer (3 sessions/week)","Monthly fitness assessment","Diet plan","Steam bath access"]'::JSONB, '#22C55E', 3),
  ((SELECT id FROM public.gyms WHERE slug = 'rockfort-planet-gym'), 'Annual Plan', 365, 7999.00, 'Best value yearly membership with all benefits', '["Full gym access","Locker & towel","Unlimited trainer sessions","Monthly assessments","Custom diet & workout plan","Steam & sauna","Free protein supplements (1/month)","Priority support"]'::JSONB, '#FF6B35', 4);
