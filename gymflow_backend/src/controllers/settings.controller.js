import { supabase } from '../config/supabase.js';

export async function getSettings(req, res) {
  try {
    const gymId = req.query.gym_id || req.user.selected_gym_id;

    const { data: settings, error } = await supabase
      .from('gym_settings')
      .select('*')
      .eq('id', gymId)
      .single();

    if (error) {
      const { data: gym } = await supabase.from('gyms').select('*').eq('id', gymId).single();
      if (gym) return res.json(gym);
      return res.status(404).json({ error: 'Settings not found' });
    }

    return res.json(settings);
  } catch (err) {
    console.error('Get settings error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}

export async function updateSettings(req, res) {
  try {
    const gymId = req.body.gym_id || req.user.selected_gym_id;
    const updates = req.body;

    delete updates.id;
    delete updates.created_at;

    const { data: settings, error } = await supabase
      .from('gym_settings')
      .update({ ...updates, updated_at: new Date().toISOString() })
      .eq('id', gymId)
      .select()
      .single();

    if (error) {
      const { data: newSettings } = await supabase
        .from('gym_settings')
        .insert({ id: gymId, ...updates })
        .select()
        .single();

      if (newSettings) return res.json(newSettings);
      return res.status(400).json({ error: error.message });
    }

    return res.json(settings);
  } catch (err) {
    console.error('Update settings error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}
