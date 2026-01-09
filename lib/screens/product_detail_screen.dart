import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import 'add_edit_product_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Product _currentProduct;

  @override
  void initState() {
    super.initState();
    _currentProduct = widget.product;
  }

  Future<void> _refreshProduct() async {
    final provider = context.read<ProductProvider>();
    final updated = await provider.getProductById(widget.product.id);
    if (updated != null && mounted) {
      setState(() {
        _currentProduct = updated;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLowStock = _currentProduct.stock <= 10;
    final bool isOutOfStock = _currentProduct.stock == 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditProductScreen(product: _currentProduct),
                ),
              );
              if (result == true) {
                _refreshProduct();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProduct,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              _buildProductImage(),
              
              // Product Information
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name and Category
                    Text(
                      _currentProduct.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Chip(
                      label: Text(_currentProduct.category),
                      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                    ),
                    
                    const SizedBox(height: 16),
                    const Divider(),
                    
                    // Price Section
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      icon: Icons.attach_money,
                      label: 'Price',
                      value: 'RM ${_currentProduct.price.toStringAsFixed(2)}',
                      valueColor: Theme.of(context).colorScheme.primary,
                      isBold: true,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Stock Section with Controls
                    _buildStockSection(isLowStock, isOutOfStock),
                    
                    const SizedBox(height: 16),
                    const Divider(),
                    
                    // Description
                    const SizedBox(height: 16),
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currentProduct.description,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                    
                    const SizedBox(height: 24),
                    const Divider(),
                    
                    // Additional Information
                    const SizedBox(height: 16),
                    Text(
                      'Additional Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      icon: Icons.calendar_today,
                      label: 'Created',
                      value: _formatDate(_currentProduct.createdAt),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      icon: Icons.update,
                      label: 'Last Updated',
                      value: _formatDate(_currentProduct.updatedAt),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      icon: Icons.qr_code,
                      label: 'Product ID',
                      value: _currentProduct.id,
                    ),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return Container(
      width: double.infinity,
      height: 300,
      color: Colors.grey[200],
      child: _currentProduct.imageUrl != null
          ? Image.network(
              _currentProduct.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildPlaceholderImage();
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
            )
          : _buildPlaceholderImage(),
    );
  }

  Widget _buildPlaceholderImage() {
    return Center(
      child: Icon(
        Icons.inventory_2,
        size: 100,
        color: Colors.grey[400],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStockSection(bool isLowStock, bool isOutOfStock) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isOutOfStock
            ? Colors.red[50]
            : isLowStock
                ? Colors.orange[50]
                : Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOutOfStock
              ? Colors.red
              : isLowStock
                  ? Colors.orange
                  : Colors.green,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.inventory,
                    color: isOutOfStock
                        ? Colors.red
                        : isLowStock
                            ? Colors.orange
                            : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Stock Level',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isOutOfStock
                          ? Colors.red
                          : isLowStock
                              ? Colors.orange
                              : Colors.green,
                    ),
                  ),
                ],
              ),
              Text(
                '${_currentProduct.stock} units',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isOutOfStock
                      ? Colors.red
                      : isLowStock
                          ? Colors.orange
                          : Colors.green,
                ),
              ),
            ],
          ),
          if (isLowStock || isOutOfStock) ...[
            const SizedBox(height: 8),
            Text(
              isOutOfStock
                  ? '⚠️ Out of Stock - Restock Immediately!'
                  : '⚠️ Low Stock Alert - Consider Restocking',
              style: TextStyle(
                color: isOutOfStock ? Colors.red : Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _currentProduct.stock > 0
                      ? () => _updateStock(_currentProduct.stock - 1)
                      : null,
                  icon: const Icon(Icons.remove),
                  label: const Text('Decrease'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _updateStock(_currentProduct.stock + 1),
                  icon: const Icon(Icons.add),
                  label: const Text('Increase'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => _showCustomStockDialog(),
            icon: const Icon(Icons.edit),
            label: const Text('Set Custom Stock'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStock(int newStock) async {
    final provider = context.read<ProductProvider>();
    final success = await provider.updateStock(_currentProduct.id, newStock);
    
    if (success && mounted) {
      setState(() {
        _currentProduct = _currentProduct.copyWith(stock: newStock);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stock updated successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update stock'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showCustomStockDialog() {
    final controller = TextEditingController(text: _currentProduct.stock.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Stock Level'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Stock Quantity',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.inventory),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newStock = int.tryParse(controller.text);
              if (newStock != null && newStock >= 0) {
                Navigator.pop(context);
                _updateStock(newStock);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid number'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${_currentProduct.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              final provider = context.read<ProductProvider>();
              final success = await provider.deleteProduct(_currentProduct.id);
              
              if (context.mounted) {
                if (success) {
                  Navigator.pop(context); // Go back to list
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Product deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to delete product'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}