import { Router } from 'express';
import { authenticate, requireRole } from '../middleware/auth.js';
import { validate, schemas } from '../middleware/validate.js';
import { listWorkouts, getWorkout, createWorkout, updateWorkout, deleteWorkout, completeWorkout, listExercises, createExercise } from '../controllers/workout.controller.js';

const router = Router();

router.get('/', authenticate, listWorkouts);
router.get('/:id', authenticate, getWorkout);
router.post('/', authenticate, requireRole('trainer', 'admin'), validate(schemas.createWorkout), createWorkout);
router.put('/:id', authenticate, requireRole('trainer', 'admin'), updateWorkout);
router.delete('/:id', authenticate, requireRole('trainer', 'admin'), deleteWorkout);
router.put('/:id/complete', authenticate, requireRole('member', 'trainer'), completeWorkout);
router.get('/exercises/list', authenticate, listExercises);
router.post('/exercises', authenticate, requireRole('admin', 'trainer'), createExercise);

export default router;
