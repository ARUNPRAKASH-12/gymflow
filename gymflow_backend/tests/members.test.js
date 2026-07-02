import './setup.js';
import request from 'supertest';
import app from '../src/app.js';

const u = (n) => `00000000-0000-0000-0000-${String(n).padStart(12, '0')}`;
const authHeader = { Authorization: 'Bearer admin-token' };

describe('GET /api/members', () => {
  it('returns list of members for admin', async () => {
    const res = await request(app)
      .get('/api/members')
      .set(authHeader);
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body.members)).toBe(true);
  });

  it('supports pagination with page and limit', async () => {
    const res = await request(app)
      .get('/api/members?page=2&limit=5')
      .set(authHeader);
    expect(res.status).toBe(200);
    expect(res.body.members).toBeDefined();
    expect(Array.isArray(res.body.members)).toBe(true);
  });

  it('supports status filter', async () => {
    const res = await request(app)
      .get('/api/members?status=active')
      .set(authHeader);
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body.members)).toBe(true);
  });
});

describe('GET /api/members/:id', () => {
  it('returns member detail for valid id', async () => {
    const res = await request(app)
      .get(`/api/members/${u(20)}`)
      .set(authHeader);
    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('id');
  });

  it('returns 404 for non-existent member', async () => {
    const res = await request(app)
      .get(`/api/members/${u(999)}`)
      .set(authHeader);
    expect(res.status).toBe(404);
  });
});

describe('POST /api/members', () => {
  it('creates a new member with valid data', async () => {
    const res = await request(app)
      .post('/api/members')
      .set(authHeader)
      .send({
        email: 'newmember@example.com',
        full_name: 'New Member',
        gym_id: u(10),
        membership_plan_id: u(30),
      });
    expect(res.status).toBe(201);
    expect(res.body).toHaveProperty('id');
  });

  it('rejects member creation without email', async () => {
    const res = await request(app)
      .post('/api/members')
      .set(authHeader)
      .send({ full_name: 'Test', gym_id: u(10) });
    expect(res.status).toBe(400);
    expect(res.body).toHaveProperty('error');
  });

  it('rejects member creation with invalid email', async () => {
    const res = await request(app)
      .post('/api/members')
      .set(authHeader)
      .send({ email: 'not-email', full_name: 'Test', gym_id: u(10) });
    expect(res.status).toBe(400);
  });
});
