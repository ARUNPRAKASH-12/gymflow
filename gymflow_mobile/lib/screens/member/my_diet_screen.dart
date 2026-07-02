import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_service.dart';
import '../../config/theme.dart';
import '../../utils/extensions.dart';

class MyDietScreen extends ConsumerStatefulWidget {
  const MyDietScreen({super.key});

  @override
  ConsumerState<MyDietScreen> createState() => _MyDietScreenState();
}

class _MyDietScreenState extends ConsumerState<MyDietScreen> {
  final _api = ApiService();
  List<dynamic> _diets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final data = await _api.getDiets();
      setState(() => _diets = data);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Diet Plan')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _diets.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.restaurant, size: 64, color: GymFlowColors.textMuted),
                          const SizedBox(height: 16),
                          Text('No diet plan assigned', style: Theme.of(context).textTheme.bodyLarge),
                          const SizedBox(height: 8),
                          Text('Your trainer will assign a diet plan for you',
                              style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _diets.length,
                      itemBuilder: (c, i) {
                        final diet = _diets[i];
                        final meals = diet['meals'] as List? ?? [];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(diet['name'] ?? '', style: Theme.of(context).textTheme.titleLarge),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: GymFlowColors.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        (diet['type'] as String?)?.replaceAll('_', ' ').toUpperCase() ?? '',
                                        style: TextStyle(fontSize: 11, color: GymFlowColors.primary, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                                if (diet['target_calories'] != null) ...[
                                  const SizedBox(height: 8),
                                  Text('Target: ${diet['target_calories']} calories/day',
                                      style: Theme.of(context).textTheme.bodyMedium),
                                ],
                                const SizedBox(height: 16),
                                ...meals.map((meal) => Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: GymFlowColors.surfaceLight,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                (meal['meal'] as String?)?.replaceAll('_', ' ').capitalize() ?? '',
                                                style: TextStyle(fontWeight: FontWeight.w600, color: GymFlowColors.primary),
                                              ),
                                              const Spacer(),
                                              Text(meal['time'] ?? '', style: Theme.of(context).textTheme.bodySmall),
                                              if (meal['calories'] != null) ...[
                                                const SizedBox(width: 12),
                                                Text('${meal['calories']} cal',
                                                    style: Theme.of(context).textTheme.bodySmall),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          ...((meal['foods'] as List?) ?? []).map((food) => Padding(
                                                padding: const EdgeInsets.only(bottom: 4),
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.circle, size: 6, color: GymFlowColors.textMuted),
                                                    const SizedBox(width: 8),
                                                    Text(food.toString(), style: Theme.of(context).textTheme.bodySmall),
                                                  ],
                                                ),
                                              )),
                                        ],
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}


