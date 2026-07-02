import React, { useState, useEffect } from 'react';
import { CalendarCheck, QrCode, LogIn } from 'lucide-react';
import api from '../services/api';

export default function Attendance() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [qrData, setQrData] = useState(null);

  useEffect(() => { loadToday(); }, []);

  async function loadToday() {
    try {
      const result = await api.getTodayAttendance();
      setData(result);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  }

  const handleGenerateQR = async () => {
    try {
      const result = await api.getAttendanceQR();
      setQrData(result);
    } catch (err) {
      alert('Failed to generate QR');
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-white">Attendance</h1>
          <p className="text-dark-400 mt-1">Today's check-ins</p>
        </div>
        <button onClick={handleGenerateQR} className="btn-primary flex items-center gap-2">
          <QrCode size={18} /> Generate QR
        </button>
      </div>

      {qrData && (
        <div className="card flex items-center gap-6">
          <img src={qrData.qr_code} alt="QR Code" className="w-32 h-32 rounded-xl" />
          <div>
            <p className="text-sm font-medium text-white">Today's QR Code</p>
            <p className="text-xs text-dark-400 mt-1">Members can scan this at the entrance</p>
            <p className="text-xs text-dark-400">Date: {qrData.date}</p>
          </div>
        </div>
      )}

      {loading ? (
        <div className="flex items-center justify-center h-64"><div className="w-8 h-8 border-2 border-primary-500 border-t-transparent rounded-full animate-spin" /></div>
      ) : (
        <>
          <div className="grid grid-cols-3 gap-4">
            <div className="card text-center">
              <p className="text-3xl font-bold text-white">{data?.total || 0}</p>
              <p className="text-sm text-dark-400 mt-1">Total Today</p>
            </div>
            <div className="card text-center">
              <p className="text-3xl font-bold text-green-500">{data?.checked_in || 0}</p>
              <p className="text-sm text-dark-400 mt-1">Checked In</p>
            </div>
            <div className="card text-center">
              <p className="text-3xl font-bold text-yellow-500">{data?.checked_out || 0}</p>
              <p className="text-sm text-dark-400 mt-1">Checked Out</p>
            </div>
          </div>

          <div className="card overflow-hidden p-0">
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead>
                  <tr className="border-b border-dark-700">
                    <th className="text-left px-6 py-4 text-sm font-medium text-dark-400">Member</th>
                    <th className="text-left px-6 py-4 text-sm font-medium text-dark-400">Check In</th>
                    <th className="text-left px-6 py-4 text-sm font-medium text-dark-400">Check Out</th>
                    <th className="text-left px-6 py-4 text-sm font-medium text-dark-400">Method</th>
                    <th className="text-left px-6 py-4 text-sm font-medium text-dark-400">Status</th>
                  </tr>
                </thead>
                <tbody>
                  {(data?.records || []).length === 0 ? (
                    <tr><td colSpan="5" className="text-center py-12 text-dark-400">No attendance records today</td></tr>
                  ) : (
                    data?.records?.map((r, i) => (
                      <tr key={i} className="border-b border-dark-700 hover:bg-dark-800/50">
                        <td className="px-6 py-4">
                          <div className="flex items-center gap-3">
                            <div className="w-8 h-8 rounded-full bg-dark-700 flex items-center justify-center text-xs font-medium">
                              {r.profile?.full_name?.[0] || '?'}
                            </div>
                            <span className="text-sm text-white">{r.profile?.full_name || 'Unknown'}</span>
                          </div>
                        </td>
                        <td className="px-6 py-4 text-sm text-dark-400">{r.check_in?.substring(11, 19) || '-'}</td>
                        <td className="px-6 py-4 text-sm text-dark-400">{r.check_out?.substring(11, 19) || '-'}</td>
                        <td className="px-6 py-4 text-sm text-dark-400">{r.method?.toUpperCase()}</td>
                        <td className="px-6 py-4">
                          <span className={`px-2 py-1 rounded-lg text-xs font-medium ${r.check_out ? 'bg-green-500/10 text-green-500' : 'bg-yellow-500/10 text-yellow-500'}`}>
                            {r.check_out ? 'DONE' : 'ACTIVE'}
                          </span>
                        </td>
                      </tr>
                    ))
                  )}
                </tbody>
              </table>
            </div>
          </div>
        </>
      )}
    </div>
  );
}
