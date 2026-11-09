import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/formatters.dart';
import '../../../res/theme/app_colors.dart';
import '../../../res/theme/app_text_styles.dart';
import '../../../shared/models/catalog_product_model.dart';
import '../../../shared/widgets/app_network_image.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import 'admin_pricing_controller.dart';

class AdminPricingView extends GetView<AdminPricingController> {
  const AdminPricingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingIndicator(message: 'Loading product catalog...');
        }

        if (controller.products.isEmpty) {
          return const EmptyState(
            icon: Icons.inventory_2_outlined,
            title: 'No Products',
            message: 'No catalog products available to configure wholesale pricing.',
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadProducts,
          color: AppColors.primary,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.products.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final product = controller.products[index];
              return _ProductPriceCard(
                product: product,
                onConfigure: () => _showPriceEditor(context, product),
              );
            },
          ),
        );
      }),
    );
  }

  void _showPriceEditor(BuildContext context, CatalogProductModel product) async {
    final prices = await controller.getPricesForProduct(product.id);
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditPricesSheet(
        product: product,
        initialPrices: prices,
        onSave: (newPrices) => controller.savePrices(product.id, newPrices),
      ),
    );
  }
}

class _ProductPriceCard extends StatelessWidget {
  final CatalogProductModel product;
  final VoidCallback onConfigure;

  const _ProductPriceCard({required this.product, required this.onConfigure});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onConfigure,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            AppNetworkImage(
              url: product.image,
              width: 52,
              height: 52,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text('${product.category} • ${product.variants.length} variant(s)', style: AppTextStyles.caption),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: onConfigure,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Set Prices', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditPricesSheet extends StatefulWidget {
  final CatalogProductModel product;
  final Map<String, num> initialPrices;
  final ValueChanged<Map<String, num>> onSave;

  const _EditPricesSheet({
    required this.product,
    required this.initialPrices,
    required this.onSave,
  });

  @override
  State<_EditPricesSheet> createState() => _EditPricesSheetState();
}

class _EditPricesSheetState extends State<_EditPricesSheet> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (final v in widget.product.variants) {
      final existing = widget.initialPrices[v.label] ?? v.sellerPrice;
      _controllers[v.label] = TextEditingController(text: existing != null ? '$existing' : '');
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Wholesale Seller Prices', style: AppTextStyles.h2),
                          Text(widget.product.productName, style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
              ),
              const Divider(),

              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    ...widget.product.variants.map((v) {
                      final controller = _controllers[v.label];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.inputBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(v.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  if (v.retailPrice > 0)
                                    Text('Retail: ${AppFormatters.taka(v.retailPrice)}', style: AppTextStyles.caption),
                                ],
                              ),
                            ),
                            const Text('৳ ', style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(
                              width: 100,
                              height: 38,
                              child: TextField(
                                controller: controller,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                decoration: const InputDecoration(
                                  hintText: 'Seller ৳',
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: () {
                        final result = <String, num>{};
                        _controllers.forEach((label, ctrl) {
                          final n = num.tryParse(ctrl.text.trim());
                          if (n != null && n > 0) {
                            result[label] = n;
                          }
                        });
                        widget.onSave(result);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: const Text('Save Wholesale Prices'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
