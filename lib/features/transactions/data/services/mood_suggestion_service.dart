// lib/features/transactions/data/services/mood_suggestion_service.dart

import '../../../../core/enums/mood_type.dart';
import '../../../../core/enums/category_type.dart';
import '../../../../core/enums/transaction_type.dart';

/// Service untuk memberikan saran mood otomatis berdasarkan kategori transaksi,
/// waktu, dan jumlah transaksi.
class MoodSuggestionService {
  /// Suggest mood berdasarkan kategori, tipe transaksi, waktu, dan jumlah
  static MoodType suggestMood({
    required CategoryType category,
    required TransactionType type,
    required DateTime transactionTime,
    required double amount,
  }) {
    // Get category-based mood
    final categoryBasedMood = _getCategoryBasedMood(category, type);
    
    // Get amount-based mood factor
    final amountBasedMood = _getAmountBasedMood(amount, type);
    
    // Prioritize based on strongest signal
    // 1. Large expenses often indicate stress or necessity
    // 2. Income usually makes people happy
    // 3. Category gives context about the transaction type
    // 4. Time gives context about the day
    
    if (type == TransactionType.income) {
      // Income generally makes people happy
      if (amount >= 1000000) {
        return MoodType.happy; // Big income = very happy
      }
      return amountBasedMood;
    }
    
    // For expenses
    // Urgent/necessity expenses (bills, health) at late hours = stress
    if (_isNecessityCategory(category) && _isLateNight(transactionTime)) {
      return MoodType.stress;
    }
    
    // Entertainment/shopping = usually happy or bored shopping
    if (category == CategoryType.entertainment) {
      return MoodType.happy;
    }
    
    if (category == CategoryType.shopping) {
      // Late night shopping might be boredom-driven
      if (_isLateNight(transactionTime)) {
        return MoodType.bored;
      }
      return MoodType.happy;
    }
    
    // Large unexpected expenses often indicate stress
    if (amount >= 500000 && _isNecessityCategory(category)) {
      return MoodType.stress;
    }
    
    // Use category-based mood as fallback
    return categoryBasedMood;
  }
  
  /// Get mood based on time of day
  static MoodType _getTimeBasedMood(DateTime time) {
    final hour = time.hour;
    
    if (hour >= 6 && hour < 12) {
      // Morning - neutral to happy
      return MoodType.neutral;
    } else if (hour >= 12 && hour < 14) {
      // Lunch time - often happy
      return MoodType.happy;
    } else if (hour >= 14 && hour < 18) {
      // Afternoon - neutral
      return MoodType.neutral;
    } else if (hour >= 18 && hour < 22) {
      // Evening - could be tired
      return MoodType.tired;
    } else {
      // Late night - likely tired or stressed
      return MoodType.tired;
    }
  }
  
  /// Get mood based on category and transaction type
  static MoodType _getCategoryBasedMood(CategoryType category, TransactionType type) {
    if (type == TransactionType.income) {
      switch (category) {
        case CategoryType.salary:
          return MoodType.happy; // Pay day!
        case CategoryType.investment:
          return MoodType.happy; // Investment returns
        case CategoryType.gift:
          return MoodType.happy; // Received gift
        default:
          return MoodType.neutral;
      }
    }
    
    // Expenses
    switch (category) {
      case CategoryType.food:
        return MoodType.neutral; // Normal daily activity
      case CategoryType.transportation:
        return MoodType.neutral; // Routine
      case CategoryType.shopping:
        return MoodType.happy; // Retail therapy
      case CategoryType.entertainment:
        return MoodType.happy; // Fun activities
      case CategoryType.bills:
        return MoodType.stress; // Bills are stressful
      case CategoryType.health:
        return MoodType.stress; // Health expenses often stressful
      case CategoryType.education:
        return MoodType.neutral; // Investment in self
      case CategoryType.other:
        return MoodType.neutral;
      default:
        return MoodType.neutral;
    }
  }
  
  /// Get mood based on amount
  static MoodType _getAmountBasedMood(double amount, TransactionType type) {
    if (type == TransactionType.income) {
      if (amount >= 5000000) {
        return MoodType.happy; // Big income!
      } else if (amount >= 1000000) {
        return MoodType.happy;
      }
      return MoodType.neutral;
    }
    
    // For expenses
    if (amount >= 1000000) {
      return MoodType.stress; // Large expense
    } else if (amount >= 500000) {
      return MoodType.neutral;
    } else if (amount >= 100000) {
      return MoodType.neutral;
    }
    return MoodType.neutral; // Small expenses are fine
  }
  
  /// Check if category is a necessity (bills, health)
  static bool _isNecessityCategory(CategoryType category) {
    return category == CategoryType.bills ||
           category == CategoryType.health ||
           category == CategoryType.transportation;
  }
  
  /// Check if time is late night (10 PM - 6 AM)
  static bool _isLateNight(DateTime time) {
    final hour = time.hour;
    return hour >= 22 || hour < 6;
  }
  
  /// Get mood explanation for UI display
  static String getMoodExplanation(MoodType mood, CategoryType category, TransactionType type) {
    if (type == TransactionType.income) {
      return 'Pemasukan biasanya membawa kebahagiaan 💰';
    }
    
    switch (mood) {
      case MoodType.happy:
        if (category == CategoryType.entertainment) {
          return 'Aktivitas hiburan membawa kesenangan 🎉';
        } else if (category == CategoryType.shopping) {
          return 'Belanja bisa menjadi terapi 🛍️';
        }
        return 'Transaksi yang menyenangkan ✨';
      
      case MoodType.stress:
        if (category == CategoryType.bills) {
          return 'Tagihan terkadang membuat stress 😅';
        } else if (category == CategoryType.health) {
          return 'Pengeluaran kesehatan bisa membuat khawatir 🏥';
        }
        return 'Pengeluaran besar bisa membuat stress 💸';
      
      case MoodType.tired:
        return 'Waktu sudah malam, istirahat yang cukup ya 🌙';
      
      case MoodType.bored:
        return 'Belanja malam mungkin karena bosan 🛒';
      
      case MoodType.neutral:
        return 'Transaksi rutin sehari-hari 📝';
    }
  }
  
  /// Get all moods with their suggestion scores for current context
  static Map<MoodType, double> getMoodScores({
    required CategoryType category,
    required TransactionType type,
    required DateTime transactionTime,
    required double amount,
  }) {
    final scores = <MoodType, double>{};
    
    for (final mood in MoodType.values) {
      scores[mood] = _calculateMoodScore(
        mood: mood,
        category: category,
        type: type,
        time: transactionTime,
        amount: amount,
      );
    }
    
    return scores;
  }
  
  /// Calculate score for a specific mood
  static double _calculateMoodScore({
    required MoodType mood,
    required CategoryType category,
    required TransactionType type,
    required DateTime time,
    required double amount,
  }) {
    double score = 0.2; // Base score
    
    // Category alignment
    final categoryMood = _getCategoryBasedMood(category, type);
    if (categoryMood == mood) score += 0.4;
    
    // Time alignment
    final timeMood = _getTimeBasedMood(time);
    if (timeMood == mood) score += 0.2;
    
    // Amount alignment
    final amountMood = _getAmountBasedMood(amount, type);
    if (amountMood == mood) score += 0.2;
    
    return score.clamp(0.0, 1.0);
  }
}
