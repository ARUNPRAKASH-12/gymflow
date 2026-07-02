import { Router } from 'express';
import { authenticate, requireRole } from '../middleware/auth.js';
import { validate, schemas } from '../middleware/validate.js';
import { listPayments, myPayments, createPayment, createRazorpayOrder, verifyRazorpay, paymentReport, getInvoice, downloadInvoice } from '../controllers/payment.controller.js';

const router = Router();

router.get('/', authenticate, requireRole('admin', 'superadmin'), listPayments);
router.get('/mine', authenticate, myPayments);
router.post('/', authenticate, requireRole('admin'), validate(schemas.createPayment), createPayment);
router.post('/create-order', authenticate, requireRole('member', 'admin'), createRazorpayOrder);
router.post('/verify', authenticate, verifyRazorpay);
router.get('/report', authenticate, requireRole('admin', 'superadmin'), paymentReport);
router.get('/:id/invoice', authenticate, getInvoice);
router.get('/:id/invoice/download', authenticate, downloadInvoice);

export default router;
