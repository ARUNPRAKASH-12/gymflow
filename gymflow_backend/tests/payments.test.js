import './setup.js';
import request from 'supertest';
import app from '../src/app.js';

const u = (n) => `00000000-0000-0000-0000-${String(n).padStart(12, '0')}`;
const authHeader = { Authorization: 'Bearer admin-token' };
const memberAuth = { Authorization: 'Bearer member-token' };

describe('GET /api/payments', () => {
  it('returns list of payments for admin', async () => {
    const res = await request(app)
      .get('/api/payments')
      .set(authHeader);
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('supports status filter', async () => {
    const res = await request(app)
      .get('/api/payments?status=completed')
      .set(authHeader);
    expect(res.status).toBe(200);
  });

  it('supports date range filter', async () => {
    const res = await request(app)
      .get('/api/payments?from=2026-01-01&to=2026-12-31')
      .set(authHeader);
    expect(res.status).toBe(200);
  });
});

describe('GET /api/payments/mine', () => {
  it('returns member own payments', async () => {
    const res = await request(app)
      .get('/api/payments/mine')
      .set(memberAuth);
    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('payments');
    expect(res.body).toHaveProperty('total_paid');
  });
});

describe('POST /api/payments', () => {
  it('creates a cash payment with valid data', async () => {
    const res = await request(app)
      .post('/api/payments')
      .set(authHeader)
      .send({
        user_id: u(2),
        gym_id: u(10),
        membership_plan_id: u(30),
        amount: 999,
        method: 'cash',
      });
    expect(res.status).toBe(201);
    expect(res.body).toHaveProperty('id');
    expect(res.body).toHaveProperty('invoice_number');
  });

  it('rejects payment without required amount', async () => {
    const res = await request(app)
      .post('/api/payments')
      .set(authHeader)
      .send({ user_id: u(2), gym_id: u(10), method: 'cash' });
    expect(res.status).toBe(400);
    expect(res.body).toHaveProperty('error');
  });

  it('rejects payment with invalid method', async () => {
    const res = await request(app)
      .post('/api/payments')
      .set(authHeader)
      .send({
        user_id: u(2),
        gym_id: u(10),
        amount: 999,
        method: 'bitcoin',
      });
    expect(res.status).toBe(400);
  });
});

describe('GET /api/payments/report', () => {
  it('returns payment report with revenue stats', async () => {
    const res = await request(app)
      .get('/api/payments/report')
      .set(authHeader);
    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('total_revenue');
    expect(res.body).toHaveProperty('total_transactions');
  });
});

describe('GET /api/payments/:id/invoice', () => {
  it('returns invoice data for a valid payment', async () => {
    const res = await request(app)
      .get(`/api/payments/${u(50)}/invoice`)
      .set(authHeader);
    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('id');
  });

  it('returns 404 for non-existent payment', async () => {
    const res = await request(app)
      .get(`/api/payments/${u(999)}/invoice`)
      .set(authHeader);
    expect(res.status).toBe(404);
  });
});
