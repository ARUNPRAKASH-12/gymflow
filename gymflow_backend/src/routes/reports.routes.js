import { Router } from 'express';
import { authenticate, requireRole } from '../middleware/auth.js';
import { revenueReport, attendanceReport, membershipReport, memberGrowthReport, trainerPerformanceReport, exportReport } from '../controllers/report.controller.js';

const router = Router();

router.get('/revenue', authenticate, requireRole('admin', 'superadmin'), revenueReport);
router.get('/attendance', authenticate, requireRole('admin', 'superadmin'), attendanceReport);
router.get('/membership', authenticate, requireRole('admin', 'superadmin'), membershipReport);
router.get('/member-growth', authenticate, requireRole('admin', 'superadmin'), memberGrowthReport);
router.get('/trainer-performance', authenticate, requireRole('admin', 'superadmin'), trainerPerformanceReport);
router.get('/export/:type', authenticate, requireRole('admin', 'superadmin'), exportReport);

export default router;
