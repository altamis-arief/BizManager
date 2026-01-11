import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sales_provider.dart';

class SalesReportsScreen extends StatefulWidget {
  const SalesReportsScreen({super.key});

  @override
  State<SalesReportsScreen> createState() => _SalesReportsScreenState();
}

class _SalesReportsScreenState extends State<SalesReportsScreen> {
  String _selectedPeriod = 'today';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _updateDateRange(_selectedPeriod);
  }

  void _updateDateRange(String period) {
    final now = DateTime.now();
    setState(() {
      _selectedPeriod = period;
      switch (period) {
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
        case 'year':
          _startDate = DateTime(now.year, 1, 1);
          _endDate = now;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Reports'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          _buildPeriodSelector(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {});
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatisticsCard(),
                    const SizedBox(height: 16),
                    _buildPaymentMethodsCard(),
                    const SizedBox(height: 16),
                    _buildTopSellingProducts(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Report Period',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPeriodChip('Today', 'today'),
                const SizedBox(width: 8),
                _buildPeriodChip('This Week', 'week'),
                const SizedBox(width: 8),
                _buildPeriodChip('This Month', 'month'),
                const SizedBox(width: 8),
                _buildPeriodChip('This Year', 'year'),
                const SizedBox(width: 8),
                ActionChip(
                  label: const Text('Custom Range'),
                  onPressed: _showDateRangePicker,
                  avatar: const Icon(Icons.calendar_today, size: 18),
                ),
              ],
            ),
          ),
          if (_selectedPeriod == 'custom') ...[
            const SizedBox(height: 8),
            Text(
              '${_formatDate(_startDate)} - ${_formatDate(_endDate)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String label, String value) {
    return ChoiceChip(
      label: Text(label),
      selected: _selectedPeriod == value,
      onSelected: (selected) {
        if (selected) {
          _updateDateRange(value);
        }
      },
    );
  }

// Add this to the _buildStatisticsCard in SalesReportsScreen
Widget _buildStatisticsCard() {
  return Consumer<SalesProvider>(
    builder: (context, provider, child) {
      return FutureBuilder<Map<String, dynamic>?>(
        future: provider.getSalesStats(_startDate, _endDate),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Card(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No data available'),
              ),
            );
          }

          final stats = snapshot.data!;

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.analytics, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Sales Overview',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildStatRow(
                    'Total Revenue',
                    'RM ${(stats['totalRevenue'] as double).toStringAsFixed(2)}',
                    Icons.attach_money,
                    Colors.green,
                  ),
                  const Divider(height: 24),
                  _buildStatRow(
                    'Total Cost',
                    'RM ${(stats['totalCost'] as double).toStringAsFixed(2)}',
                    Icons.money_off,
                    Colors.red,
                  ),
                  const Divider(height: 24),
                  _buildStatRow(
                    'Actual Profit',
                    'RM ${(stats['actualProfit'] as double).toStringAsFixed(2)}',
                    Icons.trending_up,
                    Colors.blue,
                  ),
                  const Divider(height: 24),
                  _buildStatRow(
                    'Profit Margin',
                    '${(stats['profitMargin'] as double).toStringAsFixed(1)}%',
                    Icons.percent,
                    Colors.purple,
                  ),
                  const Divider(height: 24),
                  _buildStatRow(
                    'Total Transactions',
                    '${stats['totalTransactions']}',
                    Icons.receipt,
                    Colors.indigo,
                  ),
                  const Divider(height: 24),
                  _buildStatRow(
                    'Items Sold',
                    '${stats['totalItemsSold']}',
                    Icons.shopping_cart,
                    Colors.orange,
                  ),
                  const Divider(height: 24),
                  _buildStatRow(
                    'Average Sale',
                    'RM ${(stats['averageTransactionValue'] as double).toStringAsFixed(2)}',
                    Icons.analytics,
                    Colors.teal,
                  ),
                  if ((stats['totalDiscount'] as double) > 0) ...[
                    const Divider(height: 24),
                    _buildStatRow(
                      'Total Discounts',
                      'RM ${(stats['totalDiscount'] as double).toStringAsFixed(2)}',
                      Icons.discount,
                      Colors.deepOrange,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

  Widget _buildStatRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
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
    );
  }

  Widget _buildPaymentMethodsCard() {
    return Consumer<SalesProvider>(
      builder: (context, provider, child) {
        return FutureBuilder<Map<String, dynamic>?>(
          future: provider.getSalesStats(_startDate, _endDate),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return const SizedBox.shrink();
            }

            final stats = snapshot.data!;
            final paymentMethods =
                stats['paymentMethods'] as Map<String, int>? ?? {};

            if (paymentMethods.isEmpty) {
              return const SizedBox.shrink();
            }

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.payment, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Payment Methods',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...paymentMethods.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _getPaymentIcon(entry.key),
                                  size: 20,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  entry.key,
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${entry.value}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTopSellingProducts() {
    return Consumer<SalesProvider>(
      builder: (context, provider, child) {
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: provider.getTopSellingProducts(_startDate, _endDate),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Top Selling Products',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('No sales data available'),
                    ],
                  ),
                ),
              );
            }

            final topProducts = snapshot.data!;

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Top Selling Products',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...topProducts.asMap().entries.map((entry) {
                      final index = entry.key;
                      final product = entry.value;
                      return _buildTopProductRow(
                        index + 1,
                        product['productName'],
                        product['quantity'],
                        product['revenue'],
                      );
                    }).toList(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTopProductRow(
    int rank,
    String name,
    int quantity,
    double revenue,
  ) {
    Color rankColor;
    if (rank == 1) {
      rankColor = Colors.amber;
    } else if (rank == 2) {
      rankColor = Colors.grey;
    } else if (rank == 3) {
      rankColor = Colors.brown;
    } else {
      rankColor = Colors.blue;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: rankColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: rankColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: rankColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.shopping_cart,
                        size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '$quantity sold',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.attach_money,
                        size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'RM ${revenue.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPaymentIcon(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return Icons.money;
      case 'card':
        return Icons.credit_card;
      case 'e-wallet':
        return Icons.account_balance_wallet;
      case 'bank transfer':
        return Icons.account_balance;
      default:
        return Icons.payment;
    }
  }

  Future<void> _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );

    if (picked != null) {
      setState(() {
        _selectedPeriod = 'custom';
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}