import { supabase, supabaseAdmin } from '../config/supabase.js';

export async function register(req, res) {
  try {
    const { email, password, full_name, phone, role } = req.validated.body;

    const { data: authData, error: authError } = await supabaseAdmin.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
      user_metadata: { full_name, phone, role },
    });

    if (authError) {
      return res.status(400).json({ error: authError.message });
    }

    const { data: gyms, error: gymError } = await supabase
      .from('gyms')
      .select('id')
      .limit(1);

    if (!gymError && gyms?.length > 0) {
      await supabase.from('user_gyms').insert({
        user_id: authData.user.id,
        gym_id: gyms[0].id,
        role,
      });
    }

    const { data: profile } = await supabase
      .from('user_profiles')
      .select('*')
      .eq('user_id', authData.user.id)
      .single();

    if (role === 'trainer') {
      const { error: trainerError } = await supabase.from('trainers').insert({
        user_id: authData.user.id,
        gym_id: gyms?.[0]?.id || null,
      });
      if (trainerError) console.error('Trainer creation error:', trainerError);
    }

    return res.status(201).json({
      message: 'Registration successful',
      user: {
        id: authData.user.id,
        email: authData.user.email,
        role,
        profile,
      },
    });
  } catch (err) {
    console.error('Register error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}

export async function login(req, res) {
  try {
    const { email, password } = req.validated.body;

    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (error) {
      return res.status(401).json({ error: error.message });
    }

    const { data: dbUser, error: dbError } = await supabase
      .from('users')
      .select('*, user_profiles(*)')
      .eq('id', data.user.id)
      .single();

    if (dbError) {
      console.error('User fetch error:', dbError);
    }

    await supabase
      .from('users')
      .update({ last_login: new Date().toISOString() })
      .eq('id', data.user.id);

    const { data: gyms } = await supabase
      .from('user_gyms')
      .select('gym:gyms(*)')
      .eq('user_id', data.user.id)
      .eq('is_active', true);

    return res.json({
      token: data.session.access_token,
      refresh_token: data.session.refresh_token,
      user: dbUser || { id: data.user.id, email: data.user.email },
      gyms: gyms?.map((g) => g.gym) || [],
    });
  } catch (err) {
    console.error('Login error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}

export async function forgotPassword(req, res) {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({ error: 'Email is required' });
    }

    const { error } = await supabase.auth.resetPasswordForEmail(email, {
      redirectTo: `${process.env.FRONTEND_URL || 'http://localhost:5173'}/reset-password`,
    });

    if (error) {
      return res.status(400).json({ error: error.message });
    }

    return res.json({ message: 'Password reset email sent' });
  } catch (err) {
    console.error('Forgot password error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}

export async function resetPassword(req, res) {
  try {
    const { token, new_password } = req.body;

    if (!token || !new_password) {
      return res.status(400).json({ error: 'Token and new password are required' });
    }

    const { error } = await supabase.auth.updateUser({
      password: new_password,
    });

    if (error) {
      return res.status(400).json({ error: error.message });
    }

    return res.json({ message: 'Password reset successful' });
  } catch (err) {
    console.error('Reset password error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}

export async function verifyEmail(req, res) {
  try {
    const { token } = req.body;

    if (!token) {
      return res.status(400).json({ error: 'Verification token is required' });
    }

    const { error } = await supabase.auth.verifyOtp({
      token_hash: token,
      type: 'email',
    });

    if (error) {
      return res.status(400).json({ error: error.message });
    }

    return res.json({ message: 'Email verified successfully' });
  } catch (err) {
    console.error('Verify email error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}
