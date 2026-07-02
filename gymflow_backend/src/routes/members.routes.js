import { Router } from 'express';
import { authenticate, requireRole } from '../middleware/auth.js';
import { validate, schemas } from '../middleware/validate.js';
import {
  listMembers, getMember, createMember, updateMember, deleteMember,
  getMemberAttendance, getMemberPayments, renewMembership,
} from '../controllers/member.controller.js';

const router = Router();

router.get('/', authenticate, requireRole('admin', 'superadmin'), listMembers);
router.get('/:id', authenticate, getMember);
router.post('/', authenticate, requireRole('admin', 'superadmin'), validate(schemas.createMember), createMember);
router.put('/:id', authenticate, requireRole('admin', 'superadmin'), updateMember);
router.delete('/:id', authenticate, requireRole('admin', 'superadmin'), deleteMember);
router.get('/:id/attendance', authenticate, getMemberAttendance);
router.get('/:id/payments', authenticate, getMemberPayments);
router.post('/:id/renew', authenticate, requireRole('admin', 'member'), renewMembership);

export default router;
