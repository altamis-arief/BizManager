import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../models/inventory_movement_model.dart';
import 'inventory_movement_detail_screen.dart';
import 'stock_alerts_screen.dart';

class InventoryTrackingScreen extends StatefulWidget {
  const InventoryTrackingScreen({super.key});

  @override
  State<InventoryTrackingScreen> createState() => _InventoryTrackingScreenState();
}

class _InventoryTrackingScreenState extends State<InventoryTrackingScreen> {
  MovementType? _selectedFilter;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryProvider>().loadMovements();
      context.read<InventoryProvider>().loadActiveAlerts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Tracking'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Consumer<InventoryProvider>(
            builder: (context, provider, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StockAlertsScreen(),
                        ),
                      );
                    },
                  ),
                  if (provider.alertCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '${provider.alertCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          PopupMenuButton(
            icon: const Icon(Icons.filter_list),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('All Movements'),
              ),
              const PopupMenuItem(
                value: MovementType.stockIn,
                child: Text('Stock In'),
              ),
              const PopupMenuItem(
                value: MovementType.stockOut,
                child: Text('Stock Out'),
              ),
              const PopupMenuItem(
                value: MovementType.sale,
                child: Text('Sales'),
              ),
              const PopupMenuItem(
                value: MovementType.return_,
                child: Text('Returns'),
              ),
              const PopupMenuItem(
                value: MovementType.adjustment,
                child: Text('Adjustments'),
              ),
              const PopupMenuItem(
                value: 'date',
                child: Text('Filter by Date'),
              ),
            ],
            onSelected: (value) {
              if (value == 'all') {
                setState(() {
                  _selectedFilter = null;
                  _startDate = null;
                  _endDate = null;
                });
              } else if (value == 'date') {
                _showDateRangePicker();
              } else {
                setState(() {
                  _selectedFilter = value as MovementType;
                  _startDate = null;
                  _endDate = null;
                });
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatsCard(),
          if (_selectedFilter != null || _startDate != null)
            _buildFilterChip(),
          Expanded(
            child: _buildMovementsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Consumer<InventoryProvider>(
      builder: (context, provider, child) {
        return FutureBuilder<Map<String, dynamic>?>(
          future: provider.getMovementStats(
            DateTime.now().subtract(const Duration(days: 30)),
            DateTime.now(),
          ),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox.shrink();
            }

            final stats = snapshot.data!;
            return Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last 30 Days Summary',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            'Total Movements',
                            stats['totalMovements'].toString(),
                            Icons.sync_alt,
                            Colors.blue,
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            'Stock In',
                            stats['stockIn'].toString(),
                            Icons.add_circle,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            'Stock Out',
                            stats['stockOut'].toString(),
                            Icons.remove_circle,
                            Colors.orange,
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            'Sales',
                            stats['sales'].toString(),
                            Icons.shopping_cart,
                            Colors.purple,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip() {
    String filterText = '';
    if (_selectedFilter != null) {
      filterText = 'Filter: ${_getMovementTypeLabel(_selectedFilter!)}';
    } else if (_startDate != null && _endDate != null) {
      filterText = 'Date: ${_formatDate(_startDate!)} - ${_formatDate(_endDate!)}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Chip(
            label: Text(filterText),
            onDeleted: () {
              setState(() {
                _selectedFilter = null;
                _startDate = null;
                _endDate = null;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMovementsList() {
    return Consumer<InventoryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(provider.errorMessage),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.loadMovements(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        List<InventoryMovement> movements = provider.movements;

        // Apply filters
        if (_selectedFilter != null) {
          movements = movements
              .where((m) => m.movementType == _selectedFilter)
              .toList();
        }

        if (_startDate != null && _endDate != null) {
          movements = movements.where((m) {
            return m.movementDate.isAfter(_startDate!) &&
                m.movementDate.isBefore(_endDate!.add(const Duration(days: 1)));
          }).toList();
        }

        if (movements.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No inventory movements found',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: movements.length,
          itemBuilder: (context, index) {
            final movement = movements[index];
            return _buildMovementCard(movement);
          },
        );
      },
    );
  }

  Widget _buildMovementCard(InventoryMovement movement) {
    Color typeColor = _getMovementTypeColor(movement.movementType);
    IconData typeIcon = _getMovementTypeIcon(movement.movementType);
    bool isIncrease = movement.newStock > movement.previousStock;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: typeColor.withOpacity(0.2),
          child: Icon(typeIcon, color: typeColor),
        ),
        title: Text(
          movement.productName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              movement.movementTypeLabel,
              style: TextStyle(
                color: typeColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Text(
                  '${movement.previousStock} → ${movement.newStock}',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 8),
                Icon(
                  isIncrease ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 14,
                  color: isIncrease ? Colors.green : Colors.red,
                ),
                Text(
                  '${isIncrease ? '+' : ''}${movement.quantity}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isIncrease ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              _formatDateTime(movement.movementDate),
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  InventoryMovementDetailScreen(movement: movement),
            ),
          );
        },
      ),
    );
  }

  Color _getMovementTypeColor(MovementType type) {
    switch (type) {
      case MovementType.stockIn:
        return Colors.green;
      case MovementType.stockOut:
        return Colors.orange;
      case MovementType.sale:
        return Colors.purple;
      case MovementType.return_:
        return Colors.blue;
      case MovementType.adjustment:
        return Colors.grey;
    }
  }

  IconData _getMovementTypeIcon(MovementType type) {
    switch (type) {
      case MovementType.stockIn:
        return Icons.add_circle;
      case MovementType.stockOut:
        return Icons.remove_circle;
      case MovementType.sale:
        return Icons.shopping_cart;
      case MovementType.return_:
        return Icons.keyboard_return;
      case MovementType.adjustment:
        return Icons.edit;
    }
  }

  String _getMovementTypeLabel(MovementType type) {
    switch (type) {
      case MovementType.stockIn:
        return 'Stock In';
      case MovementType.stockOut:
        return 'Stock Out';
      case MovementType.sale:
        return 'Sales';
      case MovementType.return_:
        return 'Returns';
      case MovementType.adjustment:
        return 'Adjustments';
    }
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _selectedFilter = null;
      });
    }
  }
}