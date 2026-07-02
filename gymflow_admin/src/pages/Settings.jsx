import React, { useState, useEffect } from 'react';
import { Save } from 'lucide-react';
import api from '../services/api';

export default function Settings() {
  const [settings, setSettings] = useState({
    gym_name: 'ROCKFORT PLANET GYM FITNESS',
    address: 'P-60, J K Nagar, K K Nagar',
    city: 'Tiruchirappalli',
    state: 'Tamil Nadu',
    pincode: '620007',
    phone: '+91 98651 50164',
    email: 'rockfortplanet@gmail.com',
  });
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);

  useEffect(() => { loadSettings(); }, []);

  async function loadSettings() {
    try {
      const data = await api.getSettings();
      if (data) setSettings({ ...settings, ...data });
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  }

  const handleSave = async () => {
    setSaving(true);
    try {
      await api.updateSettings(settings);
      alert('Settings saved!');
    } catch (err) {
      alert('Failed to save settings');
    } finally {
      setSaving(false);
    }
  };

  if (loading) return <div className="flex items-center justify-center h-64"><div className="w-8 h-8 border-2 border-primary-500 border-t-transparent rounded-full animate-spin" /></div>;

  return (
    <div className="max-w-2xl space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-white">Settings</h1>
          <p className="text-dark-400 mt-1">Manage your gym profile</p>
        </div>
        <button onClick={handleSave} disabled={saving} className="btn-primary flex items-center gap-2">
          <Save size={18} /> {saving ? 'Saving...' : 'Save'}
        </button>
      </div>

      <div className="card space-y-5">
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div className="sm:col-span-2">
            <label className="block text-sm font-medium text-dark-300 mb-1">Gym Name</label>
            <input type="text" value={settings.gym_name} onChange={(e) => setSettings({ ...settings, gym_name: e.target.value })} className="input-field" />
          </div>
          <div className="sm:col-span-2">
            <label className="block text-sm font-medium text-dark-300 mb-1">Address</label>
            <input type="text" value={settings.address} onChange={(e) => setSettings({ ...settings, address: e.target.value })} className="input-field" />
          </div>
          <div>
            <label className="block text-sm font-medium text-dark-300 mb-1">City</label>
            <input type="text" value={settings.city} onChange={(e) => setSettings({ ...settings, city: e.target.value })} className="input-field" />
          </div>
          <div>
            <label className="block text-sm font-medium text-dark-300 mb-1">State</label>
            <input type="text" value={settings.state} onChange={(e) => setSettings({ ...settings, state: e.target.value })} className="input-field" />
          </div>
          <div>
            <label className="block text-sm font-medium text-dark-300 mb-1">Pincode</label>
            <input type="text" value={settings.pincode} onChange={(e) => setSettings({ ...settings, pincode: e.target.value })} className="input-field" />
          </div>
          <div>
            <label className="block text-sm font-medium text-dark-300 mb-1">Phone</label>
            <input type="text" value={settings.phone} onChange={(e) => setSettings({ ...settings, phone: e.target.value })} className="input-field" />
          </div>
          <div className="sm:col-span-2">
            <label className="block text-sm font-medium text-dark-300 mb-1">Email</label>
            <input type="email" value={settings.email} onChange={(e) => setSettings({ ...settings, email: e.target.value })} className="input-field" />
          </div>
        </div>
      </div>

      <div className="card">
        <h2 className="text-lg font-semibold text-white mb-4">GymFlow Platform</h2>
        <p className="text-sm text-dark-400">Version 1.0.0</p>
        <p className="text-sm text-dark-400 mt-1">Multi-gym management platform for ROCKFORT PLANET GYM FITNESS</p>
      </div>
    </div>
  );
}
