import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/utils/formatters.dart';
import '../../../res/theme/app_colors.dart';
import '../../../res/theme/app_text_styles.dart';
import '../../../shared/models/seller_payment_model.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/snack_message.dart';
import '../seller_repository.dart';

// Settles the seller's due balance using the same manual bKash/Nagad flow
// customers already use at checkout: pick an admin-configured number, send
// money outside the app, report the transaction id for admin to verify.
// The seller can pay the full balance or just a subset of unpaid orders.
class SellerPaymentSheet extends StatefulWidget {
  const SellerPaymentSheet({super.key});

  @override
  State<SellerPaymentSheet> createState() => _SellerPaymentSheetState();
}

class _SellerPaymentSheetState extends State<SellerPaymentSheet> {
  final SellerRepository _sellerRepo = Get.find<SellerRepository>();
  final transactionIdController = TextEditingController();

  List<SellerDueOrderModel> orders = [];
  final Set<String> selectedOrderIds = {};
  List<PaymentMethodModel> methods = [];
  PaymentMethodModel? selected;
  bool isLoading = true;
  bool isSubmitting = false;

  num get selectedAmount =>
      orders.where((o) => selectedOrderIds.contains(o.id)).fold<num>(0, (sum, o) => sum + o.cost);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    transactionIdController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final due = await _sellerRepo.getPaymentDue();
      final methodList = await _sellerRepo.getPaymentMethods();
      setState(() {
        orders = due.orders;
        selectedOrderIds
          ..clear()
          ..addAll(orders.map((o) => o.id));
        methods = methodList;
        selected = methodList.isNotEmpty ? methodList.first : null;
      });
    } catch (_) {
      SnackMessage.error('Failed to load payment details.');
    }
    if (mounted) setState(() => isLoading = false);
  }

  void _toggleOrder(String id) {
    setState(() {
      if (selectedOrderIds.contains(id)) {
        selectedOrderIds.remove(id);
      } else {
        selectedOrderIds.add(id);
      }
    });
  }

  Future<void> _submit() async {
    if (selectedOrderIds.isEmpty) {
      SnackMessage.error('Select at least one order to pay.');
      return;
    }
    if (selected == null) {
      SnackMessage.error('Select a payment method.');
      return;
    }
    if (transactionIdController.text.trim().isEmpty) {
      SnackMessage.error('Enter your transaction id.');
      return;
    }

    setState(() => isSubmitting = true);
    try {
      await _sellerRepo.submitPayment(
        method: selected!.method,
        paymentNumber: selected!.number,
        transactionId: transactionIdController.text.trim(),
        orderIds: selectedOrderIds.length == orders.length ? null : selectedOrderIds.toList(),
      );
      SnackMessage.success('Payment submitted. Admin will verify it shortly.');
      Get.back(result: true);
    } catch (_) {
      SnackMessage.error('Failed to submit payment. Try again.');
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Pay Your Due', style: AppTextStyles.h2),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: isLoading
                    ? const LoadingIndicator(message: 'Loading payment details...')
                    : ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(20),
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Selected Amount', style: TextStyle(fontWeight: FontWeight.w600)),
                                Text(
                                  AppFormatters.taka(selectedAmount),
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.primaryDark),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Select Orders to Pay', style: AppTextStyles.h3),
                              TextButton(
                                onPressed: () => setState(() {
                                  if (selectedOrderIds.length == orders.length) {
                                    selectedOrderIds.clear();
                                  } else {
                                    selectedOrderIds
                                      ..clear()
                                      ..addAll(orders.map((o) => o.id));
                                  }
                                }),
                                child: Text(selectedOrderIds.length == orders.length ? 'Clear All' : 'Select All'),
                              ),
                            ],
                          ),
                          ...orders.map((o) {
                            final isChecked = selectedOrderIds.contains(o.id);
                            return CheckboxListTile(
                              value: isChecked,
                              onChanged: (_) => _toggleOrder(o.id),
                              contentPadding: EdgeInsets.zero,
                              controlAffinity: ListTileControlAffinity.leading,
                              title: Text('#${o.referenceCode}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                              subtitle: Text(AppFormatters.formatDate(o.createdAt), style: AppTextStyles.caption),
                              secondary: Text(AppFormatters.taka(o.cost), style: const TextStyle(fontWeight: FontWeight.bold)),
                            );
                          }),
                          const SizedBox(height: 10),

                          const Text('Select Payment Method', style: AppTextStyles.h3),
                          const SizedBox(height: 10),
                          if (methods.isEmpty)
                            const Text(
                              'No payment methods configured yet. Contact admin.',
                              style: AppTextStyles.bodyMuted,
                            )
                          else
                            ...methods.map((m) {
                              final isSelected = selected?.id == m.id;
                              return InkWell(
                                onTap: () => setState(() => selected = m),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected ? AppColors.primary : AppColors.border,
                                      width: isSelected ? 2 : 1,
                                    ),
                                    color: isSelected ? AppColors.primary.withValues(alpha: 0.06) : Colors.white,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                        color: isSelected ? AppColors.primary : AppColors.textLight,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(m.method, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                            Text(m.number, style: AppTextStyles.bodyMuted),
                                            if (m.extraDetails != null && m.extraDetails!.isNotEmpty) ...[
                                              const SizedBox(height: 2),
                                              Text(m.extraDetails!, style: AppTextStyles.caption),
                                            ],
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.copy_outlined, size: 18, color: AppColors.textLight),
                                        tooltip: 'Copy number',
                                        onPressed: () {
                                          Clipboard.setData(ClipboardData(text: m.number));
                                          SnackMessage.info('Number copied.');
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          const SizedBox(height: 20),

                          CustomTextField(
                            label: 'Transaction ID',
                            hint: 'e.g. 8N7A2XQZ1K',
                            controller: transactionIdController,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Send the selected amount to the chosen number, then enter the transaction id you received.',
                            style: AppTextStyles.caption,
                          ),
                          const SizedBox(height: 24),

                          CustomButton(
                            text: 'Submit Payment',
                            isLoading: isSubmitting,
                            onPressed: methods.isEmpty || selectedOrderIds.isEmpty ? null : _submit,
                          ),
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
