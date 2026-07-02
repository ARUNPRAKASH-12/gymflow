import { supabase } from '../config/supabase.js';

export async function listPlans(req, res) {
  try {
    const { gym_id, is_active } = req.query;
    const targetGym = gym_id || req.user.selected_gym_id;

    let query = supabase
      .from('membership_plans')
      .select('*')
      .order('sort_order', { ascending: true });

    if (targetGym) query = query.eq('gym_id', targetGym);
    if (is_active !== undefined) query = query.eq('is_active', is_active === 'true');

    const { data: plans, error } = await query;
    if (error) throw error;

    return res.json(plans || []);
  } catch (err) {
    console.error('List plans error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}

export async function getPlan(req, res) {
  try {
    const { id } = req.params;

    const { data: plan, error } = await supabase
      .from('membership_plans')
      .select('*')
      .eq('id', id)
      .single();

    if (error) return res.status(404).json({ error: 'Plan not found' });

    return res.json(plan);
  } catch (err) {
    console.error('Get plan error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}

export async function createPlan(req, res) {
  try {
    const { gym_id, name, duration_days, price, discounted_price, description, features } = req.validated.body;

    const { data: maxSort } = await supabase
      .from('membership_plans')
      .select('sort_order')
      .eq('gym_id', gym_id)
      .order('sort_order', { ascending: false })
      .limit(1);

    const nextSort = (maxSort?.[0]?.sort_order ?? 0) + 1;

    const { data: plan, error } = await supabase
      .from('membership_plans')
      .insert({ gym_id, name, duration_days, price, discounted_price, description, features: features || [], sort_order: nextSort })
      .select()
      .single();

    if (error) return res.status(400).json({ error: error.message });

    return res.status(201).json(plan);
  } catch (err) {
    console.error('Create plan error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}

export async function updatePlan(req, res) {
  try {
    const { id } = req.params;
    const updates = req.body;

    delete updates.id;
    delete updates.created_at;

    const { data: plan, error } = await supabase
      .from('membership_plans')
      .update({ ...updates, updated_at: new Date().toISOString() })
      .eq('id', id)
      .select()
      .single();

    if (error) return res.status(400).json({ error: error.message });

    return res.json(plan);
  } catch (err) {
    console.error('Update plan error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}

export async function deletePlan(req, res) {
  try {
    const { id } = req.params;

    await supabase.from('membership_plans').update({ is_active: false }).eq('id', id);

    return res.json({ message: 'Plan deactivated' });
  } catch (err) {
    console.error('Delete plan error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}
