import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_ui/app_theme.dart';
import '../cubit/promos_cubit.dart';
import '../cubit/promos_states.dart';
import '../../domain/entities/promo_entity.dart';

/// Promos Management Page
/// Admin page for managing promotional offers (CRUD operations)
class PromosManagementPage extends StatefulWidget {
  const PromosManagementPage({super.key});

  @override
  State<PromosManagementPage> createState() => _PromosManagementPageState();
}

class _PromosManagementPageState extends State<PromosManagementPage> {
  @override
  void initState() {
    super.initState();
    context.read<PromosCubit>().fetchAllPromos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Manage Promos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterOptions();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<PromosCubit>().fetchAllPromos();
            },
          ),
        ],
      ),
      body: BlocConsumer<PromosCubit, PromosState>(
        listener: (context, state) {
          if (state is PromoCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is PromosError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is PromoDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.orange,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PromosLoading || state is PromosInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PromosEmpty) {
            return _buildEmptyState();
          } else if (state is PromosLoaded) {
            return _buildPromosList(state.promos);
          } else if (state is PromosError) {
            return _buildErrorState(state.errorMessage);
          }
          return _buildEmptyState();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddPromoDialog();
        },
        backgroundColor: Colors.green,
        icon: const Icon(Icons.add),
        label: Text(AppTheme.isMobile(context) ? 'Add' : 'Add Promo'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_offer_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            'No Promos Found',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Create your first promotional offer',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              _showAddPromoDialog();
            },
            icon: const Icon(Icons.add),
            label: const Text('Create New Promo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromosList(List promos) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: promos.length,
      itemBuilder: (context, index) {
        final promo = promos[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.withValues(alpha: 0.1),
              child: const Icon(Icons.local_offer, color: Colors.green),
            ),
            title: Text(promo.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(promo.description),
                const SizedBox(height: 4),
                Text(
                  promo.type == PromoType.percentage ? '${promo.discountValue}% off' : '\$${promo.discountValue} off',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${promo.startDate.toString().split(' ')[0]} - ${promo.endDate.toString().split(' ')[0]}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (promo.isCurrentlyActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Active',
                      style: TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  ),
                if (promo.isUpcoming && !AppTheme.isMobile(context))
                  Container(
                    margin: const EdgeInsets.only(left: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Upcoming',
                      style: TextStyle(color: Colors.blue, fontSize: 12),
                    ),
                  ),
                if (promo.isExpired)
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
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditPromoDialog(promo);
                    } else if (value == 'toggle') {
                      context.read<PromosCubit>().updatePromo(
                            promo.copyWith(isActive: !promo.isActive),
                          );
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(promo);
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
                            promo.isActive ? Icons.visibility_off : Icons.visibility,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(promo.isActive ? 'Deactivate' : 'Activate'),
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
              context.read<PromosCubit>().fetchAllPromos();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
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
              title: const Text('All Promos'),
              onTap: () {
                Navigator.pop(context);
                this.context.read<PromosCubit>().fetchAllPromos();
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle),
              title: const Text('Active Promos'),
              onTap: () {
                Navigator.pop(context);
                this.context.read<PromosCubit>().fetchActivePromos();
              },
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Current Promos'),
              onTap: () {
                Navigator.pop(context);
                this.context.read<PromosCubit>().fetchCurrentPromos();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPromoDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final discountController = TextEditingController();
    final priorityController = TextEditingController(text: '0');
    final formKey = GlobalKey<FormState>();
    PromoType selectedType = PromoType.percentage;
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 7));

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Promo'),
          content: SizedBox(
            width: AppTheme.getDialogWidth(context),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Promo Title *',
                        hintText: 'e.g., Black Friday Sale',
                        prefixIcon: Icon(Icons.local_offer),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter promo title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descController,
                      decoration: const InputDecoration(
                        labelText: 'Description *',
                        hintText: 'Promo description',
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
                    DropdownButtonFormField<PromoType>(
                      initialValue: selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Discount Type *',
                        prefixIcon: Icon(Icons.discount),
                      ),
                      items: PromoType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(_getPromoTypeLabel(type)),
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
                        labelText: selectedType == PromoType.percentage 
                            ? 'Discount Percentage *' 
                            : 'Discount Amount *',
                        hintText: selectedType == PromoType.percentage ? '0-100' : '0.00',
                        prefixIcon: Icon(
                          selectedType == PromoType.percentage 
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
                        if (selectedType == PromoType.percentage && discount > 100) {
                          return 'Max 100%';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: priorityController,
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                        hintText: '0 (higher = shows first)',
                        prefixIcon: Icon(Icons.star),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Start Date *'),
                      subtitle: Text(startDate.toString().split(' ')[0]),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: startDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() => startDate = date);
                        }
                      },
                    ),
                    ListTile(
                      title: const Text('End Date *'),
                      subtitle: Text(endDate.toString().split(' ')[0]),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: endDate,
                          firstDate: startDate,
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() => endDate = date);
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
                  final promo = PromoEntity(
                    id: '',
                    title: titleController.text.trim(),
                    description: descController.text.trim(),
                    type: selectedType,
                    discountValue: double.parse(discountController.text.trim()),
                    priority: int.tryParse(priorityController.text.trim()) ?? 0,
                    isActive: true,
                    startDate: startDate,
                    endDate: endDate,
                  );
                  this.context.read<PromosCubit>().createPromo(promo);
                  Navigator.pop(dialogContext);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Add Promo'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditPromoDialog(PromoEntity promo) {
    final titleController = TextEditingController(text: promo.title);
    final descController = TextEditingController(text: promo.description);
    final discountController = TextEditingController(text: promo.discountValue.toString());
    final priorityController = TextEditingController(text: promo.priority.toString());
    final formKey = GlobalKey<FormState>();
    PromoType selectedType = promo.type;
    DateTime startDate = promo.startDate;
    DateTime endDate = promo.endDate;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Promo'),
          content: SizedBox(
            width: AppTheme.getDialogWidth(context),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Promo Title *',
                        prefixIcon: Icon(Icons.local_offer),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter promo title';
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
                    DropdownButtonFormField<PromoType>(
                      initialValue: selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Discount Type *',
                        prefixIcon: Icon(Icons.discount),
                      ),
                      items: PromoType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(_getPromoTypeLabel(type)),
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
                        labelText: selectedType == PromoType.percentage 
                            ? 'Discount Percentage *' 
                            : 'Discount Amount *',
                        prefixIcon: Icon(
                          selectedType == PromoType.percentage 
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
                        if (selectedType == PromoType.percentage && discount > 100) {
                          return 'Max 100%';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: priorityController,
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                        prefixIcon: Icon(Icons.star),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Start Date *'),
                      subtitle: Text(startDate.toString().split(' ')[0]),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: startDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() => startDate = date);
                        }
                      },
                    ),
                    ListTile(
                      title: const Text('End Date *'),
                      subtitle: Text(endDate.toString().split(' ')[0]),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: endDate,
                          firstDate: startDate,
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() => endDate = date);
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
                  final updatedPromo = promo.copyWith(
                    title: titleController.text.trim(),
                    description: descController.text.trim(),
                    type: selectedType,
                    discountValue: double.parse(discountController.text.trim()),
                    priority: int.tryParse(priorityController.text.trim()) ?? 0,
                    startDate: startDate,
                    endDate: endDate,
                  );
                  this.context.read<PromosCubit>().updatePromo(updatedPromo);
                  Navigator.pop(dialogContext);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(PromoEntity promo) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Promo'),
        content: Text(
          'Are you sure you want to delete "${promo.title}"?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<PromosCubit>().deletePromo(promo.id);
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

  String _getPromoTypeLabel(PromoType type) {
    switch (type) {
      case PromoType.percentage:
        return 'Percentage Discount';
      case PromoType.fixed:
        return 'Fixed Amount Discount';
      case PromoType.buyOneGetOne:
        return 'Buy One Get One (BOGO)';
      case PromoType.freeShipping:
        return 'Free Shipping';
    }
  }
}

