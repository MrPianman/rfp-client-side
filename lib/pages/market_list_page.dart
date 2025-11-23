import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/market_item.dart';

class MarketListPage extends StatefulWidget {
  final String vehicleId;
  final String driverName;

  const MarketListPage({
    super.key,
    required this.vehicleId,
    required this.driverName,
  });

  @override
  State<MarketListPage> createState() => _MarketListPageState();
}

class _MarketListPageState extends State<MarketListPage> {
  late final List<MarketItem> _items = mockMarketList(widget.vehicleId);
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = _items
        .where(
          (item) => item.name.toLowerCase().contains(_query.toLowerCase()),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${widget.vehicleId} Market List'),
            Text(
              'Driver: ${widget.driverName}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchField(context),
            const SizedBox(height: 16),
            Expanded(
              child: _MarketTable(items: filtered),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search checklist...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      onChanged: (value) => setState(() => _query = value),
    );
  }
}

class _MarketTable extends StatelessWidget {
  final List<MarketItem> items;

  const _MarketTable({required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerStyle = theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          headingRowColor: WidgetStatePropertyAll(theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6)),
          columns: [
            DataColumn(label: Text('No.', style: headerStyle)),
            DataColumn(label: Text('List', style: headerStyle)),
            DataColumn(label: Text('Status', style: headerStyle)),
          ],
          rows: items
              .map(
                (item) => DataRow(
                  cells: [
                    DataCell(Text('${item.number}')),
                    DataCell(Text(item.name)),
                    DataCell(_StatusPill(received: item.received)),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool received;

  const _StatusPill({required this.received});

  @override
  Widget build(BuildContext context) {
    final color = received ? const Color(0xFF34A853) : const Color(0xFFEA4335);
    final text = received ? 'Received' : 'Not Received';
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
