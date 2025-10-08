import 'package:flutter/material.dart';
import 'package:pagination_dropdown_list/pagination_dropdown_list.dart';

void main() {
  runApp(MyApp());
}

// Real-world data models
class Product {
  final int id;
  final String name;
  final String category;
  final double price;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      price: json['price'].toDouble(),
    );
  }

  @override
  String toString() => name;
}

class Customer {
  final int id;
  final String name;
  final String email;
  final String city;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.city,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      city: json['city'],
    );
  }

  @override
  String toString() => '$name ($city)';
}

class Order {
  final int id;
  final String orderNumber;
  final String status;
  final double total;

  Order({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.total,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      orderNumber: json['orderNumber'],
      status: json['status'],
      total: json['total'].toDouble(),
    );
  }

  @override
  String toString() => 'Order #$orderNumber - \$$total';
}

// Mock API Services
class ProductService {
  Future<List<dynamic>> getProducts(int page, int pageSize) async {
    await Future.delayed(Duration(seconds: 1));
    return List.generate(pageSize, (index) {
      int productId = (page - 1) * pageSize + index + 1;
      return Product(
        id: productId,
        name: 'Product ${String.fromCharCode(65 + productId % 26)}$productId',
        category: [
          'Electronics',
          'Clothing',
          'Books',
          'Home',
          'Sports',
        ][productId % 5],
        price: (productId * 10.0 + productId % 3 * 5.0),
      );
    });
  }
}

class CustomerService {
  Future<List<dynamic>> getCustomers(int page, int pageSize) async {
    await Future.delayed(Duration(seconds: 1));
    return List.generate(pageSize, (index) {
      int customerId = (page - 1) * pageSize + index + 1;
      return Customer(
        id: customerId,
        name: 'Customer ${String.fromCharCode(65 + customerId % 26)}',
        email: 'customer$customerId@example.com',
        city: [
          'New York',
          'London',
          'Tokyo',
          'Paris',
          'Sydney',
        ][customerId % 5],
      );
    });
  }
}

class ArabicCustomerService {
  Future<List<dynamic>> getArabicCustomers(int page, int pageSize) async {
    await Future.delayed(Duration(seconds: 1));
    return List.generate(pageSize, (index) {
      int customerId = (page - 1) * pageSize + index + 1;
      return Customer(
        id: customerId,
        name:
            'عميل ${String.fromCharCode(1570 + customerId % 28)}', // Arabic letters
        email: 'عميل$customerId@example.com',
        city: [
          'الرياض',
          'جدة',
          'دبي',
          'القاهرة',
          'الدار البيضاء',
        ][customerId % 5],
      );
    });
  }
}

class OrderService {
  Future<List<dynamic>> getOrders(int page, int pageSize) async {
    await Future.delayed(Duration(seconds: 1));
    return List.generate(pageSize, (index) {
      int orderId = (page - 1) * pageSize + index + 1;
      return Order(
        id: orderId,
        orderNumber: 'ORD${1000 + orderId}',
        status: ['Pending', 'Shipped', 'Delivered', 'Cancelled'][orderId % 4],
        total: (orderId * 25.0 + orderId % 7 * 10.0),
      );
    });
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pagination Dropdown Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: ECommerceDashboard(),
    );
  }
}

class ECommerceDashboard extends StatefulWidget {
  const ECommerceDashboard({super.key});

  @override
  State<ECommerceDashboard> createState() => _ECommerceDashboardState();
}

class _ECommerceDashboardState extends State<ECommerceDashboard> {
  dynamic selectedProduct;
  dynamic selectedCustomer;
  dynamic selectedArabicCustomer;
  dynamic selectedOrder;
  List<dynamic> selectedProducts = [];

  // Create service instances
  final ProductService _productService = ProductService();
  final CustomerService _customerService = CustomerService();
  final ArabicCustomerService _arabicCustomerService = ArabicCustomerService();
  final OrderService _orderService = OrderService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('E-Commerce Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with explanation
            _buildExplanationCard(),
            SizedBox(height: 24),

            // Product Selection
            _buildSectionHeader(
              title: '1. Product Catalog',
              subtitle: 'Browse through paginated product list',
            ),
            PaginationDropdownList(
              textTitle: 'Select Product',
              hintText: 'Search products...',
              initialItem: selectedProduct,
              onChanged: (product) {
                setState(() {
                  selectedProduct = product;
                });
              },
              itemParser: (product) =>
                  '${(product as Product).name} - \$${product.price}',
              fetchItems: (page, pageSize) async =>
                  await _productService.getProducts(page, pageSize),
            ),
            if (selectedProduct != null)
              _buildSelectedItemInfo(selectedProduct),
            SizedBox(height: 24),

            // Customer Database Section - Two dropdowns side by side
            _buildSectionHeader(
              title: '2. Customer Database',
              subtitle: 'International customer selection - LTR & RTL support',
            ),
            SizedBox(
              height: 130, //  Fixed height to contain both dropdowns
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // English/LTR Customer Dropdown
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'English Customers (LTR)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        SizedBox(height: 8),
                        Expanded(
                          child: PaginationDropdownList(
                            textTitle: 'Select Customer',
                            hintText: 'Search customers...',
                            initialItem: selectedCustomer,
                            onChanged: (customer) {
                              setState(() {
                                selectedCustomer = customer;
                              });
                            },
                            itemParser: (customer) =>
                                '${(customer as Customer).name} - ${customer.city}',
                            fetchItems: (page, pageSize) async =>
                                await _customerService.getCustomers(
                                  page,
                                  pageSize,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  // Arabic/RTL Customer Dropdown
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: Text(
                            'العملاء العرب (RTL)',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Expanded(
                          child: Directionality(
                            textDirection: TextDirection.rtl,
                            child: PaginationDropdownList(
                              textTitle: 'اختر عميل',
                              hintText: 'ابحث في العملاء...',
                              initialItem: selectedArabicCustomer,
                              onChanged: (customer) {
                                setState(() {
                                  selectedArabicCustomer = customer;
                                });
                              },
                              itemParser: (customer) =>
                                  '${(customer as Customer).name} - ${customer.city}',
                              fetchItems: (page, pageSize) async =>
                                  await _arabicCustomerService
                                      .getArabicCustomers(page, pageSize),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Selected customer info
            if (selectedCustomer != null || selectedArabicCustomer != null) ...[
              SizedBox(height: 12),
              if (selectedCustomer != null)
                _buildSelectedItemInfo(selectedCustomer),
              if (selectedArabicCustomer != null)
                _buildSelectedItemInfo(selectedArabicCustomer),
            ],

            // Order History
            _buildSectionHeader(
              title: '3. Order History',
              subtitle: 'Scroll to load more orders automatically',
            ),
            PaginationDropdownList(
              textTitle: 'Select Order',
              hintText: 'Search orders...',
              initialItem: selectedOrder,
              onChanged: (order) {
                setState(() {
                  selectedOrder = order;
                });
              },
              itemParser: (order) =>
                  '${(order as Order).orderNumber} - \$${order.total} - ${order.status}',
              fetchItems: (page, pageSize) async =>
                  await _orderService.getOrders(page, pageSize),
            ),
            if (selectedOrder != null) _buildSelectedItemInfo(selectedOrder),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanationCard() {
    return Card(
      elevation: 2,
      color: Colors.blue.shade50,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                SizedBox(width: 8),
                Text(
                  'PaginationDropdownList Demo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'This demo shows how PaginationDropdownList can be used in real-world scenarios:',
              style: TextStyle(color: Colors.blue.shade800),
            ),
            SizedBox(height: 8),
            _buildFeatureBullet('Large datasets loaded efficiently'),
            _buildFeatureBullet('Search and pagination combined'),
            _buildFeatureBullet('Custom item display and parsing'),
            _buildFeatureBullet('Multiple dropdown instances'),
            _buildFeatureBullet('RTL (Right-to-Left) language support'),
            _buildFeatureBullet('Side-by-side layout for comparison'),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureBullet(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: Colors.blue.shade700)),
          Expanded(
            child: Text(text, style: TextStyle(color: Colors.blue.shade800)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        SizedBox(height: 12),
      ],
    );
  }

  Widget _buildSelectedItemInfo(dynamic item) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              _getItemDetails(item),
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }

  String _getItemDetails(dynamic item) {
    if (item is Product) {
      return 'Selected: ${item.name} | Category: ${item.category} | Price: \$${item.price}';
    } else if (item is Customer) {
      return 'Selected: ${item.name} | Email: ${item.email} | City: ${item.city}';
    } else if (item is Order) {
      return 'Selected: ${item.orderNumber} | Status: ${item.status} | Total: \$${item.total}';
    }
    return 'Selected item';
  }
}
