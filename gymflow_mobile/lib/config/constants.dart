class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://gymflow-j5ir.onrender.com/api',
  );

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://xcxeamroucnokdpilqsd.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhjeGVhbXJvdWNub2tkcGlscXNkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODMwMDIxOTksImV4cCI6MjA5ODU3ODE5OX0.Y_A8vnrTqifmonMVQ5Wt1yTJlin5iyQpk0NozAGjZqU',
  );
}

class StorageKeys {
  static const String token = 'auth_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userRole = 'user_role';
  static const String selectedGymId = 'selected_gym_id';
  static const String selectedGymName = 'selected_gym_name';
}

class AppConstants {
  static const String appName = 'GymFlow';
  static const String appTagline = 'Your Fitness, Our Mission';
  static const String version = '1.0.0';

  static const Duration pageTransitionDuration = Duration(milliseconds: 300);
  static const Duration splashDuration = Duration(seconds: 2);

  static const double cardBorderRadius = 16;
  static const double smallBorderRadius = 8;
  static const double buttonBorderRadius = 12;
  static const double avatarRadius = 24;
  static const double largeAvatarRadius = 48;
}
