class Razorpay {
  constructor(options) {
    this.key_id = options.key_id;
    this.key_secret = options.key_secret;
  }

  orders = {
    create: () => Promise.resolve({
      id: 'order_test_123456',
      amount: 99900,
      currency: 'INR',
      receipt: 'rcpt_test',
      status: 'created',
    }),
    fetch: () => Promise.resolve({
      id: 'order_test_123456',
      amount: 99900,
      status: 'paid',
    }),
  };

  payments = {
    fetch: () => Promise.resolve({
      id: 'pay_test_123456',
      status: 'captured',
      amount: 99900,
    }),
  };
}

export default Razorpay;
