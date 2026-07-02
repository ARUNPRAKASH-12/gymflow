import { Router } from 'express';
import { authenticate, requireRole } from '../middleware/auth.js';
import { validate, schemas } from '../middleware/validate.js';
import { listAttendance, todayAttendance, myAttendance, checkIn, checkOut, attendanceReport, generateQR } from '../controllers/attendance.controller.js';

const router = Router();

router.get('/', authenticate, requireRole('admin', 'superadmin'), listAttendance);
router.get('/today', authenticate, requireRole('admin', 'superadmin'), todayAttendance);
router.get('/mine', authenticate, myAttendance);
router.post('/check-in', authenticate, validate(schemas.checkIn), checkIn);
router.put('/:id/check-out', authenticate, checkOut);
router.get('/report', authenticate, requireRole('admin', 'superadmin'), attendanceReport);
router.get('/qr', authenticate, requireRole('admin', 'superadmin'), generateQR);

export default router;
