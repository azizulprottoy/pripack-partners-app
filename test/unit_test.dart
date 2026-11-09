import 'package:flutter_test/flutter_test.dart';
import 'package:pripack_seller/core/utils/constants.dart';
import 'package:pripack_seller/core/utils/formatters.dart';
import 'package:pripack_seller/shared/models/catalog_product_model.dart';
import 'package:pripack_seller/shared/models/seller_order_model.dart';
import 'package:pripack_seller/shared/models/supplier_job_model.dart';
import 'package:pripack_seller/shared/models/user_model.dart';

void main() {
  group('AppFormatters Tests', () {
    test('taka formatting adds currency sign and commas', () {
      expect(AppFormatters.taka(1500), contains('৳'));
      expect(AppFormatters.taka(1500), contains('1,500'));
      expect(AppFormatters.taka(0), contains('0'));
    });

    test('getStatusColor returns expected color for statuses', () {
      expect(AppFormatters.getStatusColor('approved'), isNotNull);
      expect(AppFormatters.getStatusColor('pending'), isNotNull);
      expect(AppFormatters.getStatusColor('cancelled'), isNotNull);
    });
  });

  group('Data Models Tests', () {
    test('UserModel parse and role checks', () {
      final sellerJson = {
        'id': 's123',
        'name': 'Test Seller',
        'email': 'seller@example.com',
        'phone': '01711111111',
        'atype': 'seller',
        'status': 'approved',
      };
      final seller = UserModel.fromJson(sellerJson);
      expect(seller.isSeller, isTrue);
      expect(seller.isSupplier, isFalse);
      expect(seller.isApproved, isTrue);

      final adminJson = {
        'id': 'a123',
        'remail': 'admin@example.com',
        'role': 'admin',
        'tabs': ['Overview', 'Orders'],
      };
      final admin = UserModel.fromJson(adminJson);
      expect(admin.isAdmin, isTrue);
      expect(admin.tabs.length, 2);
    });

    test('CatalogProductModel and orderable variants', () {
      final productJson = {
        '_id': 'p1',
        'productName': 'Custom Box',
        'category': 'Packaging',
        'variants': [
          {'label': '100 pcs', 'price': 500, 'sellerPrice': 380},
          {'label': '500 pcs', 'price': 2000, 'sellerPrice': null},
        ],
      };
      final product = CatalogProductModel.fromJson(productJson);
      expect(product.productName, 'Custom Box');
      expect(product.variants.length, 2);
      expect(product.orderableVariants.length, 1);
      expect(product.orderableVariants.first.label, '100 pcs');
    });

    test('SellerOrderModel and totals', () {
      final orderJson = {
        '_id': 'o1',
        'referenceCode': 'ORD-999',
        'orderFor': 'customer',
        'status': AppConstants.orderPending,
        'customer': {
          'name': 'Jane Doe',
          'phone': '01800000000',
          'address': 'Dhanmondi, Dhaka',
        },
        'items': [
          {
            'productId': 'p1',
            'productName': 'Box',
            'variantLabel': 'Standard',
            'units': 2,
            'sellerPrice': 100,
            'sellingPrice': 150,
            'cost': 200,
            'selling': 300,
            'profit': 100,
          }
        ],
        'totals': {'cost': 200, 'selling': 300, 'profit': 100, 'units': 2},
      };
      final order = SellerOrderModel.fromJson(orderJson);
      expect(order.isCustomerOrder, isTrue);
      expect(order.canCancel, isTrue);
      expect(order.totals.profit, 100);
      expect(order.customer?.name, 'Jane Doe');
    });

    test('SupplierJobModel actions check', () {
      final jobJson = {
        '_id': 'j1',
        'type': 'customer',
        'referenceCode': 'JOB-101',
        'supplierStatus': AppConstants.jobAssigned,
        'items': [
          {
            'productName': 'Flyers',
            'units': 1000,
            'options': ['A4', 'Glossy'],
          }
        ],
      };
      final job = SupplierJobModel.fromJson(jobJson);
      expect(job.isAssigned, isTrue);
      expect(job.canStart, isTrue);
      expect(job.canRequestPickup, isTrue);
    });
  });
}
