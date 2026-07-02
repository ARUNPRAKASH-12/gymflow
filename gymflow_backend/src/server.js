import dotenv from 'dotenv';
import app from './app.js';

dotenv.config();

const PORT = process.env.PORT || 3000;
const NODE_ENV = process.env.NODE_ENV || 'development';

app.listen(PORT, () => {
  console.log(`GymFlow API running on port ${PORT} [${NODE_ENV}]`);
  console.log(`Health check: http://localhost:${PORT}/api/health`);
});
