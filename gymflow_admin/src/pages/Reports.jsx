import React, { useState, useEffect } from 'react';
import {
  BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer,
  LineChart, Line, AreaChart, Area, PieChart, Pie, Cell, Legend,
} from 'recharts';
import { Download } from 'lucide-react';
import api from '../services/api';

const COLORS = ['#FF6B35', '#2563EB', '#22C55E', '#F59E0B', '#EF4444', '#8B5CF6'];

export default function Reports() {
  const [activeTab, setActiveTab] = useState('revenue');
  const [revenueData, setRevenueData] = useState(null);
  const [attendanceData, setAttendanceData] = useState(null);
  const [membershipData, setMembershipData] = useState(null);
  const [growthData, setGrowthData] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => { loadAll(); }, []);

  async function loadAll() {
    setLoading(true);
    try {
      const [rev, att, mem, grow] = await Promise.all([
        api.getRevenueReport().catch(() => null),
        api.getAttendanceReport().catch(() => null),
        api.getMembershipReport().catch(() => null),
        api.getMemberGrowth().catch(() => null),
      ]);
      setRevenueData(rev);
      setAttendanceData(att);
      setMembershipData(mem);
      setGrowthData(grow);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  }

  const tabs = [
    { key: 'revenue', label: 'Revenue' },
    { key: 'attendance', label: 'Attendance' },
    { key: 'membership', label: 'Membership' },
    { key: 'growth', label: 'Member Growth' },
  ];

  function TooltipContent({ active, payload, label }) {
    if (active && payload?.length) {
      return (
        <div className="bg-dark-800 border border-dark-700 rounded-xl px-4 py-3 shadow-xl">
          <p className="text-sm text-dark-400">{label}</p>
          {payload.map((p, i) => (
            <p key={i} className="text-sm font-medium" style={{ color: p.color }}>{p.name}: {p.value?.toLocaleString()}</p>
          ))}
        </div>
      );
    }
    return null;
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-white">Reports & Analytics</h1>
          <p className="text-dark-400 mt-1">Data-driven insights for your gym</p>
        </div>
        <div className="flex gap-2">
          <button onClick={() => api.exportReport(activeTab, 'xlsx')} className="btn-outline flex items-center gap-2"><Download size={16} /> Export Excel</button>
          <button onClick={() => api.exportReport(activeTab, 'json')} className="btn-outline flex items-center gap-2"><Download size={16} /> Export JSON</button>
        </div>
      </div>

      {/* Tabs */}
      <div className="flex gap-2 border-b border-dark-700 pb-2">
        {tabs.map((tab) => (
          <button
            key={tab.key}
            onClick={() => setActiveTab(tab.key)}
            className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
              activeTab === tab.key ? 'bg-primary-500/10 text-primary-500' : 'text-dark-400 hover:text-white'
            }`}
          >
            {tab.label}
          </button>
        ))}
      </div>

      {loading ? (
        <div className="flex items-center justify-center h-64"><div className="w-8 h-8 border-2 border-primary-500 border-t-transparent rounded-full animate-spin" /></div>
      ) : (
        <>
          {/* Revenue Tab */}
          {activeTab === 'revenue' && (
            <div className="space-y-6">
              <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
                <div className="card"><p className="text-3xl font-bold text-primary-500">₹{(revenueData?.total_revenue || 0).toLocaleString()}</p><p className="text-sm text-dark-400 mt-1">Total Revenue</p></div>
                <div className="card"><p className="text-3xl font-bold text-white">{revenueData?.transaction_count || 0}</p><p className="text-sm text-dark-400 mt-1">Transactions</p></div>
                <div className="card"><p className="text-3xl font-bold text-green-500">{revenueData?.plan_breakdown?.length || 0}</p><p className="text-sm text-dark-400 mt-1">Active Plans</p></div>
              </div>
              <div className="card">
                <h2 className="text-lg font-semibold text-white mb-4">Monthly Revenue</h2>
                <ResponsiveContainer width="100%" height={300}>
                  <BarChart data={revenueData?.monthly_breakdown || []}>
                    <XAxis dataKey="month" tick={{ fill: '#64748b', fontSize: 12 }} />
                    <YAxis tick={{ fill: '#64748b', fontSize: 12 }} />
                    <Tooltip content={<TooltipContent />} />
                    <Bar dataKey="revenue" fill="#FF6B35" radius={[4, 4, 0, 0]} name="Revenue" />
                  </BarChart>
                </ResponsiveContainer>
              </div>
              <div className="card">
                <h2 className="text-lg font-semibold text-white mb-4">Revenue by Plan</h2>
                <ResponsiveContainer width="100%" height={250}>
                  <PieChart>
                    <Pie data={revenueData?.plan_breakdown || []} dataKey="revenue" nameKey="plan" cx="50%" cy="50%" outerRadius={80} label={({ plan }) => plan}>
                      {(revenueData?.plan_breakdown || []).map((_, i) => <Cell key={i} fill={COLORS[i % COLORS.length]} />)}
                    </Pie>
                    <Legend />
                    <Tooltip content={<TooltipContent />} />
                  </PieChart>
                </ResponsiveContainer>
              </div>
            </div>
          )}

          {/* Attendance Tab */}
          {activeTab === 'attendance' && (
            <div className="space-y-6">
              <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
                <div className="card"><p className="text-3xl font-bold text-white">{attendanceData?.total_records || 0}</p><p className="text-sm text-dark-400 mt-1">Total Check-ins</p></div>
                <div className="card"><p className="text-3xl font-bold text-secondary-500">{attendanceData?.unique_members || 0}</p><p className="text-sm text-dark-400 mt-1">Unique Members</p></div>
                <div className="card"><p className="text-3xl font-bold text-primary-500">{attendanceData?.avg_duration_minutes || 0} min</p><p className="text-sm text-dark-400 mt-1">Avg Duration</p></div>
              </div>
              <div className="card">
                <h2 className="text-lg font-semibold text-white mb-4">Daily Attendance</h2>
                <ResponsiveContainer width="100%" height={300}>
                  <AreaChart data={attendanceData?.daily_breakdown || []}>
                    <XAxis dataKey="date" tick={{ fill: '#64748b', fontSize: 12 }} />
                    <YAxis tick={{ fill: '#64748b', fontSize: 12 }} />
                    <Tooltip content={<TooltipContent />} />
                    <Area type="monotone" dataKey="count" stroke="#2563EB" fill="#2563EB20" name="Check-ins" />
                  </AreaChart>
                </ResponsiveContainer>
              </div>
            </div>
          )}

          {/* Membership Tab */}
          {activeTab === 'membership' && (
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
              <div className="card">
                <h2 className="text-lg font-semibold text-white mb-4">By Status</h2>
                <div className="space-y-4">
                  {membershipData?.by_status && Object.entries(membershipData.by_status).map(([status, count]) => (
                    <div key={status} className="flex items-center justify-between">
                      <span className="text-sm capitalize text-dark-300">{status}</span>
                      <div className="flex items-center gap-3">
                        <div className="w-32 h-2 bg-dark-700 rounded-full overflow-hidden">
                          <div className={`h-full rounded-full ${
                            status === 'active' ? 'bg-green-500' :
                            status === 'expired' ? 'bg-red-500' : 'bg-yellow-500'
                          }`} style={{ width: `${membershipData.total ? (count / membershipData.total * 100) : 0}%` }} />
                        </div>
                        <span className="text-sm font-medium text-white">{count}</span>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
              <div className="card">
                <h2 className="text-lg font-semibold text-white mb-4">By Plan</h2>
                <ResponsiveContainer width="100%" height={250}>
                  <PieChart>
                    <Pie data={membershipData?.by_plan || []} dataKey="count" nameKey="plan" cx="50%" cy="50%" outerRadius={80} label={({ plan }) => plan}>
                      {(membershipData?.by_plan || []).map((_, i) => <Cell key={i} fill={COLORS[i % COLORS.length]} />)}
                    </Pie>
                    <Legend />
                    <Tooltip content={<TooltipContent />} />
                  </PieChart>
                </ResponsiveContainer>
              </div>
            </div>
          )}

          {/* Growth Tab */}
          {activeTab === 'growth' && (
            <div className="card">
              <h2 className="text-lg font-semibold text-white mb-4">Member Growth</h2>
              <ResponsiveContainer width="100%" height={350}>
                <LineChart data={growthData?.monthly_growth || []}>
                  <XAxis dataKey="month" tick={{ fill: '#64748b', fontSize: 12 }} />
                  <YAxis tick={{ fill: '#64748b', fontSize: 12 }} />
                  <Tooltip content={<TooltipContent />} />
                  <Line type="monotone" dataKey="joined" stroke="#22C55E" strokeWidth={2} name="New Members" dot={{ fill: '#22C55E' }} />
                  <Line type="monotone" dataKey="active" stroke="#2563EB" strokeWidth={2} name="Active Members" dot={{ fill: '#2563EB' }} />
                </LineChart>
              </ResponsiveContainer>
            </div>
          )}
        </>
      )}
    </div>
  );
}
