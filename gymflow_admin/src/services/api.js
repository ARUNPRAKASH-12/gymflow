import axios from 'axios';

const API_BASE = import.meta.env.VITE_API_URL || '/api';

const apiClient = axios.create({
  baseURL: API_BASE,
  headers: { 'Content-Type': 'application/json' },
});

apiClient.interceptors.request.use((config) => {
  const token = localStorage.getItem('gymflow_token');
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

apiClient.interceptors.response.use(
  (res) => res,
  (err) => {
    if (err.response?.status === 401) {
      localStorage.removeItem('gymflow_token');
      window.location.href = '/login';
    }
    return Promise.reject(err);
  }
);

const api = {
  // Auth
  login: (email, password) =>
    apiClient.post('/auth/login', { email, password }).then((r) => r.data),
  forgotPassword: (email) =>
    apiClient.post('/auth/forgot-password', { email }).then((r) => r.data),
  getProfile: () =>
    apiClient.get('/users/me').then((r) => r.data),

  // Dashboard
  getAdminDashboard: (gymId) =>
    apiClient.get('/dashboard/admin', { params: { gym_id: gymId } }).then((r) => r.data),
  getTrainerDashboard: (gymId) =>
    apiClient.get('/dashboard/trainer', { params: { gym_id: gymId } }).then((r) => r.data),

  // Members
  getMembers: (params) =>
    apiClient.get('/members', { params }).then((r) => r.data),
  getMember: (id) =>
    apiClient.get(`/members/${id}`).then((r) => r.data),
  createMember: (data) =>
    apiClient.post('/members', data).then((r) => r.data),
  updateMember: (id, data) =>
    apiClient.put(`/members/${id}`, data).then((r) => r.data),
  deleteMember: (id) =>
    apiClient.delete(`/members/${id}`).then((r) => r.data),
  renewMembership: (id, data) =>
    apiClient.post(`/members/${id}/renew`, data).then((r) => r.data),

  // Trainers
  getTrainers: (params) =>
    apiClient.get('/trainers', { params }).then((r) => r.data),
  getTrainer: (id) =>
    apiClient.get(`/trainers/${id}`).then((r) => r.data),
  createTrainer: (data) =>
    apiClient.post('/trainers', data).then((r) => r.data),
  updateTrainer: (id, data) =>
    apiClient.put(`/trainers/${id}`, data).then((r) => r.data),
  deleteTrainer: (id) =>
    apiClient.delete(`/trainers/${id}`).then((r) => r.data),
  getTrainerMembers: (id) =>
    apiClient.get(`/trainers/${id}/members`).then((r) => r.data),

  // Plans
  getPlans: (params) =>
    apiClient.get('/membership-plans', { params }).then((r) => r.data),
  createPlan: (data) =>
    apiClient.post('/membership-plans', data).then((r) => r.data),
  updatePlan: (id, data) =>
    apiClient.put(`/membership-plans/${id}`, data).then((r) => r.data),
  deletePlan: (id) =>
    apiClient.delete(`/membership-plans/${id}`).then((r) => r.data),

  // Attendance
  getAttendance: (params) =>
    apiClient.get('/attendance', { params }).then((r) => r.data),
  getTodayAttendance: (params) =>
    apiClient.get('/attendance/today', { params }).then((r) => r.data),
  checkIn: (data) =>
    apiClient.post('/attendance/check-in', data).then((r) => r.data),
  checkOut: (id) =>
    apiClient.put(`/attendance/${id}/check-out`).then((r) => r.data),
  getAttendanceQR: (params) =>
    apiClient.get('/attendance/qr', { params }).then((r) => r.data),

  // Payments
  getPayments: (params) =>
    apiClient.get('/payments', { params }).then((r) => r.data),
  createPayment: (data) =>
    apiClient.post('/payments', data).then((r) => r.data),
  getPaymentReport: (params) =>
    apiClient.get('/payments/report', { params }).then((r) => r.data),

  // Workouts
  getWorkouts: (params) =>
    apiClient.get('/workouts', { params }).then((r) => r.data),
  createWorkout: (data) =>
    apiClient.post('/workouts', data).then((r) => r.data),
  getExercises: (params) =>
    apiClient.get('/workouts/exercises/list', { params }).then((r) => r.data),
  createExercise: (data) =>
    apiClient.post('/workouts/exercises', data).then((r) => r.data),

  // Diets
  getDiets: (params) =>
    apiClient.get('/diet-plans', { params }).then((r) => r.data),
  createDiet: (data) =>
    apiClient.post('/diet-plans', data).then((r) => r.data),

  // Notifications
  getNotifications: (params) =>
    apiClient.get('/notifications', { params }).then((r) => r.data),
  sendNotification: (data) =>
    apiClient.post('/notifications', data).then((r) => r.data),
  sendBulkNotification: (data) =>
    apiClient.post('/notifications/bulk', data).then((r) => r.data),
  markNotificationRead: (id) =>
    apiClient.put(`/notifications/${id}/read`).then((r) => r.data),

  // Reports
  getRevenueReport: (params) =>
    apiClient.get('/reports/revenue', { params }).then((r) => r.data),
  getAttendanceReport: (params) =>
    apiClient.get('/reports/attendance', { params }).then((r) => r.data),
  getMembershipReport: (params) =>
    apiClient.get('/reports/membership', { params }).then((r) => r.data),
  getMemberGrowth: (params) =>
    apiClient.get('/reports/member-growth', { params }).then((r) => r.data),
  getTrainerPerformance: (params) =>
    apiClient.get('/reports/trainer-performance', { params }).then((r) => r.data),

  // Settings
  getSettings: (params) =>
    apiClient.get('/settings', { params }).then((r) => r.data),
  updateSettings: (data) =>
    apiClient.put('/settings', data).then((r) => r.data),

  // Export
  exportReport: async (type, format) => {
    const response = await apiClient.get(`/reports/export/${type}`, {
      params: { format },
      responseType: format === 'xlsx' ? 'blob' : 'json',
    });
    if (format === 'xlsx') {
      const url = window.URL.createObjectURL(new Blob([response.data]));
      const a = document.createElement('a');
      a.href = url;
      a.download = `${type}_report.xlsx`;
      a.click();
      window.URL.revokeObjectURL(url);
      return { success: true };
    }
    return response.data;
  },

  // Invoice
  downloadInvoice: async (id) => {
    const response = await apiClient.get(`/payments/${id}/invoice/download`, {
      responseType: 'blob',
    });
    const url = window.URL.createObjectURL(new Blob([response.data], { type: 'application/pdf' }));
    const a = document.createElement('a');
    a.href = url;
    a.download = `invoice-${id.substring(0, 8)}.pdf`;
    a.click();
    window.URL.revokeObjectURL(url);
    return { success: true };
  },

  // Gyms
  getGyms: () => apiClient.get('/gyms').then((r) => r.data),
  selectGym: (id) => apiClient.post(`/gyms/${id}/select`).then((r) => r.data),
};

export default api;
