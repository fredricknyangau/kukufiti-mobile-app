import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../presentation/widgets/app_drawer.dart';
import '../../../../presentation/widgets/custom_card.dart';
import '../../../../presentation/widgets/custom_input.dart';
import '../../../../presentation/widgets/custom_button.dart';
import '../../../../providers/data_providers.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/utils/toast_service.dart';

class MarketScreen extends ConsumerWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final marketAsync = ref.watch(marketPricesProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Market Prices', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: marketAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (prices) {
          if (prices.isEmpty) {
            return const Center(child: Text('No market data available.'));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(marketPricesProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: prices.length,
              itemBuilder: (context, index) {
                final item = prices[index];
                final isDown = item['trend'] == 'down';
                return CustomCard(
                  isPremium: true,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Icon(
                      isDown ? LucideIcons.trendingDown : LucideIcons.trendingUp,
                      color: isDown ? theme.colorScheme.error : theme.colorScheme.primary,
                    ),
                    title: Text(item['town'] ?? 'General Market', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(item['county'] ?? 'County'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'KES ${item['price_per_kg'] ?? 0} /kg',
                          style: TextStyle(
                            color: isDown ? theme.colorScheme.error : theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        PopupMenuButton<String>(
                          icon: const Icon(LucideIcons.moreVertical, size: 20),
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showAddPriceDialog(context, ref, item: item);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPriceDialog(context, ref),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(LucideIcons.plus),
      ),
    );
  }

  void _showAddPriceDialog(BuildContext context, WidgetRef ref, {Map<String, dynamic>? item}) {
    final priceController = TextEditingController(text: (item?['price_per_kg'] ?? '').toString());
    final marketController = TextEditingController(text: item?['market'] ?? '');
    final countyController = TextEditingController(text: item?['county'] ?? '');
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(item != null ? 'Edit Market Price' : 'Add Market Price'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomInput(label: 'Price (KES/kg)', keyboardType: const TextInputType.numberWithOptions(decimal: true), controller: priceController),
              const SizedBox(height: 12),
              CustomInput(label: 'Market Name', hintText: 'e.g. City Market', controller: marketController),
              const SizedBox(height: 12),
              CustomInput(label: 'County', hintText: 'e.g. Nairobi', controller: countyController),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            CustomButton(
              text: 'Save',
              isLoading: isLoading,
              onPressed: () async {
                final price = double.tryParse(priceController.text) ?? 0.0;
                if (price <= 0) return;
                setState(() => isLoading = true);
                try {
                  final payload = {
                    'price_date': DateTime.now().toIso8601String().split('T')[0],
                    'price_per_kg': price,
                    'town': marketController.text.trim().isEmpty ? 'General' : marketController.text.trim(),
                    'county': countyController.text.trim().isEmpty ? 'N/A' : countyController.text.trim(),
                  };

                  if (item != null) {
                    await ApiClient.instance.put('${ApiEndpoints.marketPrices}/${item['id']}', data: payload);
                  } else {
                    await ApiClient.instance.post(ApiEndpoints.marketPrices, data: payload);
                  }
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    ref.invalidate(marketPricesProvider);
                    ToastService.showSuccess(context, item != null ? 'Price updated' : 'Price logged');
                  }
                } catch (e) {
                  if (ctx.mounted) ToastService.showError(context, 'Failed to log price');
                } finally {
                  if (ctx.mounted) setState(() => isLoading = false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
