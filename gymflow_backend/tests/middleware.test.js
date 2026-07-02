import './setup.js';
import request from 'supertest';
import app from '../src/app.js';

describe('Auth Middleware (authenticate)', () => {
  it('rejects requests without Authorization header', async () => {
    const res = await request(app).get('/api/users/me');
    expect(res.status).toBe(401);
    expect(res.body).toHaveProperty('error');
  });

  it('rejects requests with malformed token', async () => {
    const res = await request(app)
      .get('/api/users/me')
      .set('Authorization', 'Bearer invalid-token');
    expect(res.status).toBe(401);
  });

  it('rejects requests with empty token', async () => {
    const res = await request(app)
      .get('/api/users/me')
      .set('Authorization', 'Bearer ');
    expect(res.status).toBe(401);
  });
});

describe('Role-Based Access (requireRole)', () => {
  it('rejects member accessing admin routes with 403', async () => {
    const res = await request(app)
      .get('/api/dashboard/admin')
      .set('Authorization', 'Bearer member-token');
    expect(res.status).toBe(403);
  });

  it('rejects unauthenticated access to admin routes', async () => {
    const res = await request(app).get('/api/dashboard/admin');
    expect(res.status).toBe(401);
  });
});

describe('Gym Access (requireGymAccess)', () => {
  it('rejects requests without gym context', async () => {
    const res = await request(app)
      .get('/api/members')
      .set('Authorization', 'Bearer test-token-no-gym');
    expect(res.status).toBe(401);
  });
});

describe('CORS Preflight', () => {
  it('allows cross-origin requests', async () => {
    const res = await request(app)
      .options('/api/auth/login')
      .set('Origin', 'https://admin.gymflow.com')
      .set('Access-Control-Request-Method', 'POST');
    expect(res.status).toBe(204);
    expect(res.headers['access-control-allow-origin']).toBeTruthy();
  });
});
