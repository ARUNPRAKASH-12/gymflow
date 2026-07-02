import { supabase } from '../config/supabase.js';

export async function revenueReport(req, res) {
  try {
    const { gym_id, from, to } = req.query;
    const targetGym = gym_id || req.user.selected_gym_id;

    let query = supabase
      .from('payments')
      .select('amount, payment_date, method, plan:membership_plans(name)')
      .eq('gym_id', targetGym)
      .eq('status', 'completed');

    if (from) query = query.gte('payment_date', from);
    if (to) query = query.lte('payment_date', to);

    const { data: payments } = await query.order('payment_date', { ascending: true });

    const totalRevenue = payments?.reduce((s, p) => s + Number(p.amount), 0) || 0;
    const monthly = {};
    payments?.forEach((p) => {
      const m = new Date(p.payment_date).toISOString().substring(0, 7);
      monthly[m] = (monthly[m] || 0) + Number(p.amount);
    });

    const byPlan = {};
    payments?.forEach((p) => {
      const name = p.plan?.name || 'Other';
      byPlan[name] = (byPlan[name] || 0) + Number(p.amount);
    });

    return res.json({
      total_revenue: totalRevenue,
      transaction_count: payments?.length || 0,
      monthly_breakdown: Object.entries(monthly).map(([m, r]) => ({ month: m, revenue: r })),
      plan_breakdown: Object.entries(byPlan).map(([n, r]) => ({ plan: n, revenue: r })),
    });
  } catch (err) {
    console.error('Revenue report error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}

export async function attendanceReport(req, res) {
  try {
    const { gym_id, from, to } = req.query;
    const targetGym = gym_id || req.user.selected_gym_id;

    let query = supabase
      .from('attendance')
      .select('date, user_id, check_in, check_out, method')
      .eq('gym_id', targetGym);

    if (from) query = query.gte('date', from);
    if (to) query = query.lte('date', to);

    const { data: records } = await query.order('date', { ascending: true });

    const dailyCount = {};
    const uniqueMembers = new Set();
    records?.forEach((r) => {
      dailyCount[r.date] = (dailyCount[r.date] || 0) + 1;
      uniqueMembers.add(r.user_id);
    });

    const avgDuration = records?.filter(r => r.check_in && r.check_out).reduce((s, r) => {
      const diff = new Date(r.check_out) - new Date(r.check_in);
      return s + diff / 60000;
    }, 0) || 0;
    const avgMinutes = records?.filter(r => r.check_in && r.check_out).length
      ? Math.round(avgDuration / records.filter(r => r.check_in && r.check_out).length) : 0;

    return res.json({
      total_records: records?.length || 0,
      unique_members: uniqueMembers.size,
      avg_duration_minutes: avgMinutes,
      daily_breakdown: Object.entries(dailyCount).map(([d, c]) => ({ date: d, count: c })),
    });
  } catch (err) {
    console.error('Attendance report error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}

export async function membershipReport(req, res) {
  try {
    const { gym_id } = req.query;
    const targetGym = gym_id || req.user.selected_gym_id;

    const { data: members } = await supabase
      .from('members')
      .select('status, plan:membership_plans(name)')
      .eq('gym_id', targetGym);

    const byStatus = { active: 0, expired: 0, cancelled: 0, pending: 0 };
    const byPlan = {};

    members?.forEach((m) => {
      byStatus[m.status] = (byStatus[m.status] || 0) + 1;
      const planName = m.plan?.name || 'No Plan';
      byPlan[planName] = (byPlan[planName] || 0) + 1;
    });

    return res.json({
      total: members?.length || 0,
      by_status: byStatus,
      by_plan: Object.entries(byPlan).map(([n, c]) => ({ plan: n, count: c })),
    });
  } catch (err) {
    console.error('Membership report error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}

export async function memberGrowthReport(req, res) {
  try {
    const { gym_id, months = 12 } = req.query;
    const targetGym = gym_id || req.user.selected_gym_id;
    const numMonths = Number(months);

    const startDate = new Date();
    startDate.setMonth(startDate.getMonth() - numMonths);

    const { data: members } = await supabase
      .from('members')
      .select('join_date, status')
      .eq('gym_id', targetGym)
      .gte('join_date', startDate.toISOString().split('T')[0]);

    const monthly = {};
    for (let i = 0; i < numMonths; i++) {
      const d = new Date();
      d.setMonth(d.getMonth() - i);
      const key = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`;
      monthly[key] = { joined: 0, active: 0, expired: 0 };
    }

    members?.forEach((m) => {
      const key = m.join_date?.substring(0, 7);
      if (key && monthly[key]) {
        monthly[key].joined++;
        if (m.status === 'active') monthly[key].active++;
      }
    });

    return res.json({
      monthly_growth: Object.entries(monthly).map(([month, data]) => ({ month, ...data })),
    });
  } catch (err) {
    console.error('Member growth report error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}

export async function trainerPerformanceReport(req, res) {
  try {
    const { gym_id } = req.query;
    const targetGym = gym_id || req.user.selected_gym_id;

    const { data: trainers } = await supabase
      .from('trainers')
      .select('user_id, specialization, user:users(id, email), profile:user_profiles!user_id(full_name)')
      .eq('gym_id', targetGym)
      .eq('is_active', true);

    const performance = [];
    for (const trainer of trainers || []) {
      const { data: memberCount } = await supabase
        .from('members')
        .select('id', { count: 'exact', head: true })
        .eq('assigned_trainer_id', trainer.user_id);

      const { data: workoutCount } = await supabase
        .from('workouts')
        .select('id', { count: 'exact', head: true })
        .eq('trainer_id', trainer.user_id);

      performance.push({
        trainer: trainer.profile?.full_name || 'Unknown',
        specialization: trainer.specialization,
        assigned_members: memberCount?.length || 0,
        workouts_created: workoutCount?.length || 0,
      });
    }

    return res.json(performance);
  } catch (err) {
    console.error('Trainer performance report error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}

export async function exportReport(req, res) {
  try {
    const { type } = req.params;
    const { gym_id, from, to, format = 'json' } = req.query;
    const targetGym = gym_id || req.user.selected_gym_id;

    let data;

    switch (type) {
      case 'revenue': {
        const { data: payments } = await supabase
          .from('payments')
          .select('*, profile:user_profiles!user_id(full_name)')
          .eq('gym_id', targetGym)
          .eq('status', 'completed');
        data = payments;
        break;
      }
      case 'members': {
        const { data: members } = await supabase
          .from('members')
          .select('*, profile:user_profiles!user_id(full_name, phone, email)')
          .eq('gym_id', targetGym);
        data = members;
        break;
      }
      case 'attendance': {
        const { data: attendance } = await supabase
          .from('attendance')
          .select('*, profile:user_profiles!user_id(full_name)')
          .eq('gym_id', targetGym);
        data = attendance;
        break;
      }
      case 'payments': {
        const { data: payments } = await supabase
          .from('payments')
          .select('*, profile:user_profiles!user_id(full_name), plan:membership_plans(name)')
          .eq('gym_id', targetGym);
        data = payments;
        break;
      }
      default:
        return res.status(400).json({ error: 'Invalid report type' });
    }

    if (format === 'xlsx') {
      const { exportToExcel, getExcelColumns, mapDataForExport } = await import('../services/export.service.js');
      const columns = getExcelColumns(type);
      const rows = mapDataForExport(type, data);
      const buffer = await exportToExcel(rows, {
        sheetName: type.charAt(0).toUpperCase() + type.slice(1),
        columns,
        filename: `${type}_report.xlsx`,
      });
      res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      res.setHeader('Content-Disposition', `attachment; filename="${type}_report.xlsx"`);
      return res.send(Buffer.from(buffer));
    }

    return res.json(data || []);
  } catch (err) {
    console.error('Export report error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}
