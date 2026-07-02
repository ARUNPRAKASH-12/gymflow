import { supabase } from '../config/supabase.js';

export async function listGyms(req, res) {
  try {
    const { data: gyms, error } = await supabase
      .from('user_gyms')
      .select('gym:gyms(*)')
      .eq('user_id', req.user.id)
      .eq('is_active', true);

    if (error) throw error;

    return res.json(gyms?.map((g) => g.gym) || []);
  } catch (err) {
    console.error('List gyms error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}

export async function getGym(req, res) {
  try {
    const { id } = req.params;

    const { data: gym, error } = await supabase
      .from('gyms')
      .select('*')
      .eq('id', id)
      .single();

    if (error) {
      return res.status(404).json({ error: 'Gym not found' });
    }

    return res.json(gym);
  } catch (err) {
    console.error('Get gym error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}

export async function createGym(req, res) {
  try {
    const { name, address, city, state, phone, email } = req.body;

    const slug = name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '');

    const { data: gym, error } = await supabase
      .from('gyms')
      .insert({ name, slug, address, city, state, phone, email })
      .select()
      .single();

    if (error) {
      return res.status(400).json({ error: error.message });
    }

    await supabase.from('user_gyms').insert({
      user_id: req.user.id,
      gym_id: gym.id,
      role: 'admin',
    });

    return res.status(201).json(gym);
  } catch (err) {
    console.error('Create gym error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}

export async function updateGym(req, res) {
  try {
    const { id } = req.params;
    const updates = req.body;

    delete updates.id;
    delete updates.created_at;

    const { data: gym, error } = await supabase
      .from('gyms')
      .update({ ...updates, updated_at: new Date().toISOString() })
      .eq('id', id)
      .select()
      .single();

    if (error) {
      return res.status(400).json({ error: error.message });
    }

    return res.json(gym);
  } catch (err) {
    console.error('Update gym error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}

export async function selectGym(req, res) {
  try {
    const { id } = req.params;

    const { data: membership, error } = await supabase
      .from('user_gyms')
      .select('*')
      .eq('user_id', req.user.id)
      .eq('gym_id', id)
      .single();

    if (error || !membership) {
      return res.status(403).json({ error: 'Access denied to this gym' });
    }

    await supabase
      .from('users')
      .update({ selected_gym_id: id })
      .eq('id', req.user.id);

    return res.json({ message: 'Gym selected', gym_id: id, role: membership.role });
  } catch (err) {
    console.error('Select gym error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}
