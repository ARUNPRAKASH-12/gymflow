import { supabase } from '../config/supabase.js';

export async function myNotifications(req, res) {
  try {
    const { unread_only } = req.query;

    let query = supabase
      .from('notifications')
      .select('*, sender:users!sender_id(id, email), sender_profile:user_profiles!sender_id(full_name)')
      .eq('recipient_id', req.user.id)
      .order('created_at', { ascending: false })
      .limit(50);

    if (unread_only === 'true') {
      query = query.eq('is_read', false);
    }

    const { data: notifications, error } = await query;
    if (error) throw error;

    const unreadCount = notifications?.filter((n) => !n.is_read).length || 0;

    return res.json({ notifications: notifications || [], unread_count: unreadCount });
  } catch (err) {
    console.error('My notifications error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}

export async function markRead(req, res) {
  try {
    const { id } = req.params;

    const { data: notification, error } = await supabase
      .from('notifications')
      .update({ is_read: true, read_at: new Date().toISOString() })
      .eq('id', id)
      .eq('recipient_id', req.user.id)
      .select()
      .single();

    if (error) return res.status(400).json({ error: error.message });

    return res.json(notification);
  } catch (err) {
    console.error('Mark read error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}

export async function sendNotification(req, res) {
  try {
    const { recipient_id, title, body, type } = req.body;

    if (!recipient_id || !title || !body) {
      return res.status(400).json({ error: 'recipient_id, title, and body are required' });
    }

    const { data: notification, error } = await supabase.from('notifications').insert({
      gym_id: req.user.selected_gym_id,
      sender_id: req.user.id,
      recipient_id,
      title,
      body,
      type: type || 'announcement',
    }).select().single();

    if (error) return res.status(400).json({ error: error.message });

    return res.status(201).json(notification);
  } catch (err) {
    console.error('Send notification error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}

export async function sendBulkNotification(req, res) {
  try {
    const { role, title, body, type } = req.body;

    if (!title || !body) {
      return res.status(400).json({ error: 'title and body are required' });
    }

    let query = supabase
      .from('user_gyms')
      .select('user_id')
      .eq('gym_id', req.user.selected_gym_id)
      .eq('is_active', true);

    if (role) query = query.eq('role', role);

    const { data: recipients } = await query;

    if (!recipients?.length) {
      return res.status(404).json({ error: 'No recipients found' });
    }

    const notifications = recipients.map((r) => ({
      gym_id: req.user.selected_gym_id,
      sender_id: req.user.id,
      recipient_id: r.user_id,
      title,
      body,
      type: type || 'announcement',
    }));

    const { data: created, error } = await supabase
      .from('notifications')
      .insert(notifications)
      .select();

    if (error) return res.status(400).json({ error: error.message });

    return res.status(201).json({ message: `Sent to ${created?.length} recipients`, count: created?.length });
  } catch (err) {
    console.error('Send bulk notification error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}
