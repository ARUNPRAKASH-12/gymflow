import { Router } from 'express';
import { authenticate, requireRole } from '../middleware/auth.js';
import { validate, schemas } from '../middleware/validate.js';
import { listDiets, getDiet, createDiet, updateDiet, deleteDiet } from '../controllers/diet.controller.js';

const router = Router();

router.get('/', authenticate, listDiets);
router.get('/:id', authenticate, getDiet);
router.post('/', authenticate, requireRole('trainer', 'admin'), validate(schemas.createDiet), createDiet);
router.put('/:id', authenticate, requireRole('trainer', 'admin'), updateDiet);
router.delete('/:id', authenticate, requireRole('trainer', 'admin'), deleteDiet);

export default router;
