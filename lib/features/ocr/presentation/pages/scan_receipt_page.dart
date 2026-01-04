// lib/features/ocr/presentation/pages/scan_receipt_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/ocr_providers.dart';

class ScanReceiptPage extends ConsumerWidget {
  const ScanReceiptPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ocrState = ref.watch(ocrNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Struk'),
        actions: [
          if (ocrState.result != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.read(ocrNotifierProvider.notifier).reset(),
            ),
        ],
      ),
      body: ocrState.isProcessing
          ? _buildProcessing()
          : ocrState.result != null
              ? _buildResult(context, ref, ocrState)
              : _buildInitial(context, ref),
    );
  }

  Widget _buildInitial(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 100,
            color: AppColors.primary.withValues(alpha: 0.5),
          ),
          const Gap(24),
          Text(
            'Scan Struk Belanja',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(8),
          Text(
            'Foto struk belanja Anda dan biarkan OCR mengekstrak informasi secara otomatis',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const Gap(48),
          
          // Camera button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () => ref.read(ocrNotifierProvider.notifier).captureFromCamera(),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Ambil Foto'),
            ),
          ),
          const Gap(16),
          
          // Gallery button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: () => ref.read(ocrNotifierProvider.notifier).pickFromGallery(),
              icon: const Icon(Icons.photo_library),
              label: const Text('Pilih dari Galeri'),
            ),
          ),
          
          const Gap(32),
          
          // Tips
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.blue.shade700, size: 20),
                    const Gap(8),
                    Text(
                      'Tips untuk hasil terbaik:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
                const Gap(8),
                _buildTip('Pastikan pencahayaan cukup'),
                _buildTip('Hindari bayangan dan pantulan'),
                _buildTip('Posisikan struk datar'),
                _buildTip('Pastikan teks terlihat jelas'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 28, top: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
              shape: BoxShape.circle,
            ),
          ),
          const Gap(8),
          Text(text, style: TextStyle(color: Colors.blue.shade700)),
        ],
      ),
    );
  }

  Widget _buildProcessing() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          Gap(24),
          Text('Memproses gambar...'),
          Gap(8),
          Text(
            'Mengenali teks pada struk',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildResult(BuildContext context, WidgetRef ref, OcrState ocrState) {
    final result = ocrState.result!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image preview
          if (ocrState.selectedImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                ocrState.selectedImage!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          
          const Gap(16),
          
          // Confidence indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _getConfidenceColor(result.confidence).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getConfidenceIcon(result.confidence),
                  size: 16,
                  color: _getConfidenceColor(result.confidence),
                ),
                const Gap(8),
                Text(
                  'Akurasi: ${result.confidenceLabel}',
                  style: TextStyle(
                    color: _getConfidenceColor(result.confidence),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          const Gap(24),
          
          // Extracted data
          Text(
            'Data Terdeteksi',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(16),
          
          // Amount card
          _buildDataCard(
            context,
            'Total Belanja',
            result.hasAmount 
                ? CurrencyFormatter.format(result.amount!)
                : 'Tidak terdeteksi',
            Icons.attach_money,
            result.hasAmount ? AppColors.income : Colors.grey,
          ),
          const Gap(12),
          
          // Date card
          _buildDataCard(
            context,
            'Tanggal',
            result.hasDate 
                ? '${result.date!.day}/${result.date!.month}/${result.date!.year}'
                : 'Tidak terdeteksi',
            Icons.calendar_today,
            result.hasDate ? AppColors.primary : Colors.grey,
          ),
          const Gap(12),
          
          // Merchant card
          _buildDataCard(
            context,
            'Toko/Merchant',
            result.hasMerchant ? result.merchant! : 'Tidak terdeteksi',
            Icons.store,
            result.hasMerchant ? Colors.orange : Colors.grey,
          ),
          
          const Gap(24),
          
          // Full text (expandable)
          ExpansionTile(
            title: const Text('Teks Lengkap'),
            tilePadding: EdgeInsets.zero,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  result.fullText.isEmpty 
                      ? 'Tidak ada teks terdeteksi'
                      : result.fullText,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ],
          ),
          
          const Gap(32),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => ref.read(ocrNotifierProvider.notifier).reset(),
                  child: const Text('Scan Ulang'),
                ),
              ),
              const Gap(16),
              Expanded(
                child: ElevatedButton(
                  onPressed: result.hasAmount 
                      ? () => _useResult(context, ref, result)
                      : null,
                  child: const Text('Gunakan Data'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const Gap(4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.7) return AppColors.income;
    if (confidence >= 0.4) return Colors.orange;
    return Colors.red;
  }

  IconData _getConfidenceIcon(double confidence) {
    if (confidence >= 0.7) return Icons.check_circle;
    if (confidence >= 0.4) return Icons.info;
    return Icons.warning;
  }

  void _useResult(BuildContext context, WidgetRef ref, dynamic result) {
    // Navigate to add transaction with pre-filled data
    context.push('/add-transaction', extra: {
      'amount': result.amount,
      'date': result.date,
      'description': result.merchant,
      'receiptPath': result.imagePath,
    });
    
    // Reset OCR state
    ref.read(ocrNotifierProvider.notifier).reset();
  }
}
