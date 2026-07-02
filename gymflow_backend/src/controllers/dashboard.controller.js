import { supabase } from '../config/supabase.js';

export async function adminDashboard(req, res) {
  try {
    const gymId = req.query.gym_id || req.user.selected_gym_id;

    if (!gymId) {
      return res.status(400).json({ error: 'No gym selected' });
    }

    const { data: stats } = await supabase.rpc('get_admin_dashboard_stats', { p_gym_id: gymId });

    const now = new Date();
    const sixMonthsAgo = new Date(now.getFullYear(), now.getMonth() - 5, 1);
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);

    const { data: revenueData } = await supabase
      .from('payments')
      .select('amount, payment_date')
      .eq('gym_id', gymId)
      .eq('status', 'completed')
      .gte('payment_date', sixMonthsAgo.toISOString())
      .order('payment_date', { ascending: true });

    const monthlyRevenue = {};
    revenueData?.forEach((p) => {
      const month = new Date(p.payment_date).toISOString().substring(0, 7);
      monthlyRevenue[month] = (monthlyRevenue[month] || 0) + Number(p.amount);
    });

    const { data: recentPayments } = await supabase
      .from('payments')
      .select('*, user:users(id, email), profile:user_profiles!user_id(full_name), plan:membership_plans(name)')
      .eq('gym_id', gymId)
      .order('payment_date', { ascending: false })
      .limit(5);

    const { data: expiring } = await supabase
      .from('members')
      .select('id, end_date, user:users(id, email), profile:user_profiles!user_id(full_name)')
      .eq('gym_id', gymId)
      .eq('status', 'active')
      .gte('end_date', now.toISOString().split('T')[0])
      .lte('end_date', new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000).toISOString().split('T')[0])
      .limit(10);

    const { data: planDistribution } = await supabase
      .from('members')
      .select('plan:membership_plans(name)')
      .eq('gym_id', gymId)
      .eq('status', 'active');

    const planCounts = {};
    planDistribution?.forEach((m) => {
      const name = m.plan?.name || 'No Plan';
      planCounts[name] = (planCounts[name] || 0) + 1;
    });

    return res.json({
      stats: stats || {},
      revenue_chart: Object.entries(monthlyRevenue).map(([month, revenue]) => ({ month, revenue })),
      recent_payments: recentPayments || [],
      expiring_memberships: expiring || [],
      membership_distribution: Object.entries(planCounts).map(([name, count]) => ({ name, count })),
    });
  } catch (err) {
    console.error('Admin dashboard error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}

export async function trainerDashboard(req, res) {
  try {
    const gymId = req.query.gym_id || req.user.selected_gym_id;

    const { data: stats } = await supabase.rpc('get_trainer_dashboard_stats', {
      p_user_id: req.user.id,
      p_gym_id: gymId,
    });

    const { data: assignedMembers } = await supabase
      .from('members')
      .select('id, status, end_date, user:users(id, email), profile:user_profiles!user_id(full_name, photo_url)')
      .eq('assigned_trainer_id', req.user.id)
      .eq('gym_id', gymId);

    const today = new Date().toISOString().split('T')[0];

    const { data: todaySchedule } = await supabase
      .from('workouts')
      .select('*, member:users!member_id(id, email), member_profile:user_profiles!member_id(full_name)')
      .eq('trainer_id', req.user.id)
      .eq('gym_id', gymId)
      .eq('schedule_date', today);

    const activeMembers = assignedMembers?.filter((m) => m.status === 'active').length || 0;

    return res.json({
      stats: stats || { assigned_members: activeMembers },
      assigned_members: assignedMembers || [],
      today_schedule: todaySchedule || [],
    });
  } catch (err) {
    console.error('Trainer dashboard error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}

export async function memberDashboard(req, res) {
  try {
    const gymId = req.query.gym_id || req.user.selected_gym_id;

    const { data: stats } = await supabase.rpc('get_member_dashboard_stats', {
      p_user_id: req.user.id,
      p_gym_id: gymId,
    });

    const { data: member } = await supabase
      .from('members')
      .select('*, plan:membership_plans(*), trainer:users!assigned_trainer_id(id, email), trainer_profile:user_profiles!assigned_trainer_id(full_name)')
      .eq('user_id', req.user.id)
      .eq('gym_id', gymId)
      .single();

    const today = new Date().toISOString().split('T')[0];

    const { data: todayWorkout } = await supabase
      .from('workouts')
      .select('*')
      .eq('member_id', req.user.id)
      .eq('schedule_date', today);

    const { data: recentProgress } = await supabase
      .from('progress_logs')
      .select('*')
      .eq('member_id', req.user.id)
      .order('date', { ascending: false })
      .limit(5);

    const { data: upcomingPayments } = await supabase
      .from('payments')
      .select('*')
      .eq('user_id', req.user.id)
      .eq('status', 'pending')
      .order('payment_date', { ascending: false });

    return res.json({
      stats: stats || {},
      member: member || {},
      today_workout: todayWorkout || [],
      recent_progress: recentProgress || [],
      upcoming_payments: upcomingPayments || [],
    });
  } catch (err) {
    console.error('Member dashboard error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}
