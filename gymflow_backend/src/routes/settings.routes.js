import { Router } from 'express';
import { authenticate, requireRole } from '../middleware/auth.js';
import { getSettings, updateSettings } from '../controllers/settings.controller.js';

const router = Router();

router.get('/', authenticate, getSettings);
router.put('/', authenticate, requireRole('admin', 'superadmin'), updateSettings);

export default router;
