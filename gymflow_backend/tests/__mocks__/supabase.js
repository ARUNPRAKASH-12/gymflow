class MockQueryBuilder {
  constructor(data = []) {
    this._data = data;
  }

  select() { return this; }
  insert(values) {
    this._inserted = values;
    return this;
  }
  update(values) {
    this._updated = values;
    return this;
  }
  delete() { return this; }

  eq(key, value) {
    this._data = this._data.filter(d => d[key] === value);
    return this;
  }
  neq() { return this; }
  gt() { return this; }
  gte() { return this; }
  lt() { return this; }
  lte() { return this; }
  in() { return this; }
  contains() { return this; }
  order() { return this; }
  range() { return this; }
  limit() { return this; }
  textSearch() { return this; }

  single() {
    const result = this._data[0] || null;
    return Promise.resolve({
      data: result,
      error: result ? null : { message: 'Not found', code: 'PGRST116' },
    });
  }

  maybeSingle() {
    return this.single();
  }

  then(resolve) {
    return Promise.resolve({ data: this._data, error: null }).then(resolve);
  }
}

function uuid(n) {
  return `00000000-0000-0000-0000-${String(n).padStart(12, '0')}`;
}

function getMockData(table) {
  const now = new Date().toISOString();
  const mockSets = {
    users: [
      { id: uuid(1), email: 'admin@example.com', role: 'admin', is_active: true, created_at: now },
      { id: uuid(2), email: 'member@example.com', role: 'member', is_active: true, created_at: now },
      { id: uuid(3), email: 'trainer@example.com', role: 'trainer', is_active: true, created_at: now },
    ],
    user_profiles: [
      { user_id: uuid(1), full_name: 'Admin User', phone: '9876543210' },
      { user_id: uuid(2), full_name: 'Test Member', phone: '9876543211' },
      { user_id: uuid(3), full_name: 'Trainer User', phone: '9876543212' },
    ],
    user_gyms: [
      { user_id: uuid(1), gym_id: uuid(10), role: 'admin' },
      { user_id: uuid(3), gym_id: uuid(10), role: 'trainer' },
    ],
    gyms: [
      { id: uuid(10), name: 'Test Gym', slug: 'test-gym', address: 'Test Address', phone: '+911234567890', is_active: true },
    ],
    user_gyms: [{ user_id: uuid(1), gym_id: uuid(10), role: 'admin' }],
    members: [
      { id: uuid(20), user_id: uuid(2), gym_id: uuid(10), membership_plan_id: uuid(30), status: 'active', start_date: '2026-01-01', end_date: '2026-02-01', join_date: '2026-01-01' },
    ],
    membership_plans: [
      { id: uuid(30), gym_id: uuid(10), name: 'Monthly', price: 999, duration_days: 30, is_active: true },
    ],
    trainers: [
      { id: uuid(40), user_id: uuid(3), gym_id: uuid(10), specialization: 'Strength Training', is_active: true },
    ],
    payments: [
      { id: uuid(50), user_id: uuid(2), gym_id: uuid(10), membership_plan_id: uuid(30), amount: 999, method: 'cash', status: 'completed', payment_date: now, invoice_number: 'INV-001' },
    ],
    attendance: [
      { id: uuid(60), user_id: uuid(2), gym_id: uuid(10), date: now.substring(0, 10), check_in: now, method: 'manual' },
    ],
    workouts: [{ id: uuid(70), user_id: uuid(2), gym_id: uuid(10), name: 'Full Body' }],
    notifications: [{ id: uuid(80), user_id: uuid(2), gym_id: uuid(10), title: 'Welcome', message: 'Welcome!', is_read: false }],
    diet_plans: [{ id: uuid(90), user_id: uuid(2), gym_id: uuid(10), name: 'Weight Loss' }],
    progress: [{ id: uuid(100), user_id: uuid(2), gym_id: uuid(10), weight: 75, date: now.substring(0, 10) }],
    exercises: [{ id: uuid(110), name: 'Bench Press', muscle_group: 'Chest', gym_id: uuid(10) }],
    settings: [{ id: uuid(120), gym_id: uuid(10), settings: { check_in_radius: 50 } }],
  };
  const data = mockSets[table] || [];
  return { data, single: data[0] || null };
}

export function createClient(url, key) {
  const client = {
    auth: {
      signUp: () => Promise.resolve({
        data: { user: { id: uuid(99), email: 'new@example.com' }, session: null },
        error: null,
      }),
      signInWithPassword: () => Promise.resolve({
        data: {
          user: { id: uuid(1), email: 'admin@example.com', role: 'admin' },
          session: { access_token: 'test-token', refresh_token: 'test-refresh' },
        },
        error: null,
      }),
      resetPasswordForEmail: () => Promise.resolve({ data: {}, error: null }),
      getUser: (token) => {
        if (!token || token === 'invalid-token') {
          return Promise.resolve({ data: { user: null }, error: { message: 'Invalid token' } });
        }
        if (token === 'test-token-no-gym') {
          return Promise.resolve({ data: { user: { id: uuid(99), email: 'nogym@example.com' } }, error: null });
        }
        const userMap = {
          'member-token': uuid(2),
          'trainer-token': uuid(3),
        };
        return Promise.resolve({
          data: { user: { id: userMap[token] || uuid(1), email: 'admin@example.com' } },
          error: null,
        });
      },
      admin: {
        createUser: () => Promise.resolve({
          data: { user: { id: uuid(99), email: 'new@example.com' } },
          error: null,
        }),
      },
    },
    from: (table) => new MockQueryBuilder(getMockData(table).data),
    rpc: () => Promise.resolve({ data: {}, error: null }),
    storage: {
      from: () => ({
        upload: () => Promise.resolve({ data: { path: 'test.jpg' }, error: null }),
        getPublicUrl: () => ({ data: { publicUrl: 'https://test.com/test.jpg' } }),
      }),
    },
  };
  return client;
}
