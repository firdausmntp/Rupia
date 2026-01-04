// lib/features/debt/presentation/widgets/debt_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/debt_model.dart';

class DebtCard extends StatelessWidget {
  final DebtModel debt;
  final VoidCallback onTap;
  final VoidCallback onMarkPaid;

  const DebtCard({
    super.key,
    required this.debt,
    required this.onTap,
    required this.onMarkPaid,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = debt.isOverdue;
    final isPaid = debt.status == DebtStatus.paid;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isOverdue
              ? Colors.red.shade200
              : isPaid
                  ? Colors.green.shade200
                  : AppColors.border.withValues(alpha: 0.2),
          width: isOverdue || isPaid ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getStatusIcon(),
                      color: _getStatusColor(),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Person name & amount
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          debt.personName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyFormatter.format(debt.amount),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusText(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Progress bar (if partial payment)
              if (debt.paidAmount > 0 && debt.status != DebtStatus.paid) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: debt.paidPercentage / 100,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.green,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Dibayar: ${CurrencyFormatter.format(debt.paidAmount)} (${debt.paidPercentage.toStringAsFixed(0)}%)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              // Due date & note
              Row(
                children: [
                  if (debt.dueDate != null) ...[
                    Icon(
                      isOverdue ? Icons.error : Icons.calendar_today,
                      size: 14,
                      color: isOverdue ? Colors.red : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Jatuh tempo: ${DateFormat('dd MMM yyyy').format(debt.dueDate!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isOverdue ? Colors.red : Colors.grey.shade600,
                        fontWeight: isOverdue ? FontWeight.w600 : null,
                      ),
                    ),
                  ] else ...[
                    Icon(
                      Icons.event_available,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Tanpa jatuh tempo',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
              if (debt.note != null && debt.note!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  debt.note!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              // Mark as paid button
              if (debt.status != DebtStatus.paid) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onMarkPaid,
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: const Text('Tandai Lunas'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    if (debt.status == DebtStatus.paid) return Colors.green;
    if (debt.isOverdue) return Colors.red;
    if (debt.status == DebtStatus.partial) return Colors.orange;
    return debt.type == DebtType.iOwe ? Colors.red : Colors.green;
  }

  IconData _getStatusIcon() {
    if (debt.status == DebtStatus.paid) return Icons.check_circle;
    if (debt.isOverdue) return Icons.warning;
    return debt.type == DebtType.iOwe
        ? Icons.arrow_upward
        : Icons.arrow_downward;
  }

  String _getStatusText() {
    if (debt.status == DebtStatus.paid) return 'Lunas';
    if (debt.isOverdue) return 'Terlambat';
    if (debt.status == DebtStatus.partial) return 'Sebagian';
    return 'Belum Lunas';
  }
}
