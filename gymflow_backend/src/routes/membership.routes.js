import { Router } from 'express';
import { authenticate, requireRole } from '../middleware/auth.js';
import { validate, schemas } from '../middleware/validate.js';
import { listPlans, getPlan, createPlan, updatePlan, deletePlan } from '../controllers/membership.controller.js';

const router = Router();

router.get('/', authenticate, listPlans);
router.get('/:id', authenticate, getPlan);
router.post('/', authenticate, requireRole('admin', 'superadmin'), validate(schemas.createPlan), createPlan);
router.put('/:id', authenticate, requireRole('admin', 'superadmin'), updatePlan);
router.delete('/:id', authenticate, requireRole('admin', 'superadmin'), deletePlan);

export default router;
