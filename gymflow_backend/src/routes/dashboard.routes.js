import { Router } from 'express';
import { authenticate, requireRole } from '../middleware/auth.js';
import { adminDashboard, trainerDashboard, memberDashboard } from '../controllers/dashboard.controller.js';

const router = Router();

router.get('/admin', authenticate, requireRole('admin', 'superadmin'), adminDashboard);
router.get('/trainer', authenticate, requireRole('trainer'), trainerDashboard);
router.get('/member', authenticate, requireRole('member'), memberDashboard);

export default router;
