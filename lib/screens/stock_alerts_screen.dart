import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../providers/product_provider.dart';
import '../models/inventory_movement_model.dart';
import 'add_edit_product_screen.dart';

class StockAlertsScreen extends StatefulWidget {
  const StockAlertsScreen({super.key});

  @override
  State<StockAlertsScreen> createState() => _StockAlertsScreenState();
}

class _StockAlertsScreenState extends State<StockAlertsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Alerts'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active Alerts', icon: Icon(Icons.warning_amber)),
            Tab(text: 'All Alerts', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActiveAlerts(),
          _buildAllAlerts(),
        ],
      ),
    );
  }

  Widget _buildActiveAlerts() {
    return Consumer<InventoryProvider>(
      builder: (context, provider, child) {
        if (provider.activeAlerts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 80,
                  color: Colors.green[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'No Active Alerts',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'All products are well stocked!',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: provider.activeAlerts.length,
          itemBuilder: (context, index) {
            final alert = provider.activeAlerts[index];
            return _buildAlertCard(alert, isActive: true);
          },
        );
      },
    );
  }

  Widget _buildAllAlerts() {
    return Consumer<InventoryProvider>(
      builder: (context, provider, child) {
        return StreamBuilder<List<StockAlert>>(
          stream: provider.getAllAlerts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_none, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No alerts yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            final alerts = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                final alert = alerts[index];
                return _buildAlertCard(alert, isActive: false);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildAlertCard(StockAlert alert, {required bool isActive}) {
    final bool isCritical = alert.currentStock == 0;
    final Color alertColor =
        isCritical ? Colors.red : (alert.isResolved ? Colors.grey : Colors.orange);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: alert.isResolved ? 1 : 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: alertColor,
            width: alert.isResolved ? 1 : 2,
          ),
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: alertColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isCritical
                  ? Icons.error
                  : (alert.isResolved ? Icons.check_circle : Icons.warning_amber),
              color: alertColor,
              size: 28,
            ),
          ),
          title: Text(
            alert.productName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              decoration: alert.isResolved ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.inventory,
                    size: 16,
                    color: alertColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isCritical
                        ? 'OUT OF STOCK'
                        : 'Stock: ${alert.currentStock} (Threshold: ${alert.threshold})',
                    style: TextStyle(
                      color: alertColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _formatDateTime(alert.alertDate),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              if (alert.isResolved)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'RESOLVED',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          trailing: !alert.isResolved && isActive
              ? PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'restock',
                      child: Row(
                        children: [
                          Icon(Icons.add_circle, size: 20, color: Colors.green),
                          SizedBox(width: 8),
                          Text('Restock Product'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'resolve',
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, size: 20, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Mark as Resolved'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'restock') {
                      _navigateToRestock(alert);
                    } else if (value == 'resolve') {
                      _resolveAlert(alert);
                    }
                  },
                )
              : null,
        ),
      ),
    );
  }

  void _navigateToRestock(StockAlert alert) async {
    final productProvider = context.read<ProductProvider>();
    final product = await productProvider.getProductById(alert.productId);

    if (product != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddEditProductScreen(product: product),
        ),
      );
    }
  }

  void _resolveAlert(StockAlert alert) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resolve Alert'),
        content: Text(
          'Mark this stock alert for "${alert.productName}" as resolved?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Resolve'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = context.read<InventoryProvider>();
      final success = await provider.resolveAlert(alert.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Alert resolved successfully'
                  : 'Failed to resolve alert',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}