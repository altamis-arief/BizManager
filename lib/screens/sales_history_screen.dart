import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sales_provider.dart';
import '../models/sale_transaction_model.dart';
import 'sales_transaction_detail_screen.dart';

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales History'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.filter_list),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('All Sales'),
              ),
              const PopupMenuItem(
                value: 'today',
                child: Text('Today'),
              ),
              const PopupMenuItem(
                value: 'week',
                child: Text('This Week'),
              ),
              const PopupMenuItem(
                value: 'month',
                child: Text('This Month'),
              ),
              const PopupMenuItem(
                value: 'custom',
                child: Text('Custom Date Range'),
              ),
            ],
            onSelected: (value) {
              _handleFilterSelection(value.toString());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_startDate != null && _endDate != null) _buildDateRangeChip(),
          Expanded(child: _buildSalesList()),
        ],
      ),
    );
  }

  Widget _buildDateRangeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Chip(
            label: Text(
              '${_formatDate(_startDate!)} - ${_formatDate(_endDate!)}',
            ),
            onDeleted: () {
              setState(() {
                _startDate = null;
                _endDate = null;
                _selectedFilter = 'all';
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSalesList() {
    return Consumer<SalesProvider>(
      builder: (context, provider, child) {
        Stream<List<SalesTransaction>> salesStream;

        if (_startDate != null && _endDate != null) {
          salesStream = provider.getSalesByDateRange(_startDate!, _endDate!);
        } else if (_selectedFilter == 'today') {
          salesStream = provider.getTodaySales();
        } else {
          salesStream = provider.getSalesByDateRange(
            DateTime.now().subtract(const Duration(days: 365)),
            DateTime.now(),
          );
        }

        return StreamBuilder<List<SalesTransaction>>(
          stream: salesStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No sales transactions found',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }

            final transactions = snapshot.data!;
            
            return Column(
              children: [
                _buildSummaryCard(transactions),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      return _buildTransactionCard(transaction);
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSummaryCard(List<SalesTransaction> transactions) {
    final totalRevenue = transactions.fold<double>(
      0,
      (sum, t) => sum + t.finalAmount,
    );
    final totalTransactions = transactions.length;
    final totalItems = transactions.fold<int>(
      0,
      (sum, t) => sum + t.items.fold<int>(0, (s, i) => s + i.quantity),
    );

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Summary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  'Total Sales',
                  totalTransactions.toString(),
                  Icons.receipt,
                  Colors.blue,
                ),
                _buildSummaryItem(
                  'Items Sold',
                  totalItems.toString(),
                  Icons.shopping_cart,
                  Colors.orange,
                ),
                _buildSummaryItem(
                  'Revenue',
                  'RM ${totalRevenue.toStringAsFixed(2)}',
                  Icons.attach_money,
                  Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionCard(SalesTransaction transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.withOpacity(0.2),
          child: const Icon(Icons.receipt, color: Colors.green),
        ),
        title: Text(
          'Transaction #${transaction.id.substring(0, 8)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${transaction.items.length} item(s) • ${transaction.paymentMethod}',
            ),
            const SizedBox(height: 2),
            Text(
              _formatDateTime(transaction.transactionDate),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'RM ${transaction.finalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.green,
              ),
            ),
            if (transaction.discount > 0)
              Text(
                'Disc: RM ${transaction.discount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.red[700],
                ),
              ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SalesTransactionDetailScreen(
                transaction: transaction,
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleFilterSelection(String value) {
    setState(() {
      _selectedFilter = value;
      
      final now = DateTime.now();
      
      switch (value) {
        case 'today':
          _startDate = DateTime(now.year, now.month, now.day);
          _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
        case 'week':
          _startDate = now.subtract(Duration(days: now.weekday - 1));
          _endDate = now;
          break;
        case 'month':
          _startDate = DateTime(now.year, now.month, 1);
          _endDate = now;
          break;
        case 'custom':
          _showDateRangePicker();
          break;
        default:
          _startDate = null;
          _endDate = null;
      }
    });
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
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}