class Payment {
  final String id;
  final String userId;
  final String gymId;
  final String? membershipPlanId;
  final double amount;
  final String method;
  final String? transactionId;
  final String status;
  final String? invoiceUrl;
  final String? invoiceNumber;
  final String? paymentDate;
  final String? planName;
  final String? memberName;

  Payment({
    required this.id,
    required this.userId,
    required this.gymId,
    this.membershipPlanId,
    required this.amount,
    required this.method,
    this.transactionId,
    required this.status,
    this.invoiceUrl,
    this.invoiceNumber,
    this.paymentDate,
    this.planName,
    this.memberName,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      gymId: json['gym_id'] ?? '',
      membershipPlanId: json['membership_plan_id'],
      amount: (json['amount'] ?? 0).toDouble(),
      method: json['method'] ?? 'cash',
      transactionId: json['transaction_id'],
      status: json['status'] ?? 'pending',
      invoiceUrl: json['invoice_url'],
      invoiceNumber: json['invoice_number'],
      paymentDate: json['payment_date'],
      planName: json['plan']?['name'],
      memberName: json['profile']?['full_name'] ?? json['member_name'],
    );
  }

  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending';

  String get methodIcon {
    switch (method) {
      case 'razorpay':
        return '💰';
      case 'cash':
        return '💵';
      case 'upi':
        return '📱';
      default:
        return '💳';
    }
  }
}
