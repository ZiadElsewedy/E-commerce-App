import 'package:flutter/material.dart';
import '../../domain/entities/promo_entity.dart';

/// Promo Card Widget
/// Modern card design for displaying promo items
class PromoCardWidget extends StatelessWidget {
  final PromoEntity promo;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleStatus;

  const PromoCardWidget({
    super.key,
    required this.promo,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getPromoIcon(),
                    size: 24,
                    color: Colors.green.shade700,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Title and Status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        promo.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      _buildStatusBadge(),
                    ],
                  ),
                ),
                
                // Discount Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade400, Colors.green.shade600],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.shade200,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    _getDiscountText(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              promo.description,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            if (promo.imageUrl != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  promo.imageUrl!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 120,
                      color: const Color(0xFFF1F5F9),
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          size: 40,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Type and Priority
            Row(
              children: [
                _buildInfoChip(
                  icon: Icons.local_offer_outlined,
                  label: _getPromoTypeLabel(),
                  color: Colors.purple,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  icon: Icons.star_outline,
                  label: 'Priority: ${promo.priority}',
                  color: Colors.amber,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Date Range
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${_formatDate(promo.startDate)} - ${_formatDate(promo.endDate)}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      foregroundColor: const Color(0xFF10B981),
                      side: const BorderSide(color: Color(0xFF10B981)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onToggleStatus,
                    icon: Icon(
                      promo.isActive ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 18,
                    ),
                    label: Text(promo.isActive ? 'Hide' : 'Show'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      foregroundColor: promo.isActive ? Colors.orange : Colors.green,
                      side: BorderSide(
                        color: promo.isActive ? Colors.orange : Colors.green,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color backgroundColor;
    Color textColor;
    String text;

    if (promo.isCurrentlyActive) {
      backgroundColor = Colors.green.shade50;
      textColor = Colors.green.shade700;
      text = 'Active';
    } else if (promo.isUpcoming) {
      backgroundColor = Colors.blue.shade50;
      textColor = Colors.blue.shade700;
      text = 'Upcoming';
    } else if (promo.isExpired) {
      backgroundColor = Colors.red.shade50;
      textColor = Colors.red.shade700;
      text = 'Expired';
    } else {
      backgroundColor = Colors.grey.shade100;
      textColor = Colors.grey.shade700;
      text = 'Inactive';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPromoIcon() {
    switch (promo.type) {
      case PromoType.percentage:
        return Icons.percent;
      case PromoType.fixed:
        return Icons.attach_money;
      case PromoType.buyOneGetOne:
        return Icons.card_giftcard;
      case PromoType.freeShipping:
        return Icons.local_shipping;
    }
  }

  String _getDiscountText() {
    switch (promo.type) {
      case PromoType.percentage:
        return '${promo.discountValue.toStringAsFixed(0)}% OFF';
      case PromoType.fixed:
        return '\$${promo.discountValue.toStringAsFixed(0)} OFF';
      case PromoType.buyOneGetOne:
        return 'BOGO';
      case PromoType.freeShipping:
        return 'FREE SHIP';
    }
  }

  String _getPromoTypeLabel() {
    switch (promo.type) {
      case PromoType.percentage:
        return 'Percentage';
      case PromoType.fixed:
        return 'Fixed Amount';
      case PromoType.buyOneGetOne:
        return 'Buy One Get One';
      case PromoType.freeShipping:
        return 'Free Shipping';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

