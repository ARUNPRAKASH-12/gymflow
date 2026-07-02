import dotenv from 'dotenv';

dotenv.config();

let razorpayInstance = null;

const keyId = process.env.RAZORPAY_KEY_ID;
const keySecret = process.env.RAZORPAY_KEY_SECRET;

if (keyId && keySecret && !keyId.startsWith('rzp_test_xxx')) {
  try {
    const { default: Razorpay } = await import('razorpay');
    razorpayInstance = new Razorpay({
      key_id: keyId,
      key_secret: keySecret,
    });
    console.log('Razorpay initialized successfully');
  } catch (err) {
    console.warn('Razorpay initialization failed:', err.message);
  }
} else {
  console.warn('Razorpay not configured — payment gateway unavailable');
}

export function getRazorpay() {
  if (!razorpayInstance) {
    throw new Error('Razorpay is not configured. Set RAZORPAY_KEY_ID and RAZORPAY_KEY_SECRET.');
  }
  return razorpayInstance;
}

export const razorpay = razorpayInstance;
export const isRazorpayConfigured = () => razorpayInstance !== null;
