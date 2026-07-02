import { supabase } from '../config/supabase.js';

export async function myProgress(req, res) {
  try {
    const { limit = 30 } = req.query;

    const { data: logs, error } = await supabase
      .from('progress_logs')
      .select('*')
      .eq('member_id', req.user.id)
      .order('date', { ascending: false })
      .limit(Number(limit));

    if (error) throw error;

    const trends = {};
    if (logs?.length > 1) {
      const sorted = [...logs].reverse();
      const first = sorted[0];
      const last = sorted[sorted.length - 1];

      if (first.weight && last.weight) trends.weight_change = Number((Number(last.weight) - Number(first.weight)).toFixed(1));
      if (first.bmi && last.bmi) trends.bmi_change = Number((Number(last.bmi) - Number(first.bmi)).toFixed(1));
      if (first.body_fat && last.body_fat) trends.body_fat_change = Number((Number(last.body_fat) - Number(first.body_fat)).toFixed(1));
    }

    const latest = logs?.[0] || null;

    return res.json({ logs: logs || [], latest, trends });
  } catch (err) {
    console.error('My progress error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}

export async function memberProgress(req, res) {
  try {
    const { memberId } = req.params;
    const { limit = 30 } = req.query;

    const { data: logs, error } = await supabase
      .from('progress_logs')
      .select('*')
      .eq('member_id', memberId)
      .order('date', { ascending: false })
      .limit(Number(limit));

    if (error) throw error;

    return res.json(logs || []);
  } catch (err) {
    console.error('Member progress error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}

export async function addProgress(req, res) {
  try {
    const { weight, bmi, body_fat, chest_cm, waist_cm, arms_cm, thighs_cm, calves_cm, shoulders_cm, notes } = req.validated.body;

    const today = new Date().toISOString().split('T')[0];

    const { data: existing } = await supabase
      .from('progress_logs')
      .select('id')
      .eq('member_id', req.user.id)
      .eq('date', today)
      .single();

    if (existing) {
      const { data: log, error } = await supabase
        .from('progress_logs')
        .update({ weight, bmi, body_fat, chest_cm, waist_cm, arms_cm, thighs_cm, calves_cm, shoulders_cm, notes })
        .eq('id', existing.id)
        .select()
        .single();

      if (error) return res.status(400).json({ error: error.message });
      return res.json({ message: 'Progress updated for today', log });
    }

    const bmiValue = bmi || (weight ? Number((weight / Math.pow(1.7, 2)).toFixed(1)) : null);

    const { data: member } = await supabase
      .from('members')
      .select('gym_id')
      .eq('user_id', req.user.id)
      .single();

    const { data: log, error } = await supabase.from('progress_logs').insert({
      member_id: req.user.id,
      gym_id: member?.gym_id || req.user.selected_gym_id,
      date: today,
      weight,
      bmi: bmiValue,
      body_fat,
      chest_cm,
      waist_cm,
      arms_cm,
      thighs_cm,
      calves_cm,
      shoulders_cm,
      notes,
    }).select().single();

    if (error) return res.status(400).json({ error: error.message });

    return res.status(201).json({ message: 'Progress logged', log });
  } catch (err) {
    console.error('Add progress error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}

export async function deleteProgress(req, res) {
  try {
    const { id } = req.params;

    const { error } = await supabase.from('progress_logs').delete().eq('id', id).eq('member_id', req.user.id);
    if (error) return res.status(400).json({ error: error.message });

    return res.json({ message: 'Progress log deleted' });
  } catch (err) {
    console.error('Delete progress error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}
