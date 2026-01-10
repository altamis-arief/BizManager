import 'package:flutter/material.dart';
import '../models/inventory_movement_model.dart';

class InventoryMovementDetailScreen extends StatelessWidget {
  final InventoryMovement movement;

  const InventoryMovementDetailScreen({super.key, required this.movement});

  @override
  Widget build(BuildContext context) {
    final bool isIncrease = movement.newStock > movement.previousStock;
    final Color typeColor = _getMovementTypeColor(movement.movementType);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Movement Details'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Movement Type Card
            Card(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      typeColor.withOpacity(0.2),
                      typeColor.withOpacity(0.1),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _getMovementTypeIcon(movement.movementType),
                      size: 64,
                      color: typeColor,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      movement.movementTypeLabel,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: typeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Product Information
            Text(
              'Product Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow(
                      icon: Icons.inventory_2,
                      label: 'Product Name',
                      value: movement.productName,
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      icon: Icons.qr_code,
                      label: 'Product ID',
                      value: movement.productId,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Stock Changes
            Text(
              'Stock Changes',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStockIndicator(
                          'Previous Stock',
                          movement.previousStock.toString(),
                          Colors.grey,
                        ),
                        Icon(
                          isIncrease ? Icons.arrow_forward : Icons.arrow_back,
                          color: isIncrease ? Colors.green : Colors.red,
                          size: 32,
                        ),
                        _buildStockIndicator(
                          'New Stock',
                          movement.newStock.toString(),
                          isIncrease ? Colors.green : Colors.red,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (isIncrease ? Colors.green : Colors.red)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isIncrease ? Icons.add_circle : Icons.remove_circle,
                            color: isIncrease ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${isIncrease ? '+' : ''}${movement.quantity} units',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isIncrease ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Additional Details
            Text(
              'Additional Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow(
                      icon: Icons.calendar_today,
                      label: 'Movement Date',
                      value: _formatDateTime(movement.movementDate),
                    ),
                    if (movement.referenceId != null) ...[
                      const Divider(height: 24),
                      _buildInfoRow(
                        icon: Icons.link,
                        label: 'Reference ID',
                        value: movement.referenceId!,
                      ),
                    ],
                    if (movement.notes != null && movement.notes!.isNotEmpty) ...[
                      const Divider(height: 24),
                      _buildInfoRow(
                        icon: Icons.notes,
                        label: 'Notes',
                        value: movement.notes!,
                      ),
                    ],
                    const Divider(height: 24),
                    _buildInfoRow(
                      icon: Icons.person,
                      label: 'User ID',
                      value: movement.userId,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildStockIndicator(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color, width: 2),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
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

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}