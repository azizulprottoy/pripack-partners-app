import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../res/theme/app_colors.dart';
import '../../../res/theme/app_text_styles.dart';
import '../../../shared/models/seller_order_model.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import 'admin_seller_orders_controller.dart';

const _divisions = [
  'Dhaka', 'Chattogram', 'Rajshahi', 'Khulna', 'Barishal', 'Sylhet', 'Rangpur', 'Mymensingh',
];

// Books a CC-Delivery rider for this order: pickup from the assigned
// supplier, deliver to the order's customer (or seller, for a 'self'
// order). Pickup fields are only required the first time for a given
// supplier — the backend caches the address and reuses it after that,
// which is why pickup starts collapsed with an explanatory hint instead of
// being shown as a hard requirement up front.
class RequestRiderSheet extends StatefulWidget {
  final SellerOrderModel order;
  final AdminSellerOrdersController controller;

  const RequestRiderSheet({super.key, required this.order, required this.controller});

  @override
  State<RequestRiderSheet> createState() => _RequestRiderSheetState();
}

class _RequestRiderSheetState extends State<RequestRiderSheet> {
  bool showPickupFields = false;

  String pickupDivision = _divisions.first;
  final pickupDistrict = TextEditingController();
  final pickupUpazila = TextEditingController();
  final pickupAddressLine = TextEditingController();
  final pickupContactName = TextEditingController();
  final pickupContactPhone = TextEditingController();

  String deliveryDivision = _divisions.first;
  final deliveryDistrict = TextEditingController();
  final deliveryUpazila = TextEditingController();
  final deliveryAddressLine = TextEditingController();

  bool submitting = false;

  @override
  void initState() {
    super.initState();
    final supplier = widget.order.supplier;
    pickupDistrict.text = supplier?['address']?.toString() ?? '';
    pickupAddressLine.text = supplier?['address']?.toString() ?? '';
    pickupContactName.text = supplier?['name']?.toString() ?? '';
    pickupContactPhone.text = supplier?['phone']?.toString() ?? '';
    deliveryAddressLine.text = widget.order.isCustomerOrder
        ? (widget.order.customer?.address ?? '')
        : '';
  }

  @override
  void dispose() {
    pickupDistrict.dispose();
    pickupUpazila.dispose();
    pickupAddressLine.dispose();
    pickupContactName.dispose();
    pickupContactPhone.dispose();
    deliveryDistrict.dispose();
    deliveryUpazila.dispose();
    deliveryAddressLine.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (deliveryDistrict.text.trim().isEmpty ||
        deliveryUpazila.text.trim().isEmpty ||
        deliveryAddressLine.text.trim().isEmpty) {
      Get.snackbar('Missing details', 'Delivery district, upazila and address are required.');
      return;
    }

    setState(() => submitting = true);
    final ok = await widget.controller.requestRider(
      orderId: widget.order.id,
      pickup: showPickupFields
          ? {
              'division': pickupDivision,
              'district': pickupDistrict.text.trim(),
              'upazila': pickupUpazila.text.trim(),
              'address_line': pickupAddressLine.text.trim(),
              'contact_name': pickupContactName.text.trim(),
              'contact_phone': pickupContactPhone.text.trim(),
            }
          : null,
      delivery: {
        'division': deliveryDivision,
        'district': deliveryDistrict.text.trim(),
        'upazila': deliveryUpazila.text.trim(),
        'address_line': deliveryAddressLine.text.trim(),
      },
    );
    if (!mounted) return;
    setState(() => submitting = false);
    if (ok) Get.back();
  }

  Widget _divisionDropdown(String value, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: AppColors.inputBg, borderRadius: BorderRadius.circular(10)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          items: _divisions.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.order;
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
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
                  decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Request Rider', style: AppTextStyles.h2),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      'Rider picks up from ${o.supplier?['name'] ?? 'the supplier'} and delivers to '
                      '${o.isCustomerOrder ? (o.customer?.name ?? 'the customer') : 'the seller'}.',
                      style: AppTextStyles.bodyMuted,
                    ),
                    const SizedBox(height: 20),

                    InkWell(
                      onTap: () => setState(() => showPickupFields = !showPickupFields),
                      child: Row(
                        children: [
                          Icon(showPickupFields ? Icons.expand_less : Icons.expand_more, size: 20),
                          const SizedBox(width: 6),
                          const Expanded(child: Text('Pickup address', style: AppTextStyles.h3)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Only needed the first time for this supplier — leave collapsed if it was already '
                      'saved on an earlier order. The backend will ask for it if it wasn\'t.',
                      style: AppTextStyles.caption,
                    ),
                    if (showPickupFields) ...[
                      const SizedBox(height: 12),
                      _divisionDropdown(pickupDivision, (v) => setState(() => pickupDivision = v!)),
                      const SizedBox(height: 10),
                      CustomTextField(label: 'District', controller: pickupDistrict),
                      const SizedBox(height: 10),
                      CustomTextField(label: 'Upazila', controller: pickupUpazila),
                      const SizedBox(height: 10),
                      CustomTextField(label: 'Address', controller: pickupAddressLine, maxLines: 2),
                      const SizedBox(height: 10),
                      CustomTextField(label: 'Contact Name', controller: pickupContactName),
                      const SizedBox(height: 10),
                      CustomTextField(label: 'Contact Phone', controller: pickupContactPhone),
                    ],
                    const SizedBox(height: 24),

                    const Text('Delivery address', style: AppTextStyles.h3),
                    const SizedBox(height: 12),
                    _divisionDropdown(deliveryDivision, (v) => setState(() => deliveryDivision = v!)),
                    const SizedBox(height: 10),
                    CustomTextField(label: 'District', controller: deliveryDistrict),
                    const SizedBox(height: 10),
                    CustomTextField(label: 'Upazila', controller: deliveryUpazila),
                    const SizedBox(height: 10),
                    CustomTextField(label: 'Address', controller: deliveryAddressLine, maxLines: 2),
                    const SizedBox(height: 24),

                    CustomButton(
                      text: 'Request Rider',
                      isLoading: submitting,
                      onPressed: _submit,
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
