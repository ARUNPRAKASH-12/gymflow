import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_service.dart';
import '../../config/theme.dart';

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> with SingleTickerProviderStateMixin {
  final _api = ApiService();
  late TabController _tabController;
  Map<String, dynamic>? _revenueData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final revenue = await _api.getRevenueReport();
      setState(() => _revenueData = revenue);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Revenue'),
            Tab(text: 'Members'),
            Tab(text: 'Attendance'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _RevenueTab(data: _revenueData),
                const Center(child: Text('Membership report coming soon')),
                const Center(child: Text('Attendance report coming soon')),
              ],
            ),
    );
  }
}

class _RevenueTab extends StatelessWidget {
  final Map<String, dynamic>? data;
  const _RevenueTab({this.data});

  @override
  Widget build(BuildContext context) {
    final monthly = (data?['monthly'] as List?) ?? [];
    final planBreakdown = (data?['plan_breakdown'] as List?) ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text('Total Revenue', style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 8),
                        Text('₹${data?['total_revenue'] ?? 0}',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: GymFlowColors.primary)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text('Transactions', style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 8),
                        Text('${data?['transaction_count'] ?? 0}',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: GymFlowColors.secondary)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Monthly Breakdown', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 12),
          ...monthly.map((m) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(m['month'] ?? ''),
                  trailing: Text('₹${m['revenue'] ?? 0}',
                      style: TextStyle(fontWeight: FontWeight.bold, color: GymFlowColors.primary)),
                ),
              )),
          if (planBreakdown.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('By Plan', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 12),
            ...planBreakdown.map((p) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(p['plan'] ?? ''),
                    trailing: Text('₹${p['revenue'] ?? 0}',
                        style: TextStyle(fontWeight: FontWeight.bold, color: GymFlowColors.primary)),
                  ),
                )),
          ],
        ],
      ),
    );
  }
}
