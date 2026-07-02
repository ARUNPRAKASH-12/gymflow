import { Router } from 'express';
import { authenticate, requireRole } from '../middleware/auth.js';
import { myNotifications, markRead, sendNotification, sendBulkNotification } from '../controllers/notification.controller.js';

const router = Router();

router.get('/', authenticate, myNotifications);
router.put('/:id/read', authenticate, markRead);
router.post('/', authenticate, requireRole('admin', 'superadmin'), sendNotification);
router.post('/bulk', authenticate, requireRole('admin', 'superadmin'), sendBulkNotification);

export default router;
