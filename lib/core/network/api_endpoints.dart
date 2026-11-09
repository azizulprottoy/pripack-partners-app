class ApiEndpoints {
  ApiEndpoints._();

  // Authentication
  static const String customerLogin = '/customerlogin';
  static const String staffLogin = '/login';
  static const String sellerRegister = '/sellerregister';
  static const String supplierRegister = '/supplierregister';

  // Geo & Categories
  static const String divisions = '/divisions';
  static const String districts = '/districts';
  static const String areas = '/areas';
  static const String getCat = '/getcat';
  static const String getCatNSub = '/getcatnsub';

  // Seller Endpoints
  static const String sellerMe = '/seller/me';
  static const String sellerMeCategories = '/seller/me/categories';
  static const String sellerCatalog = '/seller/catalog';
  static const String sellerOrders = '/seller/orders';
  static const String sellerChat = '/sellerchat'; // + /:sellerId

  // Supplier Endpoints
  static const String supplierMe = '/supplier/me';
  static const String supplierMeCategories = '/supplier/me/categories';
  static const String supplierJobs = '/supplier/jobs';
  static const String updateSupplierJob = '/supplier/jobs'; // + /:type/:id

  // Partner Chat (Seller & Supplier with Admin)
  static const String partnerChat = '/partner/chat';
  static const String partnerChatRead = '/partner/chat/read';

  // Admin Endpoints
  static const String adminDashboard = '/admindashboard';
  static const String adminSellers = '/sellers';
  static const String adminSuppliers = '/suppliers';
  static const String adminSellerStatus = '/admin/sellers'; // + /:id/status
  static const String adminSupplierStatus = '/admin/suppliers'; // + /:id/status
  static const String adminSellerCategories = '/admin/sellers'; // + /:id/categories
  static const String adminSupplierCategories = '/admin/suppliers'; // + /:id/categories
  static const String adminSellerOrders = '/admin/sellerorders';
  static const String adminUpdateSellerOrder = '/admin/sellerorders'; // + /:id
  static const String adminSellerPrices = '/admin/sellerprices'; // + /:productId
  static const String adminPartnerChats = '/admin/partnerchats';
  static const String adminPartnerChatThread = '/admin/partnerchats'; // + /:type/:id
  static const String adminTransferCustomerOrder = '/admin/orders'; // + /:id/supplier
  static const String getProducts = '/getproducts';
}
