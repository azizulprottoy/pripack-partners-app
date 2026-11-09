import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/constants.dart';
import '../../../shared/models/catalog_product_model.dart';
import '../../../shared/models/partner_model.dart';
import '../../../shared/models/seller_order_model.dart';
import '../../../shared/widgets/snack_message.dart';
import '../seller_repository.dart';

class OrderCartLine {
  final CatalogProductModel product;
  final ProductVariant variant;
  int units;
  num sellingPrice;

  OrderCartLine({
    required this.product,
    required this.variant,
    this.units = 1,
    required this.sellingPrice,
  });

  String get key => '${product.id}::${variant.label}';
  num get sellerPrice => variant.sellerPrice ?? 0;
  num get cost => sellerPrice * units;
  num get selling => sellingPrice * units;
  num get profit => selling - cost;
}

class SellerCatalogController extends GetxController {
  final SellerRepository _sellerRepo = Get.find<SellerRepository>();

  final profile = Rx<PartnerModel?>(null);
  final categories = <String>[].obs;
  final selectedCategory = 'All'.obs;
  final searchQuery = ''.obs;

  final products = <CatalogProductModel>[].obs;
  final isLoading = true.obs;
  final isSubmitting = false.obs;

  // Selected lines in the draft order
  final cartLines = <OrderCartLine>[].obs;

  // Order type: 'customer' or 'self'
  final orderFor = 'customer'.obs;

  // Customer details
  final customerNameController = TextEditingController();
  final customerPhoneController = TextEditingController();
  final customerAddressController = TextEditingController();
  final noteController = TextEditingController();

  num get totalCost => cartLines.fold<num>(0, (sum, line) => sum + line.cost);
  num get totalSelling => cartLines.fold<num>(
        0,
        (sum, line) => sum + (orderFor.value == 'self' ? line.cost : line.selling),
      );
  num get totalProfit => orderFor.value == 'self' ? 0 : totalSelling - totalCost;

  bool get canOrder => profile.value?.status == AppConstants.statusApproved;

  @override
  void onInit() {
    super.onInit();
    loadCatalog();
  }

  @override
  void onClose() {
    customerNameController.dispose();
    customerPhoneController.dispose();
    customerAddressController.dispose();
    noteController.dispose();
    super.onClose();
  }

  Future<void> loadCatalog() async {
    isLoading.value = true;
    try {
      profile.value = await _sellerRepo.getProfile();
      final result = await _sellerRepo.getCatalog(
        category: selectedCategory.value,
        query: searchQuery.value,
      );
      categories.assignAll(['All', ...result.categories]);
      products.assignAll(result.products);
    } catch (e, st) {
      AppLogger.error('SellerCatalogController.loadCatalog failed', e, st);
    }
    isLoading.value = false;
  }

  void selectCategory(String cat) {
    selectedCategory.value = cat;
    loadCatalog();
  }

  void search(String q) {
    searchQuery.value = q;
    loadCatalog();
  }

  void addToOrder(CatalogProductModel product, ProductVariant variant, int qty) {
    final key = '${product.id}::${variant.label}';
    final existingIndex = cartLines.indexWhere((l) => l.key == key);

    final defaultSell = variant.retailPrice > 0 ? variant.retailPrice : (variant.sellerPrice ?? 0);

    if (existingIndex >= 0) {
      cartLines[existingIndex].units += qty;
      cartLines.refresh();
    } else {
      cartLines.add(
        OrderCartLine(
          product: product,
          variant: variant,
          units: qty,
          sellingPrice: defaultSell,
        ),
      );
    }

    SnackMessage.success('Added ${product.productName} (${variant.label}) to order.');
  }

  void updateUnits(String key, int units) {
    final line = cartLines.firstWhereOrNull((l) => l.key == key);
    if (line != null && units > 0) {
      line.units = units;
      cartLines.refresh();
    }
  }

  void updateSellingPrice(String key, num price) {
    final line = cartLines.firstWhereOrNull((l) => l.key == key);
    if (line != null && price >= 0) {
      line.sellingPrice = price;
      cartLines.refresh();
    }
  }

  void removeLine(String key) {
    cartLines.removeWhere((l) => l.key == key);
  }

  Future<bool> submitOrder() async {
    if (!canOrder) {
      SnackMessage.error('Your seller account must be approved by admin to place orders.');
      return false;
    }
    if (cartLines.isEmpty) {
      SnackMessage.error('Add at least one product to the order.');
      return false;
    }

    if (orderFor.value == 'customer') {
      if (customerNameController.text.trim().isEmpty) {
        SnackMessage.error('Please enter customer name.');
        return false;
      }
      if (customerPhoneController.text.trim().isEmpty) {
        SnackMessage.error('Please enter customer phone.');
        return false;
      }
      if (customerAddressController.text.trim().isEmpty) {
        SnackMessage.error('Please enter delivery address.');
        return false;
      }
    }

    isSubmitting.value = true;
    try {
      final itemsPayload = cartLines.map((l) {
        return {
          'productId': l.product.id,
          'productName': l.product.productName,
          'variantLabel': l.variant.label,
          'units': l.units,
          'sellingPrice': orderFor.value == 'self' ? l.sellerPrice : l.sellingPrice,
        };
      }).toList();

      final customerInfo = orderFor.value == 'customer'
          ? OrderCustomerInfo(
              name: customerNameController.text.trim(),
              phone: customerPhoneController.text.trim(),
              address: customerAddressController.text.trim(),
            )
          : null;

      await _sellerRepo.placeOrder(
        orderFor: orderFor.value,
        customer: customerInfo,
        items: itemsPayload,
        note: noteController.text.trim(),
      );

      SnackMessage.success('Order placed successfully! Admin will verify soon.');
      cartLines.clear();
      customerNameController.clear();
      customerPhoneController.clear();
      customerAddressController.clear();
      noteController.clear();
      return true;
    } catch (e) {
      SnackMessage.error('Failed to place order. Try again.');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}
