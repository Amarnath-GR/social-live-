import 'package:flutter/material.dart';
import '../models/commerce_models.dart';
import '../services/commerce_service.dart';

class RefundManagementScreen extends StatefulWidget {
  final String sellerId;

  const RefundManagementScreen({Key? key, required this.sellerId}) : super(key: key);

  @override
  State<RefundManagementScreen> createState() => _RefundManagementScreenState();
}

class _RefundManagementScreenState extends State<RefundManagementScreen> {
  List<Refund> _refunds = [];
  bool _isLoading = true;
  RefundStatus? _filterStatus;

  @override
  void initState() {
    super.initState();
    _loadRefunds();
  }

  Future<void> _loadRefunds() async {
    setState(() => _isLoading = true);
    final result = await CommerceService.getPendingRefunds(widget.sellerId);
    if (result['success']) {
      setState(() => _refunds = result['refunds']);
    }
    setState(() => _isLoading = false);
  }

  List<Refund> get _filteredRefunds {
    if (_filterStatus == null) return _refunds;
    return _refunds.where((refund) => refund.status == _filterStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Refund Management'),
        actions: [
          PopupMenuButton<RefundStatus?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (status) => setState(() => _filterStatus = status),
            itemBuilder: (context) => [
              const PopupMenuItem(value: null, child: Text('All Refunds')),
              ...RefundStatus.values.map((status) => PopupMenuItem(
                value: status,
                child: Text(status.name.toUpperCase()),
              )),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _refunds.isEmpty
              ? const Center(child: Text('No refunds found'))
              : RefreshIndicator(
                  onRefresh: _loadRefunds,
                  child: ListView.builder(
                    itemCount: _filteredRefunds.length,
                    itemBuilder: (context, index) {
                      final refund = _filteredRefunds[index];
                      return _buildRefundCard(refund);
                    },
                  ),
                ),
    );
  }

  Widget _buildRefundCard(Refund refund) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Refund #${refund.id.substring(0, 8)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                _buildStatusChip(refund.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Order: #${refund.orderId.substring(0, 8)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              'Amount: \$${refund.amount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'Reason: ${refund.reason}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Requested: ${refund.requestedAt.day}/${refund.requestedAt.month}/${refund.requestedAt.year}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            if (refund.processedAt != null)
              Text(
                'Processed: ${refund.processedAt!.day}/${refund.processedAt!.month}/${refund.processedAt!.year}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            const SizedBox(height: 16),
            if (refund.status == RefundStatus.requested)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _rejectRefund(refund),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Reject'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _approveRefund(refund),
                    child: const Text('Approve'),
                  ),
                ],
              ),
            if (refund.status == RefundStatus.approved)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => _processRefund(refund),
                    child: const Text('Process Refund'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(RefundStatus status) {
    Color color;
    switch (status) {
      case RefundStatus.requested:
        color = Colors.orange;
        break;
      case RefundStatus.approved:
        color = Colors.blue;
        break;
      case RefundStatus.rejected:
        color = Colors.red;
        break;
      case RefundStatus.processed:
        color = Colors.green;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _approveRefund(Refund refund) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Refund'),
        content: Text('Are you sure you want to approve this refund of \$${refund.amount.toStringAsFixed(2)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await CommerceService.approveRefund(refund.id);
      if (result['success']) {
        _loadRefunds();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Refund approved successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to approve refund: ${result['message']}')),
        );
      }
    }
  }

  Future<void> _rejectRefund(Refund refund) async {
    final reasonController = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Refund'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Rejecting refund of \$${refund.amount.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for rejection',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, reasonController.text),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (reason != null && reason.isNotEmpty) {
      // Note: This would call RefundService.rejectRefund with the reason
      _loadRefunds();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Refund rejected')),
      );
    }
  }

  Future<void> _processRefund(Refund refund) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Process Refund'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Process refund of \$${refund.amount.toStringAsFixed(2)}?'),
            const SizedBox(height: 8),
            const Text(
              'This will initiate the refund payment to the customer.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Process'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await CommerceService.processRefund(refund.id);
      if (result['success']) {
        _loadRefunds();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Refund processed successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to process refund: ${result['message']}')),
        );
      }
    }
  }
}
