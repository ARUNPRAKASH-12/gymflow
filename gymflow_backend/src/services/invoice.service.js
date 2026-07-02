import PDFDocument from 'pdfkit';
import { supabase } from '../config/supabase.js';

export async function generateInvoicePdf(paymentId) {
  const { data: payment, error } = await supabase
    .from('payments')
    .select('*, user:users(id, email), profile:user_profiles!user_id(full_name, address), plan:membership_plans(name, duration_days), gym:gyms(name, address, phone, email)')
    .eq('id', paymentId)
    .single();

  if (error || !payment) {
    throw new Error('Payment not found');
  }

  const doc = new PDFDocument({
    size: 'A4',
    margin: 50,
    info: {
      Title: `Invoice ${payment.invoice_number || payment.id}`,
      Author: 'GymFlow',
    },
  });

  const buffers = [];
  doc.on('data', (chunk) => buffers.push(chunk));

  return new Promise((resolve, reject) => {
    doc.on('end', () => {
      const pdfBuffer = Buffer.concat(buffers);
      resolve({ pdfBuffer, payment });
    });
    doc.on('error', reject);

    // Header
    doc.fontSize(24).font('Helvetica-Bold').text(payment.gym?.name || 'GymFlow', { align: 'center' });
    doc.fontSize(10).font('Helvetica').fillColor('#666666');
    doc.text(payment.gym?.address || '', { align: 'center' });
    doc.text(`Phone: ${payment.gym?.phone || ''}  |  Email: ${payment.gym?.email || ''}`, { align: 'center' });
    doc.moveDown();

    // Invoice Title
    doc.moveDown();
    doc.fontSize(18).font('Helvetica-Bold').fillColor('#000000').text('INVOICE', { align: 'center' });
    doc.moveDown(0.5);

    // Invoice Info
    const invoiceNo = payment.invoice_number || `INV-${payment.id.substring(0, 8)}`;
    const invoiceDate = payment.payment_date ? new Date(payment.payment_date).toLocaleDateString('en-IN') : new Date().toLocaleDateString('en-IN');

    const infoTop = 180;
    doc.fontSize(10).font('Helvetica');
    doc.text(`Invoice No: ${invoiceNo}`, 50, infoTop);
    doc.text(`Date: ${invoiceDate}`, 50, infoTop + 15);
    doc.text(`Status: ${payment.status?.toUpperCase()}`, 50, infoTop + 30);

    // Bill To
    const billToY = 260;
    doc.fontSize(12).font('Helvetica-Bold').text('Bill To:');
    doc.fontSize(10).font('Helvetica').fillColor('#333333');
    doc.text(payment.profile?.full_name || 'Member', { indent: 0 });
    doc.text(payment.user?.email || '');
    if (payment.profile?.address) doc.text(payment.profile.address);

    // Table Header
    const tableTop = 360;
    doc.fontSize(10).font('Helvetica-Bold').fillColor('#FFFFFF');
    doc.roundedRect(50, tableTop - 8, 500, 28, 4).fill('#1A1A2E');
    doc.fillColor('#FFFFFF');
    doc.text('Description', 60, tableTop, { width: 250 });
    doc.text('Qty', 320, tableTop, { width: 60, align: 'center' });
    doc.text('Amount', 420, tableTop, { width: 100, align: 'right' });

    // Table Row
    const rowY = tableTop + 35;
    doc.font('Helvetica').fillColor('#333333').fontSize(10);
    doc.text(payment.plan?.name || 'Membership Plan', 60, rowY, { width: 250 });
    doc.text('1', 320, rowY, { width: 60, align: 'center' });
    doc.text(`₹${Number(payment.amount).toLocaleString('en-IN')}`, 420, rowY, { width: 100, align: 'right' });

    // Total
    const totalY = rowY + 40;
    doc.moveTo(350, totalY).lineTo(550, totalY).stroke('#CCCCCC');
    doc.font('Helvetica-Bold').fontSize(12).fillColor('#000000');
    doc.text('Total:', 350, totalY + 10, { width: 80 });
    doc.text(`₹${Number(payment.amount).toLocaleString('en-IN')}`, 420, totalY + 10, { width: 130, align: 'right' });

    // Footer
    const footerY = 700;
    doc.fontSize(9).font('Helvetica').fillColor('#999999');
    doc.text('Thank you for choosing ' + (payment.gym?.name || 'GymFlow') + '!', 50, footerY, { align: 'center' });
    doc.text('This is a computer-generated invoice.', 50, footerY + 15, { align: 'center' });

    doc.end();
  });
}

export async function generateInvoiceNumber(gymId) {
  const { count } = await supabase
    .from('payments')
    .select('*', { count: 'exact', head: true })
    .eq('gym_id', gymId);

  const num = (count || 0) + 1;
  const date = new Date();
  return `GYM-${date.getFullYear()}${String(date.getMonth() + 1).padStart(2, '0')}-${String(num).padStart(4, '0')}`;
}
