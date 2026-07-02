import { Router } from 'express';
import { authenticate } from '../middleware/auth.js';
import { getProfile, updateProfile, uploadPhoto } from '../controllers/user.controller.js';
import { upload } from '../middleware/upload.js';

const router = Router();

router.get('/me', authenticate, getProfile);
router.put('/me', authenticate, updateProfile);
router.post('/me/photo', authenticate, upload.single('photo'), uploadPhoto);

export default router;
