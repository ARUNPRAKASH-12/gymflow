import { supabase, supabaseAdmin } from '../config/supabase.js';

export async function listTrainers(req, res) {
  try {
    const { gym_id, is_active } = req.query;

    let query = supabase
      .from('trainers')
      .select('*, user:users(id, email, phone, avatar_url, is_active), profile:user_profiles!user_id(*)')
      .order('created_at', { ascending: false });

    const targetGym = gym_id || req.user.selected_gym_id;
    if (targetGym) query = query.eq('gym_id', targetGym);
    if (is_active !== undefined) query = query.eq('is_active', is_active === 'true');

    const { data: trainers, error } = await query;
    if (error) throw error;

    return res.json(trainers || []);
  } catch (err) {
    console.error('List trainers error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}

export async function getTrainer(req, res) {
  try {
    const { id } = req.params;

    const { data: trainer, error } = await supabase
      .from('trainers')
      .select('*, user:users(*), profile:user_profiles!user_id(*)')
      .eq('id', id)
      .single();

    if (error) return res.status(404).json({ error: 'Trainer not found' });

    const { data: members } = await supabase
      .from('members')
      .select('id, user_id, status, user:users(email), profile:user_profiles!user_id(full_name, photo_url)')
      .eq('assigned_trainer_id', trainer.user_id)
      .limit(20);

    return res.json({ ...trainer, assigned_members: members || [] });
  } catch (err) {
    console.error('Get trainer error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}

export async function createTrainer(req, res) {
  try {
    const { email, password, full_name, phone, gym_id, specialization, hire_date, salary } = req.validated.body;

    const tempPassword = password || Math.random().toString(36).slice(-8) + 'A1!';

    const { data: authData, error: authError } = await supabaseAdmin.auth.admin.createUser({
      email,
      password: tempPassword,
      email_confirm: true,
      user_metadata: { full_name, phone, role: 'trainer' },
    });

    if (authError) return res.status(400).json({ error: authError.message });

    const targetGym = gym_id || req.user.selected_gym_id;

    const { data: trainer, error: trainerError } = await supabase.from('trainers').insert({
      user_id: authData.user.id,
      gym_id: targetGym,
      specialization: specialization || null,
      hire_date: hire_date || new Date().toISOString().split('T')[0],
      salary: salary || null,
    }).select('*, user:users(*), profile:user_profiles!user_id(*)').single();

    if (trainerError) return res.status(400).json({ error: trainerError.message });

    await supabase.from('user_gyms').insert({
      user_id: authData.user.id,
      gym_id: targetGym,
      role: 'trainer',
    });

    return res.status(201).json({ ...trainer, temp_password: tempPassword });
  } catch (err) {
    console.error('Create trainer error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}

export async function updateTrainer(req, res) {
  try {
    const { id } = req.params;
    const updates = req.body;

    const allowedFields = ['specialization', 'salary', 'is_active', 'schedule', 'qualifications'];
    const trainerUpdate = {};
    for (const field of allowedFields) {
      if (updates[field] !== undefined) trainerUpdate[field] = updates[field];
    }
    if (updates.hire_date) trainerUpdate.hire_date = updates.hire_date;
    trainerUpdate.updated_at = new Date().toISOString();

    const { data: trainer, error } = await supabase
      .from('trainers')
      .update(trainerUpdate)
      .eq('id', id)
      .select('*, user:users(*), profile:user_profiles!user_id(*)')
      .single();

    if (error) return res.status(400).json({ error: error.message });

    return res.json(trainer);
  } catch (err) {
    console.error('Update trainer error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}

export async function deleteTrainer(req, res) {
  try {
    const { id } = req.params;

    await supabase.from('trainers').update({ is_active: false, updated_at: new Date().toISOString() }).eq('id', id);

    const { data: trainer } = await supabase.from('trainers').select('user_id').eq('id', id).single();
    if (trainer) {
      await supabase.from('members').update({ assigned_trainer_id: null }).eq('assigned_trainer_id', trainer.user_id);
    }

    return res.json({ message: 'Trainer deactivated' });
  } catch (err) {
    console.error('Delete trainer error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}

export async function getTrainerMembers(req, res) {
  try {
    const { id } = req.params;

    const { data: trainer } = await supabase.from('trainers').select('user_id').eq('id', id).single();
    if (!trainer) return res.status(404).json({ error: 'Trainer not found' });

    const { data: members, error } = await supabase
      .from('members')
      .select('*, user:users(id, email, phone), profile:user_profiles!user_id(full_name, photo_url, dob), plan:membership_plans(name)')
      .eq('assigned_trainer_id', trainer.user_id);

    if (error) throw error;

    return res.json(members || []);
  } catch (err) {
    console.error('Get trainer members error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}
