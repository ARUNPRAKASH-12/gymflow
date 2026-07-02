import { supabase } from '../config/supabase.js';
import { razorpay } from '../config/razorpay.js';
import crypto from 'crypto';

export async function listPayments(req, res) {
  try {
    const { gym_id, status, method, from, to, page = 1, limit = 50 } = req.query;
    const targetGym = gym_id || req.user.selected_gym_id;

    let query = supabase
      .from('payments')
      .select('*, user:users(id, email), profile:user_profiles!user_id(full_name), plan:membership_plans(name)')
      .order('payment_date', { ascending: false });

    if (targetGym) query = query.eq('gym_id', targetGym);
    if (status) query = query.eq('status', status);
    if (method) query = query.eq('method', method);
    if (from) query = query.gte('payment_date', from);
    if (to) query = query.lte('payment_date', to);

    const fromRecord = (page - 1) * limit;
    query = query.range(fromRecord, fromRecord + limit - 1);

    const { data: payments, error } = await query;
    if (error) throw error;

    return res.json(payments || []);
  } catch (err) {
    console.error('List payments error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}

export async function myPayments(req, res) {
  try {
    const { data: payments, error } = await supabase
      .from('payments')
      .select('*, plan:membership_plans(name)')
      .eq('user_id', req.user.id)
      .order('payment_date', { ascending: false });

    if (error) throw error;

    const totalPaid = payments?.filter(p => p.status === 'completed').reduce((s, p) => s + Number(p.amount), 0) || 0;

    return res.json({ payments: payments || [], total_paid: totalPaid });
  } catch (err) {
    console.error('My payments error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}

export async function createPayment(req, res) {
  try {
    const { user_id, gym_id, membership_plan_id, amount, method, transaction_id } = req.validated.body;
    const targetGym = gym_id || req.user.selected_gym_id;

    const invoiceNumber = `INV-${Date.now()}-${Math.random().toString(36).substring(2, 6).toUpperCase()}`;

    const { data: payment, error } = await supabase.from('payments').insert({
      user_id,
      gym_id: targetGym,
      membership_plan_id,
      amount,
      method,
      transaction_id: transaction_id || null,
      status: 'completed',
      invoice_number: invoiceNumber,
      payment_date: new Date().toISOString(),
    }).select('*, user:users(id, email), profile:user_profiles!user_id(full_name), plan:membership_plans(name)').single();

    if (error) return res.status(400).json({ error: error.message });

    if (membership_plan_id) {
      const { data: plan } = await supabase.from('membership_plans').select('duration_days').eq('id', membership_plan_id).single();
      if (plan) {
        const { data: member } = await supabase.from('members').select('id, end_date').eq('user_id', user_id).single();
        if (member) {
          const now = new Date();
          const currentEnd = member.end_date ? new Date(member.end_date) : now;
          const newStart = currentEnd > now ? currentEnd : now;
          const newEnd = new Date(newStart);
          newEnd.setDate(newEnd.getDate() + plan.duration_days);

          await supabase.from('members').update({
            membership_plan_id,
            start_date: newStart.toISOString().split('T')[0],
            end_date: newEnd.toISOString().split('T')[0],
            status: 'active',
            updated_at: new Date().toISOString(),
          }).eq('id', member.id);
        }
      }
    }

    return res.status(201).json(payment);
  } catch (err) {
    console.error('Create payment error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}

export async function createRazorpayOrder(req, res) {
  try {
    const { membership_plan_id } = req.body;

    if (!membership_plan_id) {
      return res.status(400).json({ error: 'Membership plan ID is required' });
    }

    const { data: plan, error: planError } = await supabase
      .from('membership_plans')
      .select('*')
      .eq('id', membership_plan_id)
      .single();

    if (planError) return res.status(404).json({ error: 'Plan not found' });

    const amountInPaise = Math.round(Number(plan.price) * 100);

    const options = {
      amount: amountInPaise,
      currency: 'INR',
      receipt: `rcpt_${Date.now()}`,
      notes: {
        user_id: req.user.id,
        membership_plan_id,
        gym_id: req.user.selected_gym_id,
      },
    };

    const order = await razorpay.orders.create(options);

    await supabase.from('payments').insert({
      user_id: req.user.id,
      gym_id: req.user.selected_gym_id,
      membership_plan_id,
      amount: plan.price,
      method: 'razorpay',
      razorpay_order_id: order.id,
      status: 'pending',
      invoice_number: `INV-${Date.now()}`,
    });

    return res.json({
      order_id: order.id,
      amount: order.amount,
      currency: order.currency,
      key_id: process.env.RAZORPAY_KEY_ID,
      plan_name: plan.name,
      user_name: req.user.full_name || 'Member',
      email: req.user.email,
    });
  } catch (err) {
    console.error('Create Razorpay order error:', err);
    return res.status(500).json({ error: 'Failed to create payment order' });
  }
}

export async function verifyRazorpay(req, res) {
  try {
    const { order_id, payment_id, signature } = req.body;

    const body = order_id + '|' + payment_id;
    const expectedSignature = crypto
      .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET)
      .update(body)
      .digest('hex');

    if (expectedSignature !== signature) {
      return res.status(400).json({ error: 'Invalid payment signature' });
    }

    const { data: payment } = await supabase
      .from('payments')
      .update({
        razorpay_payment_id: payment_id,
        razorpay_signature: signature,
        status: 'completed',
        transaction_id: payment_id,
        payment_date: new Date().toISOString(),
      })
      .eq('razorpay_order_id', order_id)
      .select()
      .single();

    if (payment?.membership_plan_id) {
      const { data: plan } = await supabase.from('membership_plans').select('duration_days').eq('id', payment.membership_plan_id).single();
      if (plan) {
        const { data: member } = await supabase.from('members').select('id, end_date').eq('user_id', payment.user_id).single();
        if (member) {
          const now = new Date();
          const currentEnd = member.end_date ? new Date(member.end_date) : now;
          const newStart = currentEnd > now ? currentEnd : now;
          const newEnd = new Date(newStart);
          newEnd.setDate(newEnd.getDate() + plan.duration_days);

          await supabase.from('members').update({
            membership_plan_id: payment.membership_plan_id,
            start_date: newStart.toISOString().split('T')[0],
            end_date: newEnd.toISOString().split('T')[0],
            status: 'active',
            updated_at: new Date().toISOString(),
          }).eq('id', member.id);
        }
      }
    }

    return res.json({ message: 'Payment verified successfully', payment });
  } catch (err) {
    console.error('Verify payment error:', err);
    return res.status(500).json({ error: 'Payment verification failed' });
  }
}

export async function paymentReport(req, res) {
  try {
    const { gym_id, from, to } = req.query;
    const targetGym = gym_id || req.user.selected_gym_id;

    let query = supabase
      .from('payments')
      .select('*')
      .eq('status', 'completed');

    if (targetGym) query = query.eq('gym_id', targetGym);
    if (from) query = query.gte('payment_date', from);
    if (to) query = query.lte('payment_date', to);

    const { data: payments, error } = await query.order('payment_date', { ascending: true });
    if (error) throw error;

    const totalRevenue = payments?.reduce((s, p) => s + Number(p.amount), 0) || 0;

    const monthlyData = {};
    payments?.forEach((p) => {
      const month = new Date(p.payment_date).toISOString().substring(0, 7);
      monthlyData[month] = (monthlyData[month] || 0) + Number(p.amount);
    });

    const methodBreakdown = {};
    payments?.forEach((p) => {
      methodBreakdown[p.method] = (methodBreakdown[p.method] || 0) + Number(p.amount);
    });

    return res.json({
      total_revenue: totalRevenue,
      total_transactions: payments?.length || 0,
      monthly: Object.entries(monthlyData).map(([month, revenue]) => ({ month, revenue })),
      method_breakdown: Object.entries(methodBreakdown).map(([method, amount]) => ({ method, amount })),
    });
  } catch (err) {
    console.error('Payment report error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}

export async function getInvoice(req, res) {
  try {
    const { id } = req.params;

    const { data: payment, error } = await supabase
      .from('payments')
      .select('*, user:users(id, email), profile:user_profiles!user_id(full_name, address), plan:membership_plans(name), gym:gyms(name, address, phone, email)')
      .eq('id', id)
      .single();

    if (error) return res.status(404).json({ error: 'Payment not found' });

    return res.json(payment);
  } catch (err) {
    console.error('Get invoice error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}

export async function downloadInvoice(req, res) {
  try {
    const { id } = req.params;
    const { generateInvoicePdf } = await import('../services/invoice.service.js');
    const { pdfBuffer, payment } = await generateInvoicePdf(id);

    const invoiceNo = payment.invoice_number || `INV-${id.substring(0, 8)}`;
    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', `attachment; filename="${invoiceNo}.pdf"`);
    res.setHeader('Content-Length', pdfBuffer.length);
    return res.send(pdfBuffer);
  } catch (err) {
    console.error('Download invoice error:', err);
    if (err.message === 'Payment not found') {
      return res.status(404).json({ error: 'Payment not found' });
    }
    return res.status(500).json({ error: 'Failed to generate invoice' });
  }
}
