export default {
  testEnvironment: 'node',
  roots: ['<rootDir>/tests'],
  testMatch: ['**/*.test.js'],
  transform: {
    '^.+\\.js$': 'babel-jest',
  },
  transformIgnorePatterns: [
    'node_modules/(?!(supertest|methods)/)',
  ],
  moduleNameMapper: {
    '^@supabase/supabase-js$': '<rootDir>/tests/__mocks__/supabase.js',
    '^razorpay$': '<rootDir>/tests/__mocks__/razorpay.js',
  },
  setupFiles: ['<rootDir>/tests/setup.js'],
  verbose: true,
  forceExit: true,
  detectOpenHandles: true,
  testTimeout: 10000,
};
