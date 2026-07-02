import React, { useState, useEffect } from 'react';
import { Send, Bell } from 'lucide-react';
import api from '../services/api';
import Modal from '../components/Modal';

export default function Notifications() {
  const [notifications, setNotifications] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showSend, setShowSend] = useState(false);
  const [form, setForm] = useState({ title: '', body: '', type: 'announcement', recipient_id: '' });
  const [showBulk, setShowBulk] = useState(false);
  const [bulkForm, setBulkForm] = useState({ title: '', body: '', type: 'announcement', role: '' });

  useEffect(() => { loadNotifications(); }, []);

  async function loadNotifications() {
    try {
      const data = await api.getNotifications({ unread_only: false });
      setNotifications(data.notifications || []);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  }

  const handleSend = async (e) => {
    e.preventDefault();
    try {
      await api.sendNotification(form);
      setShowSend(false);
      setForm({ title: '', body: '', type: 'announcement', recipient_id: '' });
    } catch (err) {
      alert(err.response?.data?.error || 'Failed');
    }
  };

  const handleBulk = async (e) => {
    e.preventDefault();
    try {
      await api.sendBulkNotification(bulkForm);
      setShowBulk(false);
      setBulkForm({ title: '', body: '', type: 'announcement', role: '' });
    } catch (err) {
      alert(err.response?.data?.error || 'Failed');
    }
  };

  const typeColors = {
    membership_expiry: 'bg-yellow-500/10 text-yellow-500',
    payment_reminder: 'bg-red-500/10 text-red-500',
    workout: 'bg-green-500/10 text-green-500',
    announcement: 'bg-blue-500/10 text-blue-500',
    promotional: 'bg-purple-500/10 text-purple-500',
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-white">Notifications</h1>
          <p className="text-dark-400 mt-1">{notifications.length} sent</p>
        </div>
        <div className="flex gap-3">
          <button onClick={() => setShowBulk(true)} className="btn-outline flex items-center gap-2">
            <Send size={18} /> Bulk Send
          </button>
          <button onClick={() => setShowSend(true)} className="btn-primary flex items-center gap-2">
            <Send size={18} /> Send
          </button>
        </div>
      </div>

      {loading ? (
        <div className="flex items-center justify-center h-64"><div className="w-8 h-8 border-2 border-primary-500 border-t-transparent rounded-full animate-spin" /></div>
      ) : (
        <div className="space-y-3">
          {notifications.length === 0 ? (
            <div className="text-center py-12 text-dark-400">No notifications sent yet</div>
          ) : (
            notifications.map((n) => (
              <div key={n.id} className="card flex items-start gap-4">
                <div className={`w-10 h-10 rounded-xl flex items-center justify-center shrink-0 ${typeColors[n.type] || typeColors.announcement}`}>
                  <Bell size={18} />
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center justify-between">
                    <h3 className="font-medium text-white text-sm">{n.title}</h3>
                    <span className="text-xs text-dark-400">{n.created_at?.substring(0, 10)}</span>
                  </div>
                  <p className="text-sm text-dark-400 mt-1">{n.body}</p>
                  <div className="flex items-center gap-3 mt-2">
                    <span className={`px-2 py-0.5 rounded text-xs font-medium ${typeColors[n.type] || typeColors.announcement}`}>
                      {n.type?.replace('_', ' ').toUpperCase()}
                    </span>
                    {n.sender_profile?.full_name && (
                      <span className="text-xs text-dark-500">by {n.sender_profile.full_name}</span>
                    )}
                  </div>
                </div>
              </div>
            ))
          )}
        </div>
      )}

      <Modal open={showSend} onClose={() => setShowSend(false)} title="Send Notification">
        <form onSubmit={handleSend} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-dark-300 mb-1">Recipient ID</label>
            <input type="text" value={form.recipient_id} onChange={(e) => setForm({ ...form, recipient_id: e.target.value })} className="input-field" required placeholder="User UUID" />
          </div>
          <div>
            <label className="block text-sm font-medium text-dark-300 mb-1">Title</label>
            <input type="text" value={form.title} onChange={(e) => setForm({ ...form, title: e.target.value })} className="input-field" required />
          </div>
          <div>
            <label className="block text-sm font-medium text-dark-300 mb-1">Body</label>
            <textarea value={form.body} onChange={(e) => setForm({ ...form, body: e.target.value })} className="input-field" rows={3} required />
          </div>
          <div>
            <label className="block text-sm font-medium text-dark-300 mb-1">Type</label>
            <select value={form.type} onChange={(e) => setForm({ ...form, type: e.target.value })} className="input-field">
              <option value="announcement">Announcement</option>
              <option value="workout">Workout</option>
              <option value="membership_expiry">Membership Expiry</option>
              <option value="payment_reminder">Payment Reminder</option>
              <option value="promotional">Promotional</option>
            </select>
          </div>
          <div className="flex gap-3 justify-end pt-2">
            <button type="button" onClick={() => setShowSend(false)} className="btn-outline">Cancel</button>
            <button type="submit" className="btn-primary">Send</button>
          </div>
        </form>
      </Modal>

      <Modal open={showBulk} onClose={() => setShowBulk(false)} title="Bulk Send Notification">
        <form onSubmit={handleBulk} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-dark-300 mb-1">Send To</label>
            <select value={bulkForm.role} onChange={(e) => setBulkForm({ ...bulkForm, role: e.target.value })} className="input-field">
              <option value="">All Members</option>
              <option value="member">Members only</option>
              <option value="trainer">Trainers only</option>
              <option value="admin">Admins only</option>
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-dark-300 mb-1">Title</label>
            <input type="text" value={bulkForm.title} onChange={(e) => setBulkForm({ ...bulkForm, title: e.target.value })} className="input-field" required />
          </div>
          <div>
            <label className="block text-sm font-medium text-dark-300 mb-1">Body</label>
            <textarea value={bulkForm.body} onChange={(e) => setBulkForm({ ...bulkForm, body: e.target.value })} className="input-field" rows={3} required />
          </div>
          <div>
            <label className="block text-sm font-medium text-dark-300 mb-1">Type</label>
            <select value={bulkForm.type} onChange={(e) => setBulkForm({ ...bulkForm, type: e.target.value })} className="input-field">
              <option value="announcement">Announcement</option>
              <option value="promotional">Promotional</option>
              <option value="workout">Workout</option>
            </select>
          </div>
          <div className="flex gap-3 justify-end pt-2">
            <button type="button" onClick={() => setShowBulk(false)} className="btn-outline">Cancel</button>
            <button type="submit" className="btn-primary">Send to All</button>
          </div>
        </form>
      </Modal>
    </div>
  );
}
