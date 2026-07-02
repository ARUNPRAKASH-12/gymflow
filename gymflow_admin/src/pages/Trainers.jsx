import React, { useState, useEffect } from 'react';
import { Plus, MoreVertical } from 'lucide-react';
import api from '../services/api';
import Modal from '../components/Modal';

export default function Trainers() {
  const [trainers, setTrainers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showAdd, setShowAdd] = useState(false);
  const [form, setForm] = useState({ email: '', full_name: '', phone: '', specialization: '' });

  useEffect(() => { loadTrainers(); }, []);

  async function loadTrainers() {
    try {
      const data = await api.getTrainers();
      setTrainers(Array.isArray(data) ? data : []);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  }

  const handleCreate = async (e) => {
    e.preventDefault();
    try {
      await api.createTrainer(form);
      setShowAdd(false);
      setForm({ email: '', full_name: '', phone: '', specialization: '' });
      loadTrainers();
    } catch (err) {
      alert(err.response?.data?.error || 'Failed to create');
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-white">Trainers</h1>
          <p className="text-dark-400 mt-1">{trainers.length} trainers</p>
        </div>
        <button onClick={() => setShowAdd(true)} className="btn-primary flex items-center gap-2">
          <Plus size={18} /> Add Trainer
        </button>
      </div>

      <div className="card overflow-hidden p-0">
        {loading ? (
          <div className="flex items-center justify-center h-64"><div className="w-8 h-8 border-2 border-primary-500 border-t-transparent rounded-full animate-spin" /></div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b border-dark-700">
                  <th className="text-left px-6 py-4 text-sm font-medium text-dark-400">Trainer</th>
                  <th className="text-left px-6 py-4 text-sm font-medium text-dark-400">Email</th>
                  <th className="text-left px-6 py-4 text-sm font-medium text-dark-400">Specialization</th>
                  <th className="text-left px-6 py-4 text-sm font-medium text-dark-400">Status</th>
                  <th className="text-right px-6 py-4 text-sm font-medium text-dark-400">Actions</th>
                </tr>
              </thead>
              <tbody>
                {trainers.length === 0 ? (
                  <tr><td colSpan="5" className="text-center py-12 text-dark-400">No trainers found</td></tr>
                ) : (
                  trainers.map((t) => (
                    <tr key={t.id} className="border-b border-dark-700 hover:bg-dark-800/50">
                      <td className="px-6 py-4">
                        <div className="flex items-center gap-3">
                          <div className="w-8 h-8 rounded-full bg-dark-700 flex items-center justify-center text-xs font-medium">
                            {t.profile?.full_name?.[0] || 'T'}
                          </div>
                          <span className="text-sm font-medium text-white">{t.profile?.full_name || 'Unknown'}</span>
                        </div>
                      </td>
                      <td className="px-6 py-4 text-sm text-dark-400">{t.user?.email || '-'}</td>
                      <td className="px-6 py-4 text-sm text-dark-400">{t.specialization || '-'}</td>
                      <td className="px-6 py-4">
                        <span className={`px-2 py-1 rounded-lg text-xs font-medium ${t.is_active ? 'bg-green-500/10 text-green-500' : 'bg-red-500/10 text-red-500'}`}>
                          {t.is_active ? 'ACTIVE' : 'INACTIVE'}
                        </span>
                      </td>
                      <td className="px-6 py-4 text-right">
                        <button className="text-dark-400 hover:text-white"><MoreVertical size={16} /></button>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        )}
      </div>

      <Modal open={showAdd} onClose={() => setShowAdd(false)} title="Add Trainer">
        <form onSubmit={handleCreate} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-dark-300 mb-1">Full Name</label>
            <input type="text" value={form.full_name} onChange={(e) => setForm({ ...form, full_name: e.target.value })} className="input-field" required />
          </div>
          <div>
            <label className="block text-sm font-medium text-dark-300 mb-1">Email</label>
            <input type="email" value={form.email} onChange={(e) => setForm({ ...form, email: e.target.value })} className="input-field" required />
          </div>
          <div>
            <label className="block text-sm font-medium text-dark-300 mb-1">Phone</label>
            <input type="text" value={form.phone} onChange={(e) => setForm({ ...form, phone: e.target.value })} className="input-field" />
          </div>
          <div>
            <label className="block text-sm font-medium text-dark-300 mb-1">Specialization</label>
            <input type="text" value={form.specialization} onChange={(e) => setForm({ ...form, specialization: e.target.value })} className="input-field" placeholder="e.g., Strength Training" />
          </div>
          <div className="flex gap-3 justify-end pt-2">
            <button type="button" onClick={() => setShowAdd(false)} className="btn-outline">Cancel</button>
            <button type="submit" className="btn-primary">Create Trainer</button>
          </div>
        </form>
      </Modal>
    </div>
  );
}
