import { supabase } from '../config/supabase.js';
import QRCode from 'qrcode';

export async function listAttendance(req, res) {
  try {
    const { gym_id, date, user_id, page = 1, limit = 50 } = req.query;
    const targetGym = gym_id || req.user.selected_gym_id;

    let query = supabase
      .from('attendance')
      .select('*, user:users(id, email), profile:user_profiles!user_id(full_name, photo_url)')
      .order('check_in', { ascending: false });

    if (targetGym) query = query.eq('gym_id', targetGym);
    if (date) query = query.eq('date', date);
    if (user_id) query = query.eq('user_id', user_id);

    const from = (page - 1) * limit;
    query = query.range(from, from + limit - 1);

    const { data: records, error } = await query;
    if (error) throw error;

    return res.json(records || []);
  } catch (err) {
    console.error('List attendance error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}

export async function todayAttendance(req, res) {
  try {
    const { gym_id } = req.query;
    const targetGym = gym_id || req.user.selected_gym_id;

    const { data: records, error } = await supabase
      .from('attendance')
      .select('*, user:users(id, email), profile:user_profiles!user_id(full_name, photo_url)')
      .eq('gym_id', targetGym)
      .eq('date', new Date().toISOString().split('T')[0])
      .order('check_in', { ascending: false });

    if (error) throw error;

    const checkedIn = records?.filter(r => !r.check_out)?.length || 0;
    const checkedOut = records?.filter(r => r.check_out)?.length || 0;

    return res.json({ total: records?.length || 0, checked_in: checkedIn, checked_out: checkedOut, records: records || [] });
  } catch (err) {
    console.error('Today attendance error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}

export async function myAttendance(req, res) {
  try {
    const { from, to, limit = 30 } = req.query;

    let query = supabase
      .from('attendance')
      .select('*')
      .eq('user_id', req.user.id)
      .order('date', { ascending: false })
      .limit(Number(limit));

    if (from) query = query.gte('date', from);
    if (to) query = query.lte('date', to);

    const { data: records, error } = await query;
    if (error) throw error;

    const thisMonth = records?.filter(r => {
      const d = new Date(r.date);
      const now = new Date();
      return d.getMonth() === now.getMonth() && d.getFullYear() === now.getFullYear();
    })?.length || 0;

    return res.json({ records: records || [], this_month_count: thisMonth });
  } catch (err) {
    console.error('My attendance error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}

export async function checkIn(req, res) {
  try {
    const { gym_id, method, notes } = req.validated.body;
    const targetGym = gym_id || req.user.selected_gym_id;

    const today = new Date().toISOString().split('T')[0];

    const { data: existing } = await supabase
      .from('attendance')
      .select('id, check_out')
      .eq('user_id', req.user.id)
      .eq('date', today)
      .single();

    if (existing && !existing.check_out) {
      return res.status(400).json({ error: 'Already checked in today. Check out first.' });
    }

    if (existing && existing.check_out) {
      return res.status(400).json({ error: 'Already checked in and out today.' });
    }

    const { data: record, error } = await supabase
      .from('attendance')
      .insert({
        user_id: req.user.id,
        gym_id: targetGym,
        check_in: new Date().toISOString(),
        date: today,
        method: method || 'manual',
        notes: notes || null,
      })
      .select('*, profile:user_profiles!user_id(full_name)')
      .single();

    if (error) return res.status(400).json({ error: error.message });

    return res.status(201).json({ message: 'Checked in successfully', record });
  } catch (err) {
    console.error('Check-in error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}

export async function checkOut(req, res) {
  try {
    const { id } = req.params;

    const { data: record, error: fetchError } = await supabase
      .from('attendance')
      .select('*')
      .eq('id', id)
      .single();

    if (fetchError) return res.status(404).json({ error: 'Attendance record not found' });

    if (record.user_id !== req.user.id && req.user.role === 'member') {
      return res.status(403).json({ error: 'Cannot check out for another user' });
    }

    if (record.check_out) {
      return res.status(400).json({ error: 'Already checked out' });
    }

    const { data: updated, error } = await supabase
      .from('attendance')
      .update({ check_out: new Date().toISOString() })
      .eq('id', id)
      .select()
      .single();

    if (error) return res.status(400).json({ error: error.message });

    const checkIn = new Date(record.check_in);
    const checkOut = new Date(updated.check_out);
    const durationMs = checkOut - checkIn;
    const durationMin = Math.round(durationMs / 60000);

    return res.json({ message: 'Checked out successfully', record: updated, duration_minutes: durationMin });
  } catch (err) {
    console.error('Check-out error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}

export async function attendanceReport(req, res) {
  try {
    const { gym_id, from, to } = req.query;
    const targetGym = gym_id || req.user.selected_gym_id;

    if (!from || !to) {
      return res.status(400).json({ error: 'Date range (from, to) is required' });
    }

    const { data, error } = await supabase
      .rpc('get_attendance_report', { p_gym_id: targetGym, p_from: from, p_to: to });

    if (error) {
      const { data: records } = await supabase
        .from('attendance')
        .select('date, check_in, check_out, user_id')
        .eq('gym_id', targetGym)
        .gte('date', from)
        .lte('date', to)
        .order('date');

      const dailyCount = {};
      records?.forEach((r) => {
        dailyCount[r.date] = (dailyCount[r.date] || 0) + 1;
      });

      return res.json({
        total_records: records?.length || 0,
        unique_members: new Set(records?.map(r => r.user_id)).size,
        daily_breakdown: Object.entries(dailyCount).map(([date, count]) => ({ date, count })),
        records: records || [],
      });
    }

    return res.json(data);
  } catch (err) {
    console.error('Attendance report error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}

export async function generateQR(req, res) {
  try {
    const { gym_id } = req.query;
    const targetGym = gym_id || req.user.selected_gym_id;

    const today = new Date().toISOString().split('T')[0];
    const qrData = JSON.stringify({ gym_id: targetGym, date: today, type: 'attendance' });

    const qrCodeDataUrl = await QRCode.toDataURL(qrData, {
      width: 400,
      margin: 2,
      color: { dark: '#000000', light: '#FFFFFF' },
    });

    const { data: existing } = await supabase
      .from('qr_codes')
      .select('id')
      .eq('gym_id', targetGym)
      .eq('date', today)
      .single();

    if (!existing) {
      await supabase.from('qr_codes').insert({
        gym_id: targetGym,
        code: qrData,
        date: today,
        expires_at: new Date(new Date().setHours(23, 59, 59, 999)).toISOString(),
      });
    }

    return res.json({ qr_code: qrCodeDataUrl, data: qrData, date: today });
  } catch (err) {
    console.error('Generate QR error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}
