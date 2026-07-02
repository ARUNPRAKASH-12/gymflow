import React, { useState, useEffect } from 'react';
import { IndianRupee, Plus, Download } from 'lucide-react';
import api from '../services/api';
import Modal from '../components/Modal';

export default function Payments() {
  const [payments, setPayments] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showAdd, setShowAdd] = useState(false);
  const [form, setForm] = useState({ user_id: '', amount: '', method: 'cash', transaction_id: '' });
  const [members, setMembers] = useState([]);

  useEffect(() => { loadPayments(); loadMembers(); }, []);

  async function loadPayments() {
    try {
      const data = await api.getPayments();
      setPayments(Array.isArray(data) ? data : []);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  }

  async function loadMembers() {
    try {
      const data = await api.getMembers();
      setMembers(data.members || data || []);
    } catch (err) {
      console.error(err);
    }
  }

  const handleCreate = async (e) => {
    e.preventDefault();
    try {
      await api.createPayment({ ...form, amount: parseFloat(form.amount) });
      setShowAdd(false);
      setForm({ user_id: '', amount: '', method: 'cash', transaction_id: '' });
      loadPayments();
    } catch (err) {
      alert(err.response?.data?.error || 'Failed');
    }
  };

  const totalRevenue = payments.filter(p => p.status === 'completed').reduce((s, p) => s + (p.amount || 0), 0);

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-white">Payments</h1>
          <p className="text-dark-400 mt-1">{payments.length} transactions</p>
        </div>
        <button onClick={() => setShowAdd(true)} className="btn-primary flex items-center gap-2">
          <Plus size={18} /> Record Payment
        </button>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <div className="card">
          <p className="text-3xl font-bold text-primary-500">₹{totalRevenue.toLocaleString()}</p>
          <p className="text-sm text-dark-400 mt-1">Total Revenue</p>
        </div>
        <div className="card">
          <p className="text-3xl font-bold text-white">{payments.length}</p>
          <p className="text-sm text-dark-400 mt-1">Transactions</p>
        </div>
        <div className="card">
          <p className="text-3xl font-bold text-green-500">{payments.filter(p => p.status === 'completed').length}</p>
          <p className="text-sm text-dark-400 mt-1">Completed</p>
        </div>
      </div>

      <div className="card overflow-hidden p-0">
        {loading ? (
          <div className="flex items-center justify-center h-64"><div className="w-8 h-8 border-2 border-primary-500 border-t-transparent rounded-full animate-spin" /></div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b border-dark-700">
                  <th className="text-left px-6 py-4 text-sm font-medium text-dark-400">Member</th>
                  <th className="text-left px-6 py-4 text-sm font-medium text-dark-400">Amount</th>
                  <th className="text-left px-6 py-4 text-sm font-medium text-dark-400">Method</th>
                  <th className="text-left px-6 py-4 text-sm font-medium text-dark-400">Plan</th>
                  <th className="text-left px-6 py-4 text-sm font-medium text-dark-400">Date</th>
                  <th className="text-left px-6 py-4 text-sm font-medium text-dark-400">Status</th>
                  <th className="text-right px-6 py-4 text-sm font-medium text-dark-400">Invoice</th>
                </tr>
              </thead>
              <tbody>
                {payments.length === 0 ? (
                  <tr><td colSpan="6" className="text-center py-12 text-dark-400">No payments found</td></tr>
                ) : (
                  payments.map((p, i) => (
                    <tr key={p.id || i} className="border-b border-dark-700 hover:bg-dark-800/50">
                      <td className="px-6 py-4 text-sm text-white">{p.profile?.full_name || p.member_name || 'Member'}</td>
                      <td className="px-6 py-4 text-sm font-semibold text-white">₹{p.amount?.toLocaleString()}</td>
                      <td className="px-6 py-4 text-sm text-dark-400">{p.method?.toUpperCase()}</td>
                      <td className="px-6 py-4 text-sm text-dark-400">{p.plan?.name || '-'}</td>
                      <td className="px-6 py-4 text-sm text-dark-400">{p.payment_date?.substring(0, 10)}</td>
                      <td className="px-6 py-4">
                        <span className={`px-2 py-1 rounded-lg text-xs font-medium ${
                          p.status === 'completed' ? 'bg-green-500/10 text-green-500' :
                          p.status === 'pending' ? 'bg-yellow-500/10 text-yellow-500' :
                          'bg-red-500/10 text-red-500'
                        }`}>{p.status?.toUpperCase()}</span>
                      </td>
                      <td className="px-6 py-4 text-right">
                        {p.status === 'completed' && (
                          <button
                            onClick={() => api.downloadInvoice(p.id)}
                            className="text-dark-400 hover:text-primary-500 transition-colors"
                            title="Download Invoice"
                          >
                            <Download size={16} />
                          </button>
                        )}
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        )}
      </div>

      <Modal open={showAdd} onClose={() => setShowAdd(false)} title="Record Payment">
        <form onSubmit={handleCreate} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-dark-300 mb-1">Member</label>
            <select value={form.user_id} onChange={(e) => setForm({ ...form, user_id: e.target.value })} className="input-field" required>
              <option value="">Select member</option>
              {members.map((m) => (
                <option key={m.user_id || m.id} value={m.user_id || m.id}>
                  {m.profile?.full_name || m.email || 'Unknown'}
                </option>
              ))}
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-dark-300 mb-1">Amount (₹)</label>
            <input type="number" value={form.amount} onChange={(e) => setForm({ ...form, amount: e.target.value })} className="input-field" required />
          </div>
          <div>
            <label className="block text-sm font-medium text-dark-300 mb-1">Method</label>
            <select value={form.method} onChange={(e) => setForm({ ...form, method: e.target.value })} className="input-field">
              <option value="cash">Cash</option>
              <option value="razorpay">Razorpay</option>
              <option value="upi">UPI</option>
              <option value="card">Card</option>
              <option value="bank_transfer">Bank Transfer</option>
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-dark-300 mb-1">Transaction ID (optional)</label>
            <input type="text" value={form.transaction_id} onChange={(e) => setForm({ ...form, transaction_id: e.target.value })} className="input-field" />
          </div>
          <div className="flex gap-3 justify-end pt-2">
            <button type="button" onClick={() => setShowAdd(false)} className="btn-outline">Cancel</button>
            <button type="submit" className="btn-primary">Record Payment</button>
          </div>
        </form>
      </Modal>
    </div>
  );
}
