import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Search, Plus, Filter, MoreVertical, Edit, Trash2, UserCheck } from 'lucide-react';
import api from '../services/api';
import Modal from '../components/Modal';

export default function Members() {
  const [members, setMembers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [showAdd, setShowAdd] = useState(false);
  const [form, setForm] = useState({ email: '', full_name: '', phone: '' });
  const navigate = useNavigate();

  useEffect(() => { loadMembers(); }, []);

  async function loadMembers() {
    try {
      const data = await api.getMembers({ search });
      setMembers(data.members || data || []);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  }

  const handleCreate = async (e) => {
    e.preventDefault();
    try {
      await api.createMember(form);
      setShowAdd(false);
      setForm({ email: '', full_name: '', phone: '' });
      loadMembers();
    } catch (err) {
      alert(err.response?.data?.error || 'Failed to create');
    }
  };

  const getStatusBadge = (status) => {
    const colors = {
      active: 'bg-green-500/10 text-green-500',
      expired: 'bg-red-500/10 text-red-500',
      pending: 'bg-yellow-500/10 text-yellow-500',
      cancelled: 'bg-gray-500/10 text-gray-500',
    };
    return `px-2 py-1 rounded-lg text-xs font-medium ${colors[status] || colors.pending}`;
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-white">Members</h1>
          <p className="text-dark-400 mt-1">{members.length} total members</p>
        </div>
        <button onClick={() => setShowAdd(true)} className="btn-primary flex items-center gap-2">
          <Plus size={18} />
          Add Member
        </button>
      </div>

      {/* Search & Filters */}
      <div className="flex items-center gap-4">
        <div className="relative flex-1 max-w-md">
          <Search size={18} className="absolute left-3 top-1/2 -translate-y-1/2 text-dark-400" />
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search members..."
            className="input-field pl-10"
            onKeyDown={(e) => e.key === 'Enter' && loadMembers()}
          />
        </div>
        <button className="btn-outline flex items-center gap-2">
          <Filter size={16} />
          Filter
        </button>
      </div>

      {/* Table */}
      <div className="card overflow-hidden p-0">
        {loading ? (
          <div className="flex items-center justify-center h-64">
            <div className="w-8 h-8 border-2 border-primary-500 border-t-transparent rounded-full animate-spin" />
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b border-dark-700">
                  <th className="text-left px-6 py-4 text-sm font-medium text-dark-400">Member</th>
                  <th className="text-left px-6 py-4 text-sm font-medium text-dark-400">Email</th>
                  <th className="text-left px-6 py-4 text-sm font-medium text-dark-400">Plan</th>
                  <th className="text-left px-6 py-4 text-sm font-medium text-dark-400">Status</th>
                  <th className="text-left px-6 py-4 text-sm font-medium text-dark-400">End Date</th>
                  <th className="text-right px-6 py-4 text-sm font-medium text-dark-400">Actions</th>
                </tr>
              </thead>
              <tbody>
                {members.length === 0 ? (
                  <tr>
                    <td colSpan="6" className="text-center py-12 text-dark-400">No members found</td>
                  </tr>
                ) : (
                  members.map((m) => (
                    <tr key={m.id} className="border-b border-dark-700 hover:bg-dark-800/50 cursor-pointer" onClick={() => navigate(`/members/${m.id}`)}>
                      <td className="px-6 py-4">
                        <div className="flex items-center gap-3">
                          <div className="w-8 h-8 rounded-full bg-dark-700 flex items-center justify-center text-xs font-medium">
                            {m.profile?.full_name?.[0] || '?'}
                          </div>
                          <span className="text-sm font-medium text-white">{m.profile?.full_name || 'Unknown'}</span>
                        </div>
                      </td>
                      <td className="px-6 py-4 text-sm text-dark-400">{m.user?.email || '-'}</td>
                      <td className="px-6 py-4 text-sm text-dark-400">{m.plan?.name || '-'}</td>
                      <td className="px-6 py-4">
                        <span className={getStatusBadge(m.status)}>{m.status?.toUpperCase()}</span>
                      </td>
                      <td className="px-6 py-4 text-sm text-dark-400">{m.end_date || '-'}</td>
                      <td className="px-6 py-4 text-right">
                        <button className="text-dark-400 hover:text-white transition-colors">
                          <MoreVertical size={16} />
                        </button>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        )}
      </div>

      <Modal open={showAdd} onClose={() => setShowAdd(false)} title="Add New Member">
        <form onSubmit={handleCreate} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-dark-300 mb-1">Full Name</label>
            <input type="text" value={form.full_name} onChange={(e) => setForm({ ...form, full_name: e.target.value })}
              className="input-field" required />
          </div>
          <div>
            <label className="block text-sm font-medium text-dark-300 mb-1">Email</label>
            <input type="email" value={form.email} onChange={(e) => setForm({ ...form, email: e.target.value })}
              className="input-field" required />
          </div>
          <div>
            <label className="block text-sm font-medium text-dark-300 mb-1">Phone</label>
            <input type="text" value={form.phone} onChange={(e) => setForm({ ...form, phone: e.target.value })}
              className="input-field" />
          </div>
          <div className="flex gap-3 justify-end pt-2">
            <button type="button" onClick={() => setShowAdd(false)} className="btn-outline">Cancel</button>
            <button type="submit" className="btn-primary">Create Member</button>
          </div>
        </form>
      </Modal>
    </div>
  );
}
