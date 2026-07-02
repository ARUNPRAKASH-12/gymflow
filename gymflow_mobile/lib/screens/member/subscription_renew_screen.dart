import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../config/theme.dart';
import '../../models/member.dart';

class SubscriptionRenewScreen extends ConsumerStatefulWidget {
  const SubscriptionRenewScreen({super.key});

  @override
  ConsumerState<SubscriptionRenewScreen> createState() => _SubscriptionRenewScreenState();
}

class _SubscriptionRenewScreenState extends ConsumerState<SubscriptionRenewScreen> {
  final _api = ApiService();
  List<MembershipPlan> _plans = [];
  bool _isLoading = true;
  String? _selectedPlanId;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final data = await _api.getPlans();
      setState(() => _plans = data.map((p) => MembershipPlan.fromJson(p)).toList());
      if (_plans.isNotEmpty) _selectedPlanId = _plans[0].id;
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _renew() async {
    if (_selectedPlanId == null) return;
    setState(() => _isProcessing = true);
    try {
      final order = await _api.createRazorpayOrder(_selectedPlanId!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order created: ${order['order_id']}'), backgroundColor: GymFlowColors.success),
        );
        context.go('/member/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Renew Membership')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Select a Plan', style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: 8),
                Text('Choose a membership plan to renew',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 24),
                ..._plans.map((plan) {
                  final isSelected = plan.id == _selectedPlanId;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isSelected ? GymFlowColors.primary : GymFlowColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: InkWell(
                      onTap: () => setState(() => _selectedPlanId = plan.id),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Radio<String>(
                              value: plan.id,
                              groupValue: _selectedPlanId,
                              activeColor: GymFlowColors.primary,
                              onChanged: (v) => setState(() => _selectedPlanId = v),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(plan.name, style: Theme.of(context).textTheme.titleLarge),
                                  Text('${plan.durationDays} days',
                                      style: Theme.of(context).textTheme.bodySmall),
                                  if (plan.description != null) ...[
                                    const SizedBox(height: 4),
                                    Text(plan.description!, style: Theme.of(context).textTheme.bodySmall),
                                  ],
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Text('₹${plan.price.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: GymFlowColors.primary,
                                    )),
                                if (plan.discountedPrice != null)
                                  Text('₹${plan.discountedPrice!.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: GymFlowColors.textMuted,
                                        decoration: TextDecoration.lineThrough,
                                      )),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _renew,
                    child: _isProcessing
                        ? const SizedBox(width: 24, height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text('Pay ₹${_selectedPlanId != null ? _plans.firstWhere((p) => p.id == _selectedPlanId).price.toStringAsFixed(0) : '0'}'),
                  ),
                ),
              ],
            ),
    );
  }
}
