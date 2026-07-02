import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_service.dart';
import '../../config/theme.dart';
import '../../models/payment.dart';

class PaymentHistoryScreen extends ConsumerStatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  ConsumerState<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends ConsumerState<PaymentHistoryScreen> {
  final _api = ApiService();
  List<Payment> _payments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final data = await _api.getPayments();
      setState(() => _payments = data.map((p) => Payment.fromJson(p)).toList());
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _payments.where((p) => p.isCompleted).fold<double>(0, (s, p) => s + p.amount);

    return Scaffold(
      appBar: AppBar(title: const Text('Payment History')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [GymFlowColors.primary, GymFlowColors.primaryDark]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Revenue', style: TextStyle(color: Colors.white70, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text('₹${total.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Transactions', style: TextStyle(color: Colors.white70, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text('${_payments.length}',
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _payments.length,
                      itemBuilder: (c, i) {
                        final p = _payments[i];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: p.isCompleted ? GymFlowColors.successBg : GymFlowColors.warningBg,
                              child: Icon(
                                p.isCompleted ? Icons.check_circle : Icons.pending,
                                color: p.isCompleted ? GymFlowColors.success : GymFlowColors.warning,
                                size: 20,
                              ),
                            ),
                            title: Text('₹${p.amount.toStringAsFixed(0)}',
                                style: Theme.of(context).textTheme.bodyLarge),
                            subtitle: Text('${p.memberName ?? 'Member'} • ${p.paymentDate?.substring(0, 10) ?? ''}',
                                style: Theme.of(context).textTheme.bodySmall),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(p.method.toUpperCase(),
                                    style: TextStyle(fontSize: 11, color: GymFlowColors.textMuted)),
                                Text(p.planName ?? '', style: TextStyle(fontSize: 11, color: GymFlowColors.textMuted)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
