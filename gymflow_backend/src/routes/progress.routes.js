import { Router } from 'express';
import { authenticate, requireRole } from '../middleware/auth.js';
import { validate, schemas } from '../middleware/validate.js';
import { myProgress, memberProgress, addProgress, deleteProgress } from '../controllers/progress.controller.js';

const router = Router();

router.get('/mine', authenticate, myProgress);
router.get('/:memberId', authenticate, requireRole('admin', 'trainer'), memberProgress);
router.post('/', authenticate, validate(schemas.addProgress), addProgress);
router.delete('/:id', authenticate, deleteProgress);

export default router;
