import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/formatters.dart';
import '../../../res/theme/app_colors.dart';
import '../../../res/theme/app_text_styles.dart';
import '../../../shared/models/catalog_product_model.dart';
import '../../../shared/widgets/app_network_image.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import 'seller_catalog_controller.dart';

class SellerCatalogView extends GetView<SellerCatalogController> {
  final VoidCallback? onOrderPlaced;

  const SellerCatalogView({super.key, this.onOrderPlaced});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Search & Filter header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              children: [
                // Search bar
                TextField(
                  onChanged: (val) => controller.search(val),
                  decoration: InputDecoration(
                    hintText: 'Search products by name...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.textLight),
                    fillColor: AppColors.inputBg,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Category chips
                Obx(() {
                  final selectedCategory = controller.selectedCategory.value;
                  return SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.categories.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final cat = controller.categories[index];
                        final isSelected = selectedCategory == cat;
                        return ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (_) => controller.selectCategory(cat),
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.inputBg,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textDark,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            fontSize: 12,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          showCheckmark: false,
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          ),

          // Approval Warning if not approved
          Obx(() {
            if (!controller.canOrder && controller.profile.value != null) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: AppColors.warning.withValues(alpha: 0.15),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.warning, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Account status is "${controller.profile.value!.status}". Admin approval required to place orders.',
                        style: const TextStyle(fontSize: 12, color: Color(0xFFB45309), fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          // Product List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const LoadingIndicator(message: 'Loading catalog products...');
              }

              if (controller.products.isEmpty) {
                return const EmptyState(
                  icon: Icons.inventory_2_outlined,
                  title: 'No Products in Your Categories',
                  message: 'Ask admin to assign more product categories to your seller account.',
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: controller.products.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final product = controller.products[index];
                  return _CatalogProductCard(
                    product: product,
                    onAddVariant: (variant, qty) {
                      controller.addToOrder(product, variant, qty);
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: Obx(() {
        final count = controller.cartLines.length;
        if (count == 0) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$count Product${count > 1 ? 's' : ''} in Draft',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        'Wholesale Cost: ${AppFormatters.taka(controller.totalCost)}',
                        style: AppTextStyles.bodyMuted,
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showOrderSheet(context),
                  icon: const Icon(Icons.shopping_cart_checkout, size: 18),
                  label: const Text('Review Order'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _showOrderSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _OrderReviewSheet(
        controller: controller,
        onSubmitted: () {
          Navigator.pop(ctx);
          onOrderPlaced?.call();
        },
      ),
    );
  }
}

class _CatalogProductCard extends StatefulWidget {
  final CatalogProductModel product;
  final void Function(ProductVariant variant, int qty) onAddVariant;

  const _CatalogProductCard({
    required this.product,
    required this.onAddVariant,
  });

  @override
  State<_CatalogProductCard> createState() => _CatalogProductCardState();
}

class _CatalogProductCardState extends State<_CatalogProductCard> {
  ProductVariant? selectedVariant;
  int units = 1;

  @override
  void initState() {
    super.initState();
    final orderable = widget.product.orderableVariants;
    if (orderable.isNotEmpty) {
      selectedVariant = orderable.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderable = widget.product.orderableVariants;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppNetworkImage(
                url: widget.product.image,
                width: 72,
                height: 72,
                borderRadius: BorderRadius.circular(12),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.product.productName, style: AppTextStyles.h3),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.product.category}${widget.product.subCategory != null ? ' • ${widget.product.subCategory}' : ''}',
                      style: AppTextStyles.caption,
                    ),
                    if (widget.product.deliveryTime != null) ...[
                      const SizedBox(height: 2),
                      Text('Delivery: ${widget.product.deliveryTime}', style: AppTextStyles.caption),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),

          if (orderable.isEmpty)
            const Text(
              'Seller wholesale price not set yet for this item. Contact admin.',
              style: TextStyle(fontSize: 12, color: AppColors.textLight, fontStyle: FontStyle.italic),
            )
          else ...[
            Row(
              children: [
                // Variant Selector Dropdown
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: AppColors.inputBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<ProductVariant>(
                        isExpanded: true,
                        value: selectedVariant ?? orderable.first,
                        items: orderable.map((v) {
                          return DropdownMenuItem<ProductVariant>(
                            value: v,
                            child: Text(v.label, style: const TextStyle(fontSize: 13)),
                          );
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => selectedVariant = v);
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Qty Counter
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.inputBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 16),
                        onPressed: units > 1 ? () => setState(() => units--) : null,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 36),
                      ),
                      Text('$units', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      IconButton(
                        icon: const Icon(Icons.add, size: 16),
                        onPressed: () => setState(() => units++),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 36),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Price: ${AppFormatters.taka(selectedVariant?.sellerPrice)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    if (selectedVariant != null && selectedVariant!.retailPrice > 0)
                      Text(
                        'Retail: ${AppFormatters.taka(selectedVariant!.retailPrice)}',
                        style: AppTextStyles.caption.copyWith(decoration: TextDecoration.lineThrough),
                      ),
                  ],
                ),
                ElevatedButton(
                  onPressed: selectedVariant == null
                      ? null
                      : () => widget.onAddVariant(selectedVariant!, units),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Add to Order', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _OrderReviewSheet extends StatelessWidget {
  final SellerCatalogController controller;
  final VoidCallback onSubmitted;

  const _OrderReviewSheet({
    required this.controller,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Sheet Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Order Configuration', style: AppTextStyles.h2),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),

              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Order For Toggle
                    const Text('Who is this order for?', style: AppTextStyles.h3),
                    const SizedBox(height: 8),
                    Obx(() {
                      final isCustomer = controller.orderFor.value == 'customer';
                      return Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: const Center(child: Text('For a Customer')),
                              selected: isCustomer,
                              onSelected: (_) => controller.orderFor.value = 'customer',
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(
                                color: isCustomer ? Colors.white : AppColors.textDark,
                                fontWeight: isCustomer ? FontWeight.w700 : FontWeight.normal,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ChoiceChip(
                              label: const Center(child: Text('For Myself')),
                              selected: !isCustomer,
                              onSelected: (_) => controller.orderFor.value = 'self',
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(
                                color: !isCustomer ? Colors.white : AppColors.textDark,
                                fontWeight: !isCustomer ? FontWeight.w700 : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: 20),

                    // Customer fields if for customer
                    Obx(() {
                      if (controller.orderFor.value != 'customer') return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Customer Delivery Information', style: AppTextStyles.h3),
                          const SizedBox(height: 12),
                          CustomTextField(
                            label: 'Customer Name',
                            hint: 'Full name',
                            controller: controller.customerNameController,
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            label: 'Customer Phone',
                            hint: '01700000000',
                            controller: controller.customerPhoneController,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            label: 'Delivery Address',
                            hint: 'Full street address, district',
                            controller: controller.customerAddressController,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 24),
                        ],
                      );
                    }),

                    // Items List
                    const Text('Ordered Products', style: AppTextStyles.h3),
                    const SizedBox(height: 10),
                    Obx(() {
                      final lines = controller.cartLines;
                      final isCustomer = controller.orderFor.value == 'customer';

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: lines.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final l = lines[index];
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.inputBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${l.product.productName} • ${l.variant.label}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                                      onPressed: () => controller.removeLine(l.key),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Wholesale: ${AppFormatters.taka(l.sellerPrice)}',
                                        style: AppTextStyles.caption,
                                      ),
                                    ),
                                    Text('Qty: ${l.units}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  ],
                                ),
                                if (isCustomer) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Text('Selling Price / unit:  ৳ ', style: TextStyle(fontSize: 12)),
                                      SizedBox(
                                        width: 100,
                                        height: 32,
                                        child: TextFormField(
                                          initialValue: '${l.sellingPrice}',
                                          keyboardType: TextInputType.number,
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                          decoration: const InputDecoration(
                                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            isDense: true,
                                          ),
                                          onChanged: (val) {
                                            final n = num.tryParse(val);
                                            if (n != null) controller.updateSellingPrice(l.key, n);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Profit: ${AppFormatters.taka(l.profit)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: l.profit >= 0 ? AppColors.emerald : AppColors.error,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      );
                    }),
                    const SizedBox(height: 16),

                    CustomTextField(
                      label: 'Order Note for Admin (Optional)',
                      hint: 'Special packaging instructions, custom requests...',
                      controller: controller.noteController,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 20),

                    // Financial Summary Box
                    Obx(() {
                      final isCustomer = controller.orderFor.value == 'customer';
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.inputBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('You Pay (Wholesale Cost)', style: AppTextStyles.bodyMuted),
                                Text(AppFormatters.taka(controller.totalCost), style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            if (isCustomer) ...[
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Customer Pays', style: AppTextStyles.bodyMuted),
                                  Text(AppFormatters.taka(controller.totalSelling), style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const Divider(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Your Net Profit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text(
                                    AppFormatters.taka(controller.totalProfit),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      color: controller.totalProfit >= 0 ? AppColors.emerald : AppColors.error,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 24),

                    Obx(() => CustomButton(
                          text: controller.canOrder ? 'Confirm & Place Order' : 'Awaiting Admin Approval',
                          isLoading: controller.isSubmitting.value,
                          onPressed: controller.canOrder
                              ? () async {
                                  final ok = await controller.submitOrder();
                                  if (ok) onSubmitted();
                                }
                              : null,
                        )),
                    const SizedBox(height: 20),
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
