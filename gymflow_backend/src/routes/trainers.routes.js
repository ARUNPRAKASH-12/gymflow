import { Router } from 'express';
import { authenticate, requireRole } from '../middleware/auth.js';
import { validate, schemas } from '../middleware/validate.js';
import { listTrainers, getTrainer, createTrainer, updateTrainer, deleteTrainer, getTrainerMembers } from '../controllers/trainer.controller.js';

const router = Router();

router.get('/', authenticate, requireRole('admin', 'superadmin'), listTrainers);
router.get('/:id', authenticate, getTrainer);
router.post('/', authenticate, requireRole('admin', 'superadmin'), validate(schemas.createTrainer), createTrainer);
router.put('/:id', authenticate, requireRole('admin', 'superadmin'), updateTrainer);
router.delete('/:id', authenticate, requireRole('admin', 'superadmin'), deleteTrainer);
router.get('/:id/members', authenticate, getTrainerMembers);

export default router;
