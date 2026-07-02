import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Users, Dumbbell, CalendarCheck, IndianRupee, Timer, TrendingUp,
  AlertTriangle, CheckCircle, XCircle,
} from 'lucide-react';
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, PieChart, Pie, Cell, Legend } from 'recharts';
import StatCard from '../components/StatCard';
import api from '../services/api';

const COLORS = ['#FF6B35', '#2563EB', '#22C55E', '#F59E0B', '#EF4444'];

export default function Dashboard() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();

  useEffect(() => { loadData(); }, []);

  async function loadData() {
    try {
      const result = await api.getAdminDashboard();
      setData(result);
    } catch (err) {
      console.error('Dashboard load error:', err);
    } finally {
      setLoading(false);
    }
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="w-8 h-8 border-2 border-primary-500 border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  const stats = data?.stats || {};
  const revenueChart = data?.revenue_chart || [];
  const membershipDist = data?.membership_distribution || [];
  const recentPayments = data?.recent_payments || [];
  const expiring = data?.expiring_memberships || [];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-white">Dashboard</h1>
        <p className="text-dark-400 mt-1">Overview of your gym operations</p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-6 gap-4">
        <StatCard title="Total Members" value={stats.total_members || 0} icon={Users} color="primary" />
        <StatCard title="Active Members" value={stats.active_members || 0} icon={CheckCircle} color="success" />
        <StatCard title="Expired" value={stats.expired_members || 0} icon={XCircle} color="danger" />
        <StatCard title="Today's Attendance" value={stats.today_attendance || 0} icon={CalendarCheck} color="info" />
        <StatCard title="Revenue (Month)" value={`₹${(stats.monthly_revenue || 0).toLocaleString()}`} icon={IndianRupee} color="warning" />
        <StatCard title="Trainers" value={stats.total_trainers || 0} icon={Dumbbell} color="secondary" />
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Revenue Chart */}
        <div className="card">
          <h2 className="text-lg font-semibold text-white mb-4">Monthly Revenue</h2>
          {revenueChart.length > 0 ? (
            <ResponsiveContainer width="100%" height={280}>
              <BarChart data={revenueChart}>
                <XAxis dataKey="month" tick={{ fill: '#64748b', fontSize: 12 }} />
                <YAxis tick={{ fill: '#64748b', fontSize: 12 }} />
                <Tooltip
                  contentStyle={{ background: '#1E2A4A', border: '1px solid #2D3A5C', borderRadius: '12px', color: '#fff' }}
                  formatter={(v) => [`₹${v.toLocaleString()}`, 'Revenue']}
                />
                <Bar dataKey="revenue" fill="#FF6B35" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          ) : (
            <div className="flex items-center justify-center h-[280px] text-dark-400">No revenue data yet</div>
          )}
        </div>

        {/* Membership Distribution */}
        <div className="card">
          <h2 className="text-lg font-semibold text-white mb-4">Membership Distribution</h2>
          {membershipDist.length > 0 ? (
            <ResponsiveContainer width="100%" height={280}>
              <PieChart>
                <Pie
                  data={membershipDist}
                  dataKey="count"
                  nameKey="name"
                  cx="50%"
                  cy="50%"
                  outerRadius={90}
                  label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`}
                >
                  {membershipDist.map((_, i) => (
                    <Cell key={i} fill={COLORS[i % COLORS.length]} />
                  ))}
                </Pie>
                <Legend />
                <Tooltip contentStyle={{ background: '#1E2A4A', border: '1px solid #2D3A5C', borderRadius: '12px' }} />
              </PieChart>
            </ResponsiveContainer>
          ) : (
            <div className="flex items-center justify-center h-[280px] text-dark-400">No members yet</div>
          )}
        </div>
      </div>

      {/* Bottom Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Recent Payments */}
        <div className="card">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg font-semibold text-white">Recent Payments</h2>
            <button onClick={() => navigate('/payments')} className="text-sm text-primary-500 hover:underline">View all</button>
          </div>
          {recentPayments.length > 0 ? (
            <div className="space-y-3">
              {recentPayments.slice(0, 5).map((p, i) => (
                <div key={i} className="flex items-center justify-between py-2 border-b border-dark-700 last:border-0">
                  <div>
                    <p className="text-sm font-medium text-white">{p.profile?.full_name || 'Member'}</p>
                    <p className="text-xs text-dark-400">{p.plan?.name || 'N/A'} • {new Date(p.payment_date).toLocaleDateString()}</p>
                  </div>
                  <span className="text-sm font-semibold text-green-500">₹{p.amount?.toLocaleString()}</span>
                </div>
              ))}
            </div>
          ) : (
            <p className="text-dark-400 text-sm">No payments yet</p>
          )}
        </div>

        {/* Expiring Memberships */}
        <div className="card">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg font-semibold text-white">Expiring Soon</h2>
            <button onClick={() => navigate('/members')} className="text-sm text-primary-500 hover:underline">View all</button>
          </div>
          {expiring.length > 0 ? (
            <div className="space-y-3">
              {expiring.slice(0, 5).map((m, i) => (
                <div key={i} className="flex items-center justify-between py-2 border-b border-dark-700 last:border-0">
                  <div className="flex items-center gap-3">
                    <AlertTriangle size={16} className="text-yellow-500" />
                    <div>
                      <p className="text-sm font-medium text-white">{m.profile?.full_name || 'Member'}</p>
                      <p className="text-xs text-dark-400">Expires: {m.end_date}</p>
                    </div>
                  </div>
                  <span className="text-xs text-yellow-500 bg-yellow-500/10 px-2 py-1 rounded-lg">Expiring</span>
                </div>
              ))}
            </div>
          ) : (
            <p className="text-dark-400 text-sm">No members expiring soon</p>
          )}
        </div>
      </div>
    </div>
  );
}
