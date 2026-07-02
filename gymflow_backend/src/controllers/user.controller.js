import { supabase } from '../config/supabase.js';
import { uploadToSupabase } from '../middleware/upload.js';

export async function getProfile(req, res) {
  try {
    const { data: profile, error } = await supabase
      .from('user_profiles')
      .select('*')
      .eq('user_id', req.user.id)
      .single();

    if (error) {
      return res.status(404).json({ error: 'Profile not found' });
    }

    const { data: gyms } = await supabase
      .from('user_gyms')
      .select('gym:gyms(*)')
      .eq('user_id', req.user.id);

    return res.json({
      user: req.user,
      profile,
      gyms: gyms?.map((g) => g.gym) || [],
    });
  } catch (err) {
    console.error('Get profile error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}

export async function updateProfile(req, res) {
  try {
    const updates = req.body;

    const allowedFields = [
      'full_name', 'dob', 'gender', 'address',
      'emergency_contact_name', 'emergency_contact_phone',
      'medical_conditions', 'allergies', 'blood_group',
    ];

    const profileUpdate = {};
    for (const field of allowedFields) {
      if (updates[field] !== undefined) {
        profileUpdate[field] = updates[field];
      }
    }

    if (updates.phone && updates.phone !== req.user.phone) {
      await supabase
        .from('users')
        .update({ phone: updates.phone })
        .eq('id', req.user.id);
    }

    if (Object.keys(profileUpdate).length > 0) {
      const { data, error } = await supabase
        .from('user_profiles')
        .update({ ...profileUpdate, updated_at: new Date().toISOString() })
        .eq('user_id', req.user.id)
        .select()
        .single();

      if (error) {
        return res.status(400).json({ error: error.message });
      }

      return res.json({ message: 'Profile updated', profile: data });
    }

    return res.json({ message: 'No changes made' });
  } catch (err) {
    console.error('Update profile error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}

export async function uploadPhoto(req, res) {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No file uploaded' });
    }

    const photoUrl = await uploadToSupabase(req.file, 'profile-photos', `users/${req.user.id}`);

    await supabase
      .from('user_profiles')
      .update({ photo_url: photoUrl, updated_at: new Date().toISOString() })
      .eq('user_id', req.user.id);

    await supabase
      .from('users')
      .update({ avatar_url: photoUrl })
      .eq('id', req.user.id);

    return res.json({ photo_url: photoUrl });
  } catch (err) {
    console.error('Upload photo error:', err);
    return res.status(500).json({ error: err.message || 'Upload failed' });
  }
}
