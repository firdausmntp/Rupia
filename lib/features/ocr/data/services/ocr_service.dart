// lib/features/ocr/data/services/ocr_service.dart

import 'dart:io';
import 'dart:ui' as ui;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class OcrService {
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final ImagePicker _imagePicker = ImagePicker();

  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 95, // Higher quality for better OCR
        maxWidth: 2048,
        maxHeight: 2048,
      );
      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      throw OcrException('Failed to capture image: $e');
    }
  }

  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 95, // Higher quality for better OCR
        maxWidth: 2048,
        maxHeight: 2048,
      );
      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      throw OcrException('Failed to pick image: $e');
    }
  }

  Future<OcrResult> recognizeText(File imageFile) async {
    try {
      final InputImage inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      final fullText = recognizedText.text;
      
      // Extract text blocks with bounding boxes for better accuracy
      final textBlocks = _extractTextBlocks(recognizedText.blocks);
      
      // Use improved extraction methods
      final amount = _extractAmountImproved(fullText, textBlocks);
      final date = _extractDateImproved(fullText, textBlocks);
      final merchant = _extractMerchantImproved(recognizedText.blocks, textBlocks);
      final items = _extractLineItems(textBlocks);
      
      return OcrResult(
        fullText: fullText,
        amount: amount,
        date: date,
        merchant: merchant,
        imagePath: imageFile.path,
        confidence: _calculateConfidenceImproved(amount, date, merchant, textBlocks),
        textBlocks: textBlocks,
        lineItems: items,
      );
    } catch (e) {
      throw OcrException('OCR failed: $e');
    }
  }
  
  /// Extract text blocks with position info for better context awareness
  List<OcrTextBlock> _extractTextBlocks(List<TextBlock> blocks) {
    final result = <OcrTextBlock>[];
    
    for (final block in blocks) {
      for (final line in block.lines) {
        result.add(OcrTextBlock(
          text: line.text.trim(),
          boundingBox: line.boundingBox,
          confidence: line.confidence ?? 0.0,
          isNumeric: RegExp(r'^[\d.,\s]+$').hasMatch(line.text.trim()),
        ));
      }
    }
    
    // Sort by vertical position (top to bottom)
    result.sort((a, b) => (a.boundingBox.top).compareTo(b.boundingBox.top));
    
    return result;
  }
  
  /// Improved amount extraction using context and position
  double? _extractAmountImproved(String text, List<OcrTextBlock> blocks) {
    // Priority 1: Look for TOTAL with amount
    final totalPatterns = [
      RegExp(r'(?:TOTAL|Total|GRAND\s*TOTAL|JUMLAH|Jumlah|BAYAR|Bayar)[:\s]*(?:Rp\.?|IDR)?\s*([\d.,]+)', caseSensitive: false),
      RegExp(r'(?:SUB\s*TOTAL|Subtotal)[:\s]*(?:Rp\.?|IDR)?\s*([\d.,]+)', caseSensitive: false),
    ];
    
    for (final pattern in totalPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final amount = _parseAmount(match.group(1)!);
        if (amount != null && amount >= 1000) {
          return amount;
        }
      }
    }
    
    // Priority 2: Find amounts near "TOTAL" keyword using block positions
    for (int i = 0; i < blocks.length; i++) {
      final block = blocks[i];
      final lowerText = block.text.toLowerCase();
      
      if (lowerText.contains('total') || lowerText.contains('bayar') || lowerText.contains('jumlah')) {
        // Check same line or next line for amount
        final amountMatch = RegExp(r'(?:Rp\.?|IDR)?\s*([\d.,]+)').firstMatch(block.text);
        if (amountMatch != null) {
          final amount = _parseAmount(amountMatch.group(1)!);
          if (amount != null && amount >= 1000) return amount;
        }
        
        // Check adjacent blocks
        if (i + 1 < blocks.length) {
          final nextAmount = _parseAmount(blocks[i + 1].text);
          if (nextAmount != null && nextAmount >= 1000) return nextAmount;
        }
      }
    }
    
    // Priority 3: Find largest amount (likely total)
    List<double> amounts = [];
    final amountPattern = RegExp(r'(?:Rp\.?|IDR)?\s*([\d]{1,3}(?:[.,]\d{3})+(?:[.,]\d{2})?|\d{4,})', caseSensitive: false);
    
    for (final match in amountPattern.allMatches(text)) {
      final parsed = _parseAmount(match.group(1)!);
      if (parsed != null && parsed >= 1000) {
        amounts.add(parsed);
      }
    }
    
    if (amounts.isNotEmpty) {
      amounts.sort((a, b) => b.compareTo(a));
      return amounts.first;
    }
    
    return null;
  }

  double? _parseAmount(String amountStr) {
    try {
      String cleaned = amountStr.replaceAll(RegExp(r'[^\d.,]'), '');
      
      if (cleaned.isEmpty) return null;
      
      if (cleaned.contains('.') && cleaned.contains(',')) {
        int dotPos = cleaned.lastIndexOf('.');
        int commaPos = cleaned.lastIndexOf(',');
        
        if (commaPos > dotPos) {
          cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');
        } else {
          cleaned = cleaned.replaceAll(',', '');
        }
      } else if (cleaned.contains('.')) {
        final parts = cleaned.split('.');
        if (parts.last.length == 3) {
          cleaned = cleaned.replaceAll('.', '');
        }
      } else if (cleaned.contains(',')) {
        final parts = cleaned.split(',');
        if (parts.last.length == 3) {
          cleaned = cleaned.replaceAll(',', '');
        } else {
          cleaned = cleaned.replaceAll(',', '.');
        }
      }
      
      return double.tryParse(cleaned);
    } catch (e) {
      return null;
    }
  }

  /// Improved date extraction with more patterns
  DateTime? _extractDateImproved(String text, List<OcrTextBlock> blocks) {
    final patterns = [
      // DD/MM/YYYY or DD-MM-YYYY
      RegExp(r'(\d{1,2})[/\-](\d{1,2})[/\-](\d{4})'),
      // DD/MM/YY or DD-MM-YY
      RegExp(r'(\d{1,2})[/\-](\d{1,2})[/\-](\d{2})'),
      // YYYY/MM/DD or YYYY-MM-DD (ISO format)
      RegExp(r'(\d{4})[/\-](\d{1,2})[/\-](\d{1,2})'),
      // DD MMM YYYY (e.g., 15 Jan 2024)
      RegExp(r'(\d{1,2})\s+(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec|Januari|Februari|Maret|April|Mei|Juni|Juli|Agustus|September|Oktober|November|Desember)\s+(\d{4})', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        try {
          int year, month, day;
          
          // Check if it's month name pattern
          if (match.groupCount >= 3 && _isMonthName(match.group(2))) {
            day = int.parse(match.group(1)!);
            month = _parseMonthName(match.group(2)!);
            year = int.parse(match.group(3)!);
          } else if (match.group(1)!.length == 4) {
            // YYYY-MM-DD format
            year = int.parse(match.group(1)!);
            month = int.parse(match.group(2)!);
            day = int.parse(match.group(3)!);
          } else if (match.group(3)!.length == 4) {
            // DD-MM-YYYY format
            day = int.parse(match.group(1)!);
            month = int.parse(match.group(2)!);
            year = int.parse(match.group(3)!);
          } else {
            // DD-MM-YY format
            day = int.parse(match.group(1)!);
            month = int.parse(match.group(2)!);
            year = 2000 + int.parse(match.group(3)!);
          }
          
          if (month >= 1 && month <= 12 && day >= 1 && day <= 31) {
            final date = DateTime(year, month, day);
            // Validate it's a reasonable date (not too far in past or future)
            final now = DateTime.now();
            if (date.isAfter(now.subtract(const Duration(days: 365 * 2))) && 
                date.isBefore(now.add(const Duration(days: 30)))) {
              return date;
            }
          }
        } catch (e) {
          continue;
        }
      }
    }
    
    return null;
  }
  
  bool _isMonthName(String? text) {
    if (text == null) return false;
    final months = ['jan', 'feb', 'mar', 'apr', 'may', 'mei', 'jun', 'jul', 'aug', 'agu', 'sep', 'oct', 'okt', 'nov', 'dec', 'des'];
    return months.any((m) => text.toLowerCase().startsWith(m));
  }
  
  int _parseMonthName(String monthName) {
    final monthMap = {
      'jan': 1, 'januari': 1,
      'feb': 2, 'februari': 2,
      'mar': 3, 'maret': 3,
      'apr': 4, 'april': 4,
      'may': 5, 'mei': 5,
      'jun': 6, 'juni': 6,
      'jul': 7, 'juli': 7,
      'aug': 8, 'agu': 8, 'agustus': 8,
      'sep': 9, 'september': 9,
      'oct': 10, 'okt': 10, 'oktober': 10,
      'nov': 11, 'november': 11,
      'dec': 12, 'des': 12, 'desember': 12,
    };
    return monthMap[monthName.toLowerCase()] ?? 1;
  }

  /// Improved merchant extraction using top blocks and filtering
  String? _extractMerchantImproved(List<TextBlock> blocks, List<OcrTextBlock> textBlocks) {
    if (blocks.isEmpty) return null;
    
    // Look at top portion of receipt for merchant name
    final topBlocks = textBlocks.where((b) {
      // Consider blocks in top 20% of image
      return b.boundingBox.top < (textBlocks.last.boundingBox.bottom * 0.25);
    }).toList();
    
    for (final block in topBlocks) {
      final text = block.text.trim();
      
      // Skip if it's an address, phone, or just numbers
      if (_isAddress(text)) continue;
      if (_isPhoneNumber(text)) continue;
      if (text.length < 3) continue;
      if (RegExp(r'^[\d\s.,\-]+$').hasMatch(text)) continue;
      if (text.toLowerCase().contains('struk') || text.toLowerCase().contains('receipt')) continue;
      if (text.toLowerCase().contains('tanggal') || text.toLowerCase().contains('date')) continue;
      
      // Good candidate - likely merchant name
      // Clean up and return
      return _cleanMerchantName(text);
    }
    
    // Fallback to original method
    for (int i = 0; i < blocks.length && i < 3; i++) {
      final text = blocks[i].text.trim();
      if (_isAddress(text) || _isPhoneNumber(text)) continue;
      if (text.length < 3) continue;
      if (RegExp(r'^[\d\s.,]+$').hasMatch(text)) continue;
      return _cleanMerchantName(text);
    }
    
    return null;
  }
  
  String _cleanMerchantName(String name) {
    // Remove common prefixes/suffixes
    var cleaned = name
        .replaceAll(RegExp(r'^(PT\.?|CV\.?|UD\.?|TB\.?)\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s*(CABANG|CAB\.?|BRANCH).*$', caseSensitive: false), '')
        .trim();
    
    // Capitalize words
    if (cleaned.toUpperCase() == cleaned) {
      cleaned = cleaned.split(' ').map((word) {
        if (word.isEmpty) return word;
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      }).join(' ');
    }
    
    return cleaned;
  }
  
  /// Extract line items from receipt
  List<OcrLineItem> _extractLineItems(List<OcrTextBlock> blocks) {
    final items = <OcrLineItem>[];
    
    for (final block in blocks) {
      // Look for patterns like "Item name    10.000" or "Item name x2 20.000"
      final itemPattern = RegExp(r'^(.+?)\s+(?:x\s*(\d+)\s+)?(?:Rp\.?\s*)?(\d{1,3}(?:[.,]\d{3})*(?:[.,]\d{2})?)$');
      final match = itemPattern.firstMatch(block.text);
      
      if (match != null) {
        final name = match.group(1)?.trim();
        final qty = int.tryParse(match.group(2) ?? '1') ?? 1;
        final price = _parseAmount(match.group(3)!);
        
        if (name != null && name.isNotEmpty && price != null && price > 0) {
          items.add(OcrLineItem(
            name: name,
            quantity: qty,
            price: price,
          ));
        }
      }
    }
    
    return items;
  }

  bool _isAddress(String text) {
    final addressKeywords = ['jl.', 'jalan', 'rt.', 'rw.', 'no.', 'blok', 'kec.', 'kel.', 'kota', 'kab.', 'kabupaten', 'provinsi'];
    return addressKeywords.any((keyword) => text.toLowerCase().contains(keyword));
  }

  bool _isPhoneNumber(String text) {
    return RegExp(r'^[\d\-\+\(\)\s]{8,}$').hasMatch(text) ||
           RegExp(r'(?:telp|tel|phone|hp|wa|whatsapp)[:\s]*[\d\-\+\(\)\s]{8,}', caseSensitive: false).hasMatch(text);
  }

  double _calculateConfidenceImproved(double? amount, DateTime? date, String? merchant, List<OcrTextBlock> blocks) {
    double score = 0;
    
    // Amount weight: 50%
    if (amount != null && amount >= 1000) {
      score += 0.5;
    } else if (amount != null && amount > 0) {
      score += 0.25;
    }
    
    // Date weight: 25%
    if (date != null) {
      score += 0.25;
    }
    
    // Merchant weight: 15%
    if (merchant != null && merchant.length >= 3) {
      score += 0.15;
    }
    
    // Block quality weight: 10%
    if (blocks.isNotEmpty) {
      final avgConfidence = blocks.map((b) => b.confidence).reduce((a, b) => a + b) / blocks.length;
      score += 0.10 * avgConfidence;
    }
    
    return score.clamp(0.0, 1.0);
  }

  void dispose() {
    _textRecognizer.close();
  }
}

/// Represents a text block with position info
class OcrTextBlock {
  final String text;
  final ui.Rect boundingBox;
  final double confidence;
  final bool isNumeric;
  
  OcrTextBlock({
    required this.text,
    required this.boundingBox,
    required this.confidence,
    required this.isNumeric,
  });
}

/// Represents a line item from receipt
class OcrLineItem {
  final String name;
  final int quantity;
  final double price;
  
  OcrLineItem({
    required this.name,
    required this.quantity,
    required this.price,
  });
  
  double get total => quantity * price;
}

class OcrResult {
  final String fullText;
  final double? amount;
  final DateTime? date;
  final String? merchant;
  final String imagePath;
  final double confidence;
  final List<OcrTextBlock> textBlocks;
  final List<OcrLineItem> lineItems;

  OcrResult({
    required this.fullText,
    this.amount,
    this.date,
    this.merchant,
    required this.imagePath,
    required this.confidence,
    this.textBlocks = const [],
    this.lineItems = const [],
  });

  bool get hasAmount => amount != null && amount! > 0;
  bool get hasDate => date != null;
  bool get hasMerchant => merchant != null && merchant!.isNotEmpty;
  bool get hasLineItems => lineItems.isNotEmpty;
  
  String get confidenceLabel {
    if (confidence >= 0.7) return 'Tinggi';
    if (confidence >= 0.4) return 'Sedang';
    return 'Rendah';
  }
}

class OcrException implements Exception {
  final String message;
  OcrException(this.message);
  
  @override
  String toString() => message;
}
