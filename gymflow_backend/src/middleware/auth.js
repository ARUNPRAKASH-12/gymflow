import { supabase } from '../config/supabase.js';

export async function authenticate(req, res, next) {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'Missing or invalid authorization header' });
    }

    const token = authHeader.split(' ')[1];
    const { data: { user }, error } = await supabase.auth.getUser(token);

    if (error || !user) {
      return res.status(401).json({ error: 'Invalid or expired token' });
    }

    const { data: dbUser, error: dbError } = await supabase
      .from('users')
      .select('*')
      .eq('id', user.id)
      .single();

    if (dbError || !dbUser) {
      return res.status(401).json({ error: 'User not found in database' });
    }

    if (!dbUser.is_active) {
      return res.status(403).json({ error: 'Account deactivated' });
    }

    req.user = dbUser;
    req.token = token;
    next();
  } catch (err) {
    console.error('Auth middleware error:', err);
    return res.status(500).json({ error: 'Internal authentication error' });
  }
}

export function requireRole(...roles) {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ error: 'Authentication required' });
    }
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({
        error: 'Forbidden',
        message: `Required role: ${roles.join(' or ')}`,
      });
    }
    next();
  };
}

export function requireGymAccess(req, res, next) {
  const gymId = req.params.gymId || req.body.gym_id || req.query.gym_id;
  if (!gymId) {
    return res.status(400).json({ error: 'Gym ID is required' });
  }
  req.gymId = gymId;
  next();
}
