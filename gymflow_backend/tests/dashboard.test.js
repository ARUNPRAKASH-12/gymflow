import './setup.js';
import request from 'supertest';
import app from '../src/app.js';

const u = (n) => `00000000-0000-0000-0000-${String(n).padStart(12, '0')}`;
const adminAuth = { Authorization: 'Bearer admin-token' };
const trainerAuth = { Authorization: 'Bearer trainer-token' };
const memberAuth = { Authorization: 'Bearer member-token' };
const gymQuery = `gym_id=${u(10)}`;

describe('GET /api/dashboard/admin', () => {
  it('returns admin dashboard stats', async () => {
    const res = await request(app)
      .get(`/api/dashboard/admin?${gymQuery}`)
      .set(adminAuth);
    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('stats');
    expect(res.body).toHaveProperty('revenue_chart');
  });

  it('includes revenue chart data', async () => {
    const res = await request(app)
      .get(`/api/dashboard/admin?${gymQuery}`)
      .set(adminAuth);
    expect(res.status).toBe(200);
    expect(res.body.revenue_chart).toBeDefined();
    expect(Array.isArray(res.body.revenue_chart)).toBe(true);
  });

  it('includes recent payments', async () => {
    const res = await request(app)
      .get(`/api/dashboard/admin?${gymQuery}`)
      .set(adminAuth);
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body.recent_payments)).toBe(true);
  });

  it('includes expiring memberships', async () => {
    const res = await request(app)
      .get(`/api/dashboard/admin?${gymQuery}`)
      .set(adminAuth);
    expect(res.status).toBe(200);
    expect(res.body.expiring_memberships).toBeDefined();
  });
});

describe('GET /api/dashboard/trainer', () => {
  it('returns trainer dashboard stats', async () => {
    const res = await request(app)
      .get(`/api/dashboard/trainer?${gymQuery}`)
      .set(trainerAuth);
    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('assigned_members');
    expect(Array.isArray(res.body.assigned_members)).toBe(true);
  });
});

describe('GET /api/dashboard/member', () => {
  it('returns member dashboard stats', async () => {
    const res = await request(app)
      .get(`/api/dashboard/member?${gymQuery}`)
      .set(memberAuth);
    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('member');
  });
});

describe('Access Control', () => {
  it('denies admin dashboard for members with 403', async () => {
    const res = await request(app)
      .get(`/api/dashboard/admin?${gymQuery}`)
      .set(memberAuth);
    expect(res.status).toBe(403);
  });

  it('denies admin dashboard for trainers with 403', async () => {
    const res = await request(app)
      .get(`/api/dashboard/admin?${gymQuery}`)
      .set(trainerAuth);
    expect(res.status).toBe(403);
  });

  it('requires authentication for all dashboard routes', async () => {
    const res = await request(app)
      .get(`/api/dashboard/admin?${gymQuery}`);
    expect(res.status).toBe(401);
  });
});
