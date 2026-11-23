import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/formatters.dart';
import '../../../res/theme/app_colors.dart';
import '../../../res/theme/app_text_styles.dart';
import '../../../shared/models/seller_payment_model.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/snack_message.dart';
import '../admin_repository.dart';

class AdminSellerPaymentsView extends StatefulWidget {
  const AdminSellerPaymentsView({super.key});

  @override
  State<AdminSellerPaymentsView> createState() => _AdminSellerPaymentsViewState();
}

class _AdminSellerPaymentsViewState extends State<AdminSellerPaymentsView> {
  final AdminRepository _adminRepo = Get.find<AdminRepository>();
  final filters = const ['Pending Verification', 'Verified', 'Rejected', ''];
  String status = 'Pending Verification';
  bool isLoading = true;
  List<SellerPaymentModel> payments = [];
  final Set<String> _busyIds = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => isLoading = true);
    try {
      payments = await _adminRepo.getSellerPayments(status: status);
    } catch (e, st) {
      AppLogger.error('AdminSellerPaymentsView._load failed', e, st);
    }
    if (mounted) setState(() => isLoading = false);
  }

  Future<void> _verify(SellerPaymentModel p) async {
    setState(() => _busyIds.add(p.id));
    try {
      await _adminRepo.reviewSellerPayment(paymentId: p.id, action: 'verify');
      SnackMessage.success('Payment verified.');
      _load();
    } catch (_) {
      SnackMessage.error('Failed to verify payment.');
    } finally {
      if (mounted) setState(() => _busyIds.remove(p.id));
    }
  }

  Future<void> _reject(SellerPaymentModel p) async {
    final noteController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reject Payment'),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(hintText: 'Reason (optional)'),
          maxLines: 2,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Reject')),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _busyIds.add(p.id));
    try {
      await _adminRepo.reviewSellerPayment(paymentId: p.id, action: 'reject', note: noteController.text.trim());
      SnackMessage.success('Payment rejected.');
      _load();
    } catch (_) {
      SnackMessage.error('Failed to reject payment.');
    } finally {
      if (mounted) setState(() => _busyIds.remove(p.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seller Payments')),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: filters.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final f = filters[index];
                  final isSelected = status == f;
                  return ChoiceChip(
                    label: Text(f.isEmpty ? 'ALL' : f.toUpperCase()),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => status = f);
                      _load();
                    },
                    selectedColor: AppColors.textDark,
                    backgroundColor: AppColors.inputBg,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textDark,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 11,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    showCheckmark: false,
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const LoadingIndicator(message: 'Loading payments...')
                : payments.isEmpty
                    ? const EmptyState(
                        icon: Icons.payments_outlined,
                        title: 'No Payments',
                        message: 'No seller payments match this filter.',
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        color: AppColors.primary,
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          itemCount: payments.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final p = payments[index];
                            final busy = _busyIds.contains(p.id);
                            return Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        p.shopName?.isNotEmpty == true ? p.shopName! : (p.sellerName ?? 'Seller'),
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      Text(AppFormatters.taka(p.amount),
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                    ],
                                  ),
                                  Text('${p.sellerName ?? ''} • ${p.sellerPhone ?? ''}', style: AppTextStyles.caption),
                                  const SizedBox(height: 6),
                                  Text('${p.method} • ${p.paymentNumber}', style: AppTextStyles.caption),
                                  Text('Txn ID: ${p.transactionId}', style: AppTextStyles.caption),
                                  Text(AppFormatters.formatDateTime(p.createdAt), style: AppTextStyles.caption),
                                  if (p.isPending) ...[
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        OutlinedButton(
                                          onPressed: busy ? null : () => _reject(p),
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(color: AppColors.error),
                                            foregroundColor: AppColors.error,
                                          ),
                                          child: const Text('Reject'),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          onPressed: busy ? null : () => _verify(p),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.emerald,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text('Verify'),
                                        ),
                                      ],
                                    ),
                                  ] else if (p.note != null && p.note!.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text('Note: ${p.note}', style: AppTextStyles.caption.copyWith(fontStyle: FontStyle.italic)),
                                  ],
                                ],
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
