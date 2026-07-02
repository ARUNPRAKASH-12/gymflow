import React, { useState, useEffect } from 'react';
import { Plus, Check } from 'lucide-react';
import api from '../services/api';
import Modal from '../components/Modal';

export default function Plans() {
  const [plans, setPlans] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showAdd, setShowAdd] = useState(false);
  const [form, setForm] = useState({ name: '', duration_days: 30, price: '', description: '', features: '' });

  useEffect(() => { loadPlans(); }, []);

  async function loadPlans() {
    try {
      const data = await api.getPlans();
      setPlans(Array.isArray(data) ? data : []);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  }

  const handleCreate = async (e) => {
    e.preventDefault();
    try {
      await api.createPlan({
        ...form,
        price: parseFloat(form.price),
        duration_days: parseInt(form.duration_days),
        features: form.features.split('\n').filter(Boolean),
      });
      setShowAdd(false);
      setForm({ name: '', duration_days: 30, price: '', description: '', features: '' });
      loadPlans();
    } catch (err) {
      alert(err.response?.data?.error || 'Failed to create');
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-white">Membership Plans</h1>
          <p className="text-dark-400 mt-1">{plans.length} plans</p>
        </div>
        <button onClick={() => setShowAdd(true)} className="btn-primary flex items-center gap-2">
          <Plus size={18} /> Add Plan
        </button>
      </div>

      {loading ? (
        <div className="flex items-center justify-center h-64"><div className="w-8 h-8 border-2 border-primary-500 border-t-transparent rounded-full animate-spin" /></div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
          {plans.map((plan) => (
            <div key={plan.id} className="card flex flex-col">
              <div className="mb-4">
                <h3 className="text-lg font-semibold text-white">{plan.name}</h3>
                <p className="text-3xl font-bold text-primary-500 mt-2">₹{plan.price?.toLocaleString()}</p>
                <p className="text-sm text-dark-400">{plan.duration_days} days</p>
              </div>
              {plan.description && (
                <p className="text-sm text-dark-400 mb-4">{plan.description}</p>
              )}
              {plan.features?.length > 0 && (
                <div className="space-y-2 mb-6">
                  {plan.features.map((f, i) => (
                    <div key={i} className="flex items-start gap-2">
                      <Check size={14} className="text-green-500 mt-0.5 shrink-0" />
                      <span className="text-sm text-dark-300">{f}</span>
                    </div>
                  ))}
                </div>
              )}
              <div className="mt-auto pt-4 border-t border-dark-700">
                <span className={`px-2 py-1 rounded-lg text-xs font-medium ${plan.is_active ? 'bg-green-500/10 text-green-500' : 'bg-red-500/10 text-red-500'}`}>
                  {plan.is_active ? 'ACTIVE' : 'INACTIVE'}
                </span>
              </div>
            </div>
          ))}
        </div>
      )}

      <Modal open={showAdd} onClose={() => setShowAdd(false)} title="Create Membership Plan">
        <form onSubmit={handleCreate} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-dark-300 mb-1">Plan Name</label>
            <input type="text" value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })} className="input-field" required placeholder="e.g., Monthly Plan" />
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-dark-300 mb-1">Duration (days)</label>
              <input type="number" value={form.duration_days} onChange={(e) => setForm({ ...form, duration_days: e.target.value })} className="input-field" required />
            </div>
            <div>
              <label className="block text-sm font-medium text-dark-300 mb-1">Price (₹)</label>
              <input type="number" value={form.price} onChange={(e) => setForm({ ...form, price: e.target.value })} className="input-field" required />
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-dark-300 mb-1">Description</label>
            <textarea value={form.description} onChange={(e) => setForm({ ...form, description: e.target.value })} className="input-field" rows={2} />
          </div>
          <div>
            <label className="block text-sm font-medium text-dark-300 mb-1">Features (one per line)</label>
            <textarea value={form.features} onChange={(e) => setForm({ ...form, features: e.target.value })} className="input-field" rows={4} placeholder="Full gym access&#10;Locker facility&#10;Personal trainer" />
          </div>
          <div className="flex gap-3 justify-end pt-2">
            <button type="button" onClick={() => setShowAdd(false)} className="btn-outline">Cancel</button>
            <button type="submit" className="btn-primary">Create Plan</button>
          </div>
        </form>
      </Modal>
    </div>
  );
}
