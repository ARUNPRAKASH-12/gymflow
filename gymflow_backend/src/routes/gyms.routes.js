import { Router } from 'express';
import { authenticate, requireRole, requireGymAccess } from '../middleware/auth.js';
import { listGyms, getGym, createGym, updateGym, selectGym } from '../controllers/gym.controller.js';

const router = Router();

router.get('/', authenticate, listGyms);
router.get('/:id', authenticate, getGym);
router.post('/', authenticate, requireRole('superadmin', 'admin'), createGym);
router.put('/:id', authenticate, requireRole('superadmin', 'admin'), updateGym);
router.post('/:id/select', authenticate, selectGym);

export default router;
