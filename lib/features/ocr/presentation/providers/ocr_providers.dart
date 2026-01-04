// lib/features/ocr/presentation/providers/ocr_providers.dart

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/ocr_service.dart';

// OCR Service Provider
final ocrServiceProvider = Provider<OcrService>((ref) {
  final service = OcrService();
  ref.onDispose(() => service.dispose());
  return service;
});

// OCR State
class OcrState {
  final bool isProcessing;
  final OcrResult? result;
  final String? error;
  final File? selectedImage;

  const OcrState({
    this.isProcessing = false,
    this.result,
    this.error,
    this.selectedImage,
  });

  OcrState copyWith({
    bool? isProcessing,
    OcrResult? result,
    String? error,
    File? selectedImage,
  }) {
    return OcrState(
      isProcessing: isProcessing ?? this.isProcessing,
      result: result ?? this.result,
      error: error,
      selectedImage: selectedImage ?? this.selectedImage,
    );
  }
}

// OCR Notifier
class OcrNotifier extends StateNotifier<OcrState> {
  final OcrService _ocrService;

  OcrNotifier(this._ocrService) : super(const OcrState());

  Future<void> captureFromCamera() async {
    state = state.copyWith(isProcessing: true, error: null);

    try {
      final image = await _ocrService.pickImageFromCamera();
      if (image == null) {
        state = state.copyWith(isProcessing: false);
        return;
      }

      state = state.copyWith(selectedImage: image);
      await _processImage(image);
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: e.toString(),
      );
    }
  }

  Future<void> pickFromGallery() async {
    state = state.copyWith(isProcessing: true, error: null);

    try {
      final image = await _ocrService.pickImageFromGallery();
      if (image == null) {
        state = state.copyWith(isProcessing: false);
        return;
      }

      state = state.copyWith(selectedImage: image);
      await _processImage(image);
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: e.toString(),
      );
    }
  }

  Future<void> _processImage(File image) async {
    try {
      final result = await _ocrService.recognizeText(image);
      state = state.copyWith(
        isProcessing: false,
        result: result,
      );
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: e.toString(),
      );
    }
  }

  void reset() {
    state = const OcrState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// OCR Notifier Provider
final ocrNotifierProvider = StateNotifierProvider<OcrNotifier, OcrState>((ref) {
  final ocrService = ref.watch(ocrServiceProvider);
  return OcrNotifier(ocrService);
});
