import { Router } from 'express';
import { register, login, forgotPassword, resetPassword, verifyEmail } from '../controllers/auth.controller.js';
import { validate, schemas } from '../middleware/validate.js';

const router = Router();

router.post('/register', validate(schemas.register), register);
router.post('/login', validate(schemas.login), login);
router.post('/forgot-password', forgotPassword);
router.post('/reset-password', resetPassword);
router.post('/verify-email', verifyEmail);

export default router;
