import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/formatters.dart';
import '../../../res/theme/app_colors.dart';
import '../../../res/theme/app_text_styles.dart';
import '../../../shared/models/seller_payment_model.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../seller_repository.dart';

class SellerPaymentHistoryView extends StatefulWidget {
  const SellerPaymentHistoryView({super.key});

  @override
  State<SellerPaymentHistoryView> createState() => _SellerPaymentHistoryViewState();
}

class _SellerPaymentHistoryViewState extends State<SellerPaymentHistoryView> {
  final SellerRepository _sellerRepo = Get.find<SellerRepository>();
  bool isLoading = true;
  List<SellerPaymentModel> payments = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => isLoading = true);
    try {
      payments = await _sellerRepo.getMyPayments();
    } catch (e, st) {
      AppLogger.error('SellerPaymentHistoryView._load failed', e, st);
    }
    if (mounted) setState(() => isLoading = false);
  }

  Color _statusColor(SellerPaymentModel p) {
    if (p.isVerified) return AppColors.emerald;
    if (p.isRejected) return AppColors.error;
    return AppColors.warning;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment History')),
      backgroundColor: AppColors.background,
      body: isLoading
          ? const LoadingIndicator(message: 'Loading payment history...')
          : payments.isEmpty
              ? const EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'No Payments Yet',
                  message: 'Payments you submit will show up here.',
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
                                Text(AppFormatters.taka(p.amount),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _statusColor(p).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    p.status,
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _statusColor(p)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text('${p.method} • ${p.paymentNumber}', style: AppTextStyles.caption),
                            Text('Txn ID: ${p.transactionId}', style: AppTextStyles.caption),
                            Text(AppFormatters.formatDateTime(p.createdAt), style: AppTextStyles.caption),
                            if (p.isRejected && p.note != null && p.note!.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text('Reason: ${p.note}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.error, fontStyle: FontStyle.italic)),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
