import React, { useState, useEffect } from 'react';
import { Plus, Search } from 'lucide-react';
import api from '../services/api';
import Modal from '../components/Modal';

export default function Workouts() {
  const [workouts, setWorkouts] = useState([]);
  const [exercises, setExercises] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showAdd, setShowAdd] = useState(false);
  const [showAddExercise, setShowAddExercise] = useState(false);
  const [search, setSearch] = useState('');
  const [form, setForm] = useState({ member_id: '', name: '', description: '', day_of_week: '', exercises: [] });
  const [exerciseForm, setExerciseForm] = useState({ name: '', category: 'chest', description: '', sets_reps: '' });
  const [members, setMembers] = useState([]);

  const days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];

  useEffect(() => { loadData(); }, []);

  async function loadData() {
    try {
      const [wData, eData, mData] = await Promise.all([
        api.getWorkouts(),
        api.getExercises(),
        api.getMembers(),
      ]);
      setWorkouts(Array.isArray(wData) ? wData : []);
      setExercises(Array.isArray(eData) ? eData : []);
      setMembers(mData.members || mData || []);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  }

  const handleCreateWorkout = async (e) => {
    e.preventDefault();
    try {
      await api.createWorkout(form);
      setShowAdd(false);
      setForm({ member_id: '', name: '', description: '', day_of_week: '', exercises: [] });
      loadData();
    } catch (err) {
      alert(err.response?.data?.error || 'Failed');
    }
  };

  const handleCreateExercise = async (e) => {
    e.preventDefault();
    try {
      await api.createExercise({
        ...exerciseForm,
        sets_reps: exerciseForm.sets_reps ? JSON.parse(exerciseForm.sets_reps) : [],
      });
      setShowAddExercise(false);
      setExerciseForm({ name: '', category: 'chest', description: '', sets_reps: '' });
      loadData();
    } catch (err) {
      alert(err.response?.data?.error || 'Failed');
    }
  };

  const categories = ['chest', 'back', 'legs', 'shoulder', 'biceps', 'triceps', 'cardio', 'abs'];

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-white">Workouts</h1>
          <p className="text-dark-400 mt-1">{workouts.length} workouts</p>
        </div>
        <div className="flex gap-3">
          <button onClick={() => setShowAddExercise(true)} className="btn-outline flex items-center gap-2">
            <Plus size={18} /> Exercise
          </button>
          <button onClick={() => setShowAdd(true)} className="btn-primary flex items-center gap-2">
            <Plus size={18} /> Workout
          </button>
        </div>
      </div>

      {loading ? (
        <div className="flex items-center justify-center h-64"><div className="w-8 h-8 border-2 border-primary-500 border-t-transparent rounded-full animate-spin" /></div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {workouts.length === 0 ? (
            <div className="col-span-full text-center py-12 text-dark-400">No workouts yet</div>
          ) : (
            workouts.map((w) => (
              <div key={w.id} className="card">
                <div className="flex items-start justify-between mb-3">
                  <div>
                    <h3 className="font-semibold text-white">{w.name}</h3>
                    <p className="text-xs text-dark-400 mt-1">
                      {w.day_of_week || w.schedule_date || 'Custom'} • {w.exercises?.length || 0} exercises
                    </p>
                  </div>
                  <span className={`px-2 py-1 rounded-lg text-xs font-medium ${w.is_completed ? 'bg-green-500/10 text-green-500' : 'bg-yellow-500/10 text-yellow-500'}`}>
                    {w.is_completed ? 'DONE' : 'PENDING'}
                  </span>
                </div>
                {w.member_profile?.full_name && (
                  <p className="text-xs text-dark-400">For: {w.member_profile.full_name}</p>
                )}
              </div>
            ))
          )}
        </div>
      )}

      <Modal open={showAdd} onClose={() => setShowAdd(false)} title="Create Workout">
        <form onSubmit={handleCreateWorkout} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-dark-300 mb-1">Workout Name</label>
            <input type="text" value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })} className="input-field" required />
          </div>
          <div>
            <label className="block text-sm font-medium text-dark-300 mb-1">Member</label>
            <select value={form.member_id} onChange={(e) => setForm({ ...form, member_id: e.target.value })} className="input-field" required>
              <option value="">Select member</option>
              {members.map((m) => (
                <option key={m.user_id || m.id} value={m.user_id || m.id}>{m.profile?.full_name || m.email}</option>
              ))}
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-dark-300 mb-1">Day</label>
            <select value={form.day_of_week} onChange={(e) => setForm({ ...form, day_of_week: e.target.value })} className="input-field">
              <option value="">Select day</option>
              {days.map((d) => <option key={d} value={d}>{d.charAt(0).toUpperCase() + d.slice(1)}</option>)}
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-dark-300 mb-1">Description</label>
            <textarea value={form.description} onChange={(e) => setForm({ ...form, description: e.target.value })} className="input-field" rows={2} />
          </div>
          <div className="flex gap-3 justify-end pt-2">
            <button type="button" onClick={() => setShowAdd(false)} className="btn-outline">Cancel</button>
            <button type="submit" className="btn-primary">Create</button>
          </div>
        </form>
      </Modal>

      <Modal open={showAddExercise} onClose={() => setShowAddExercise(false)} title="Add Exercise">
        <form onSubmit={handleCreateExercise} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-dark-300 mb-1">Exercise Name</label>
            <input type="text" value={exerciseForm.name} onChange={(e) => setExerciseForm({ ...exerciseForm, name: e.target.value })} className="input-field" required />
          </div>
          <div>
            <label className="block text-sm font-medium text-dark-300 mb-1">Category</label>
            <select value={exerciseForm.category} onChange={(e) => setExerciseForm({ ...exerciseForm, category: e.target.value })} className="input-field">
              {categories.map((c) => <option key={c} value={c}>{c.charAt(0).toUpperCase() + c.slice(1)}</option>)}
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-dark-300 mb-1">Description</label>
            <textarea value={exerciseForm.description} onChange={(e) => setExerciseForm({ ...exerciseForm, description: e.target.value })} className="input-field" rows={2} />
          </div>
          <div className="flex gap-3 justify-end pt-2">
            <button type="button" onClick={() => setShowAddExercise(false)} className="btn-outline">Cancel</button>
            <button type="submit" className="btn-primary">Add Exercise</button>
          </div>
        </form>
      </Modal>
    </div>
  );
}
