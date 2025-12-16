import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_ui/app_theme.dart';
import '../cubit/coupons_cubit.dart';
import '../cubit/coupons_states.dart';
import '../../domain/entities/coupon_entity.dart';

/// Coupons Management Page
/// Admin page for managing discount coupons (CRUD operations)
class CouponsManagementPage extends StatefulWidget {
  const CouponsManagementPage({super.key});

  @override
  State<CouponsManagementPage> createState() => _CouponsManagementPageState();
}

class _CouponsManagementPageState extends State<CouponsManagementPage> {
  @override
  void initState() {
    super.initState();
    context.read<CouponsCubit>().fetchAllCoupons();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Manage Coupons',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterOptions();
            },
          ),
          if (!AppTheme.isMobile(context))
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // TODO: Search by code
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Search feature coming soon')),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<CouponsCubit>().fetchAllCoupons();
            },
          ),
        ],
      ),
      body: BlocConsumer<CouponsCubit, CouponsState>(
        listener: (context, state) {
          if (state is CouponCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is CouponsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is CouponDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.orange,
              ),
            );
          } else if (state is CouponValidated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: state.isValid ? Colors.green : Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CouponsLoading || state is CouponsInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CouponsEmpty) {
            return _buildEmptyState();
          } else if (state is CouponsLoaded) {
            return _buildCouponsList(state.coupons);
          } else if (state is CouponsError) {
            return _buildErrorState(state.errorMessage);
          }
          return _buildEmptyState();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddCouponDialog();
        },
        backgroundColor: Colors.purple,
        icon: const Icon(Icons.add),
        label: Text(AppTheme.isMobile(context) ? 'Add' : 'Add Coupon'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.confirmation_number_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            'No Coupons Found',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Create your first discount coupon',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              _showAddCouponDialog();
            },
            icon: const Icon(Icons.add),
            label: const Text('Create New Coupon'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponsList(List coupons) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: coupons.length,
      itemBuilder: (context, index) {
        final coupon = coupons[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.purple.withValues(alpha: 0.1),
              child: const Icon(Icons.confirmation_number, color: Colors.purple),
            ),
            title: Text(coupon.code, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(coupon.description),
                const SizedBox(height: 4),
                Text(
                  coupon.type == CouponType.percentage ? '${coupon.discountValue}% off' : '\$${coupon.discountValue} off',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Used: ${coupon.usageCount}${coupon.usageLimit != null ? '/${coupon.usageLimit}' : ''}${coupon.expiresAt != null ? ' • Expires: ${coupon.expiresAt!.toString().split(' ')[0]}' : ''}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (coupon.isValid)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Valid',
                      style: TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  ),
                if (coupon.isExpired)
                  Container(
                    margin: const EdgeInsets.only(left: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Expired',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                if (coupon.isUsageLimitReached && !AppTheme.isMobile(context))
                  Container(
                    margin: const EdgeInsets.only(left: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Limit Reached',
                      style: TextStyle(color: Colors.orange, fontSize: 10),
                    ),
                  ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditCouponDialog(coupon);
                    } else if (value == 'toggle') {
                      context.read<CouponsCubit>().updateCoupon(
                            coupon.copyWith(isActive: !coupon.isActive),
                          );
                    } else if (value == 'validate') {
                      _showValidateCouponDialog(coupon);
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(coupon);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'toggle',
                      child: Row(
                        children: [
                          Icon(
                            coupon.isActive ? Icons.visibility_off : Icons.visibility,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(coupon.isActive ? 'Deactivate' : 'Activate'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'validate',
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, size: 20),
                          SizedBox(width: 8),
                          Text('Validate'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
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
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 100,
            color: Colors.red[300],
          ),
          const SizedBox(height: 20),
          Text(
            'Error',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            error,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              context.read<CouponsCubit>().fetchAllCoupons();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: const Text('All Coupons'),
              onTap: () {
                Navigator.pop(context);
                this.context.read<CouponsCubit>().fetchAllCoupons();
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle),
              title: const Text('Active Coupons'),
              onTap: () {
                Navigator.pop(context);
                this.context.read<CouponsCubit>().fetchActiveCoupons();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCouponDialog() {
    final codeController = TextEditingController();
    final descController = TextEditingController();
    final discountController = TextEditingController();
    final minPurchaseController = TextEditingController();
    final maxDiscountController = TextEditingController();
    final usageLimitController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    CouponType selectedType = CouponType.percentage;
    DateTime? expiresAt;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Coupon'),
          content: SizedBox(
            width: AppTheme.getDialogWidth(context),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: codeController,
                      decoration: const InputDecoration(
                        labelText: 'Coupon Code *',
                        hintText: 'e.g., SUMMER2024',
                        prefixIcon: Icon(Icons.confirmation_number),
                      ),
                      textCapitalization: TextCapitalization.characters,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter coupon code';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descController,
                      decoration: const InputDecoration(
                        labelText: 'Description *',
                        hintText: 'Coupon description',
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<CouponType>(
                      initialValue: selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Discount Type *',
                        prefixIcon: Icon(Icons.discount),
                      ),
                      items: CouponType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(_getCouponTypeLabel(type)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedType = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: discountController,
                      decoration: InputDecoration(
                        labelText: selectedType == CouponType.percentage 
                            ? 'Discount Percentage *' 
                            : 'Discount Amount *',
                        hintText: selectedType == CouponType.percentage ? '0-100' : '0.00',
                        prefixIcon: Icon(
                          selectedType == CouponType.percentage 
                              ? Icons.percent 
                              : Icons.attach_money,
                        ),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter discount value';
                        }
                        final discount = double.tryParse(value);
                        if (discount == null) {
                          return 'Invalid value';
                        }
                        if (selectedType == CouponType.percentage && discount > 100) {
                          return 'Max 100%';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: minPurchaseController,
                            decoration: const InputDecoration(
                              labelText: 'Min Purchase',
                              hintText: '0.00',
                              prefixIcon: Icon(Icons.shopping_cart),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: maxDiscountController,
                            decoration: const InputDecoration(
                              labelText: 'Max Discount',
                              hintText: '0.00',
                              prefixIcon: Icon(Icons.money_off),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: usageLimitController,
                      decoration: const InputDecoration(
                        labelText: 'Usage Limit (Optional)',
                        hintText: 'Unlimited if empty',
                        prefixIcon: Icon(Icons.people),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Expiration Date (Optional)'),
                      subtitle: Text(
                        expiresAt != null 
                            ? expiresAt.toString().split(' ')[0]
                            : 'No expiration',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(const Duration(days: 30)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() => expiresAt = date);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final coupon = CouponEntity(
                    id: '',
                    code: codeController.text.trim().toUpperCase(),
                    description: descController.text.trim(),
                    type: selectedType,
                    discountValue: double.parse(discountController.text.trim()),
                    minPurchaseAmount: minPurchaseController.text.isNotEmpty 
                        ? double.parse(minPurchaseController.text.trim()) 
                        : null,
                    maxDiscountAmount: maxDiscountController.text.isNotEmpty 
                        ? double.parse(maxDiscountController.text.trim()) 
                        : null,
                    usageLimit: usageLimitController.text.isNotEmpty 
                        ? int.parse(usageLimitController.text.trim()) 
                        : null,
                    isActive: true,
                    createdAt: DateTime.now(),
                    expiresAt: expiresAt,
                  );
                  this.context.read<CouponsCubit>().createCoupon(coupon);
                  Navigator.pop(dialogContext);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Add Coupon'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditCouponDialog(CouponEntity coupon) {
    final codeController = TextEditingController(text: coupon.code);
    final descController = TextEditingController(text: coupon.description);
    final discountController = TextEditingController(text: coupon.discountValue.toString());
    final minPurchaseController = TextEditingController(
      text: coupon.minPurchaseAmount?.toString() ?? '',
    );
    final maxDiscountController = TextEditingController(
      text: coupon.maxDiscountAmount?.toString() ?? '',
    );
    final usageLimitController = TextEditingController(
      text: coupon.usageLimit?.toString() ?? '',
    );
    final formKey = GlobalKey<FormState>();
    CouponType selectedType = coupon.type;
    DateTime? expiresAt = coupon.expiresAt;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Coupon'),
          content: SizedBox(
            width: AppTheme.getDialogWidth(context),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: codeController,
                      decoration: const InputDecoration(
                        labelText: 'Coupon Code *',
                        prefixIcon: Icon(Icons.confirmation_number),
                      ),
                      textCapitalization: TextCapitalization.characters,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter coupon code';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descController,
                      decoration: const InputDecoration(
                        labelText: 'Description *',
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<CouponType>(
                      initialValue: selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Discount Type *',
                        prefixIcon: Icon(Icons.discount),
                      ),
                      items: CouponType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(_getCouponTypeLabel(type)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedType = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: discountController,
                      decoration: InputDecoration(
                        labelText: selectedType == CouponType.percentage 
                            ? 'Discount Percentage *' 
                            : 'Discount Amount *',
                        prefixIcon: Icon(
                          selectedType == CouponType.percentage 
                              ? Icons.percent 
                              : Icons.attach_money,
                        ),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter discount value';
                        }
                        final discount = double.tryParse(value);
                        if (discount == null) {
                          return 'Invalid value';
                        }
                        if (selectedType == CouponType.percentage && discount > 100) {
                          return 'Max 100%';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: minPurchaseController,
                            decoration: const InputDecoration(
                              labelText: 'Min Purchase',
                              prefixIcon: Icon(Icons.shopping_cart),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: maxDiscountController,
                            decoration: const InputDecoration(
                              labelText: 'Max Discount',
                              prefixIcon: Icon(Icons.money_off),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: usageLimitController,
                      decoration: const InputDecoration(
                        labelText: 'Usage Limit',
                        prefixIcon: Icon(Icons.people),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Expiration Date'),
                      subtitle: Text(
                        expiresAt != null 
                            ? expiresAt.toString().split(' ')[0]
                            : 'No expiration',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (expiresAt != null)
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => setState(() => expiresAt = null),
                            ),
                          const Icon(Icons.calendar_today),
                        ],
                      ),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: expiresAt ?? DateTime.now().add(const Duration(days: 30)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() => expiresAt = date);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final updatedCoupon = coupon.copyWith(
                    code: codeController.text.trim().toUpperCase(),
                    description: descController.text.trim(),
                    type: selectedType,
                    discountValue: double.parse(discountController.text.trim()),
                    minPurchaseAmount: minPurchaseController.text.isNotEmpty 
                        ? double.parse(minPurchaseController.text.trim()) 
                        : null,
                    maxDiscountAmount: maxDiscountController.text.isNotEmpty 
                        ? double.parse(maxDiscountController.text.trim()) 
                        : null,
                    usageLimit: usageLimitController.text.isNotEmpty 
                        ? int.parse(usageLimitController.text.trim()) 
                        : null,
                    expiresAt: expiresAt,
                  );
                  this.context.read<CouponsCubit>().updateCoupon(updatedCoupon);
                  Navigator.pop(dialogContext);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(CouponEntity coupon) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Coupon'),
        content: Text(
          'Are you sure you want to delete "${coupon.code}"?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CouponsCubit>().deleteCoupon(coupon.id);
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showValidateCouponDialog(CouponEntity coupon) {
    final orderAmountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Validate Coupon'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: orderAmountController,
            decoration: const InputDecoration(
              labelText: 'Order Amount *',
              hintText: '0.00',
              prefixIcon: Icon(Icons.attach_money),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Enter order amount';
              }
              if (double.tryParse(value) == null) {
                return 'Invalid amount';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final orderAmount = double.parse(orderAmountController.text.trim());
                context.read<CouponsCubit>().validateCoupon(coupon.code, orderAmount);
                Navigator.pop(dialogContext);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Validate'),
          ),
        ],
      ),
    );
  }

  String _getCouponTypeLabel(CouponType type) {
    switch (type) {
      case CouponType.percentage:
        return 'Percentage Discount';
      case CouponType.fixed:
        return 'Fixed Amount Discount';
    }
  }
}
