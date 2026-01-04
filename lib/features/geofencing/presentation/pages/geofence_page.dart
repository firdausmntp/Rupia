// lib/features/geofencing/presentation/pages/geofence_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/geofence_model.dart';
import '../providers/geofence_providers.dart';

class GeofencePage extends ConsumerWidget {
  const GeofencePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final geofenceState = ref.watch(geofenceNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengingat Lokasi'),
        actions: [
          Switch(
            value: geofenceState.isEnabled,
            onChanged: (value) {
              ref.read(geofenceNotifierProvider.notifier).setEnabled(value);
            },
          ),
        ],
      ),
      body: geofenceState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(context, ref, geofenceState),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context, ref),
        icon: const Icon(Icons.add_location),
        label: const Text('Tambah Lokasi'),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    GeofenceState state,
  ) {
    if (state.geofences.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Info card
        if (!state.isEnabled)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.orange.shade700),
                const Gap(12),
                Expanded(
                  child: Text(
                    'Aktifkan pengingat lokasi untuk menerima notifikasi saat memasuki area tertentu.',
                    style: TextStyle(color: Colors.orange.shade700),
                  ),
                ),
              ],
            ),
          ),

        // Current location
        if (state.currentPosition != null)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.my_location, color: AppColors.primary),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Lokasi Saat Ini',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${state.currentPosition!.latitude.toStringAsFixed(6)}, ${state.currentPosition!.longitude.toStringAsFixed(6)}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    ref.read(geofenceNotifierProvider.notifier).updateCurrentPosition();
                  },
                ),
              ],
            ),
          ),

        // Geofence list
        ...state.geofences.map((geofence) => _buildGeofenceCard(
          context,
          ref,
          geofence,
        )),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const Gap(16),
          Text(
            'Belum ada lokasi',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Gap(8),
          Text(
            'Tambahkan lokasi untuk menerima\npengingat budget saat berbelanja',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildGeofenceCard(
    BuildContext context,
    WidgetRef ref,
    GeofenceModel geofence,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: geofence.isActive
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.location_on,
                color: geofence.isActive ? AppColors.primary : Colors.grey,
              ),
            ),
            title: Text(
              geofence.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Radius: ${geofence.radius.toInt()}m',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                if (geofence.budgetAmount != null)
                  Text(
                    'Budget: ${CurrencyFormatter.format(geofence.budgetAmount!)}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
            trailing: Switch(
              value: geofence.isActive,
              onChanged: (value) {
                ref.read(geofenceNotifierProvider.notifier)
                    .toggleGeofence(geofence.id, value);
              },
            ),
          ),
          const Divider(height: 1),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _showEditDialog(context, ref, geofence),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit'),
                ),
              ),
              Container(
                width: 1,
                height: 30,
                color: Colors.grey.shade200,
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _showDeleteDialog(context, ref, geofence),
                  icon: Icon(Icons.delete, size: 18, color: Colors.red.shade400),
                  label: Text(
                    'Hapus',
                    style: TextStyle(color: Colors.red.shade400),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final radiusController = TextEditingController(text: '200');
    final budgetController = TextEditingController();
    final state = ref.read(geofenceNotifierProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Lokasi'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lokasi',
                  hintText: 'cth: Mall Grand Indonesia',
                ),
              ),
              const Gap(16),
              TextField(
                controller: radiusController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Radius (meter)',
                  hintText: '200',
                ),
              ),
              const Gap(16),
              TextField(
                controller: budgetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Budget (opsional)',
                  hintText: '500000',
                  prefixText: 'Rp ',
                ),
              ),
              const Gap(16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, size: 16, color: Colors.blue.shade700),
                    const Gap(8),
                    Expanded(
                      child: Text(
                        'Lokasi akan menggunakan posisi Anda saat ini',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isEmpty) return;
              if (state.currentPosition == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tidak dapat mengambil lokasi saat ini'),
                  ),
                );
                return;
              }

              ref.read(geofenceNotifierProvider.notifier).addGeofence(
                name: nameController.text,
                latitude: state.currentPosition!.latitude,
                longitude: state.currentPosition!.longitude,
                radius: double.tryParse(radiusController.text) ?? 200,
                budgetAmount: budgetController.text.isNotEmpty
                    ? double.tryParse(budgetController.text)
                    : null,
              );
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    GeofenceModel geofence,
  ) {
    final nameController = TextEditingController(text: geofence.name);
    final radiusController = TextEditingController(
      text: geofence.radius.toInt().toString(),
    );
    final budgetController = TextEditingController(
      text: geofence.budgetAmount?.toInt().toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Lokasi'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama Lokasi'),
              ),
              const Gap(16),
              TextField(
                controller: radiusController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Radius (meter)'),
              ),
              const Gap(16),
              TextField(
                controller: budgetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Budget (opsional)',
                  prefixText: 'Rp ',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isEmpty) return;

              ref.read(geofenceNotifierProvider.notifier).updateGeofence(
                geofence.copyWith(
                  name: nameController.text,
                  radius: double.tryParse(radiusController.text) ?? 200,
                  budgetAmount: budgetController.text.isNotEmpty
                      ? double.tryParse(budgetController.text)
                      : null,
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    GeofenceModel geofence,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Lokasi'),
        content: Text('Hapus "${geofence.name}" dari daftar lokasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(geofenceNotifierProvider.notifier)
                  .deleteGeofence(geofence.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
