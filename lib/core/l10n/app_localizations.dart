// lib/core/l10n/app_localizations.dart

import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  
  AppLocalizations(this.locale);
  
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
  
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
  
  static final Map<String, Map<String, String>> _localizedValues = {
    'id': {
      // General
      'app_name': 'RUPIA',
      'app_tagline': 'Kelola Keuangan dengan Cerdas',
      'ok': 'OK',
      'cancel': 'Batal',
      'save': 'Simpan',
      'delete': 'Hapus',
      'edit': 'Ubah',
      'add': 'Tambah',
      'close': 'Tutup',
      'search': 'Cari',
      'loading': 'Memuat...',
      'error': 'Error',
      'success': 'Berhasil',
      'warning': 'Peringatan',
      'confirm': 'Konfirmasi',
      'yes': 'Ya',
      'no': 'Tidak',
      
      // Navigation
      'nav_home': 'Beranda',
      'nav_analytics': 'Analitik',
      'nav_budget': 'Anggaran',
      'nav_settings': 'Pengaturan',
      
      // Home
      'home_balance': 'Saldo',
      'home_income': 'Pemasukan',
      'home_expense': 'Pengeluaran',
      'home_recent_transactions': 'Transaksi Terbaru',
      'home_see_all': 'Lihat Semua',
      'home_no_transactions': 'Belum ada transaksi',
      'home_quick_actions': 'Aksi Cepat',
      
      // Transactions
      'transaction_add': 'Tambah Transaksi',
      'transaction_edit': 'Edit Transaksi',
      'transaction_income': 'Pemasukan',
      'transaction_expense': 'Pengeluaran',
      'transaction_amount': 'Jumlah',
      'transaction_category': 'Kategori',
      'transaction_date': 'Tanggal',
      'transaction_note': 'Catatan',
      'transaction_mood': 'Mood',
      'transaction_saved': 'Transaksi berhasil disimpan',
      'transaction_deleted': 'Transaksi berhasil dihapus',
      
      // Budget
      'budget_title': 'Anggaran',
      'budget_add': 'Tambah Anggaran',
      'budget_edit': 'Edit Anggaran',
      'budget_category': 'Kategori',
      'budget_amount': 'Batas Anggaran',
      'budget_spent': 'Terpakai',
      'budget_remaining': 'Sisa',
      'budget_period': 'Periode',
      'budget_monthly': 'Bulanan',
      'budget_weekly': 'Mingguan',
      'budget_exceeded': 'Anggaran Terlampaui!',
      'budget_warning': 'Anggaran Hampir Habis',
      'budget_on_track': 'Sesuai Rencana',
      
      // Analytics
      'analytics_title': 'Analitik',
      'analytics_overview': 'Ringkasan',
      'analytics_by_category': 'Per Kategori',
      'analytics_by_mood': 'Per Mood',
      'analytics_trend': 'Tren',
      'analytics_this_month': 'Bulan Ini',
      'analytics_last_month': 'Bulan Lalu',
      
      // Mood
      'mood_happy': 'Senang',
      'mood_stress': 'Stres',
      'mood_tired': 'Lelah',
      'mood_bored': 'Bosan',
      'mood_neutral': 'Netral',
      'mood_analytics_title': 'Mood Analytics',
      'mood_insight': 'Insight: Kamu paling boros saat',
      
      // Categories
      'category_food': 'Makanan',
      'category_transport': 'Transportasi',
      'category_shopping': 'Belanja',
      'category_entertainment': 'Hiburan',
      'category_health': 'Kesehatan',
      'category_education': 'Pendidikan',
      'category_bills': 'Tagihan',
      'category_salary': 'Gaji',
      'category_investment': 'Investasi',
      'category_gift': 'Hadiah',
      'category_other': 'Lainnya',
      
      // Settings
      'settings_title': 'Pengaturan',
      'settings_account': 'Akun',
      'settings_profile': 'Profil',
      'settings_language': 'Bahasa',
      'settings_theme': 'Tema',
      'settings_theme_light': 'Terang',
      'settings_theme_dark': 'Gelap',
      'settings_theme_system': 'Ikuti Sistem',
      'settings_notifications': 'Notifikasi',
      'settings_budget_alerts': 'Peringatan Anggaran',
      'settings_sync': 'Sinkronisasi',
      'settings_export': 'Ekspor Data',
      'settings_about': 'Tentang',
      'settings_logout': 'Keluar',
      'settings_delete_account': 'Hapus Akun',
      
      // Auth
      'auth_login': 'Masuk',
      'auth_login_google': 'Masuk dengan Google',
      'auth_skip': 'Lewati (Mode Offline)',
      'auth_logout': 'Keluar',
      'auth_terms': 'Dengan masuk, Anda menyetujui Syarat & Ketentuan dan Kebijakan Privasi',
      
      // Profile
      'profile_title': 'Profil',
      'profile_member_since': 'Member sejak',
      'profile_transactions_count': 'Total Transaksi',
      
      // Debt Tracker
      'debt_title': 'Hutang & Piutang',
      'debt_add': 'Tambah Hutang/Piutang',
      'debt_i_owe': 'Saya Berhutang',
      'debt_owed_to_me': 'Piutang Saya',
      'debt_person_name': 'Nama Orang',
      'debt_amount': 'Jumlah',
      'debt_due_date': 'Jatuh Tempo',
      'debt_note': 'Catatan',
      'debt_status_pending': 'Belum Lunas',
      'debt_status_partial': 'Sebagian',
      'debt_status_paid': 'Lunas',
      'debt_mark_paid': 'Tandai Lunas',
      'debt_reminder': 'Ingatkan',
      'debt_total_owed': 'Total Hutang',
      'debt_total_receivable': 'Total Piutang',
      
      // Export
      'export_title': 'Ekspor Data',
      'export_pdf': 'Ekspor ke PDF',
      'export_excel': 'Ekspor ke Excel',
      'export_range': 'Rentang Waktu',
      'export_all': 'Semua Data',
      'export_this_month': 'Bulan Ini',
      'export_last_month': 'Bulan Lalu',
      'export_custom': 'Kustom',
      'export_success': 'Data berhasil diekspor',
      'export_generating': 'Membuat file...',
      
      // Gamification
      'gamification_title': 'Pencapaian',
      'gamification_points': 'Poin',
      'gamification_level': 'Level',
      'gamification_streak': 'Streak',
      'gamification_badges': 'Lencana',
      'gamification_achievements': 'Prestasi',
      'gamification_daily_bonus': 'Bonus Harian',
      'gamification_claim': 'Klaim',
      'gamification_claimed': 'Sudah Diklaim',
      
      // Achievements
      'achievement_first_transaction': 'Transaksi Pertama',
      'achievement_first_transaction_desc': 'Catat transaksi pertamamu',
      'achievement_budget_master': 'Master Anggaran',
      'achievement_budget_master_desc': 'Patuhi anggaran selama 1 bulan',
      'achievement_saver': 'Penabung Handal',
      'achievement_saver_desc': 'Hemat 20% dari pemasukan',
      'achievement_streak_7': 'Streak 7 Hari',
      'achievement_streak_7_desc': 'Catat transaksi 7 hari berturut-turut',
      'achievement_streak_30': 'Streak 30 Hari',
      'achievement_streak_30_desc': 'Catat transaksi 30 hari berturut-turut',
      'achievement_mood_tracker': 'Pelacak Mood',
      'achievement_mood_tracker_desc': 'Catat mood di 50 transaksi',
      
      // Notifications
      'notif_budget_warning_title': 'Peringatan Anggaran',
      'notif_budget_warning_body': 'Anggaran %s sudah terpakai %s%%',
      'notif_budget_exceeded_title': 'Anggaran Terlampaui!',
      'notif_budget_exceeded_body': 'Anggaran %s sudah melebihi batas',
      'notif_debt_reminder_title': 'Pengingat Hutang',
      'notif_debt_reminder_body': 'Hutang kepada %s jatuh tempo besok',
      'notif_daily_reminder_title': 'Jangan Lupa Catat!',
      'notif_daily_reminder_body': 'Sudah catat pengeluaran hari ini?',
      
      // Widgets
      'widget_balance': 'Saldo',
      'widget_today_expense': 'Pengeluaran Hari Ini',
      'widget_budget_status': 'Status Anggaran',
      
      // Onboarding
      'onboarding_welcome': 'Selamat Datang di RUPIA',
      'onboarding_track': 'Lacak Keuanganmu',
      'onboarding_track_desc': 'Catat pemasukan dan pengeluaran dengan mudah',
      'onboarding_mood': 'Pahami Mood-mu',
      'onboarding_mood_desc': 'Ketahui kapan kamu paling boros',
      'onboarding_budget': 'Kelola Anggaran',
      'onboarding_budget_desc': 'Atur budget dan dapatkan peringatan',
      'onboarding_start': 'Mulai Sekarang',
      'onboarding_skip': 'Lewati',
      'onboarding_next': 'Lanjut',
      
      // Misc
      'today': 'Hari Ini',
      'yesterday': 'Kemarin',
      'this_week': 'Minggu Ini',
      'this_month': 'Bulan Ini',
      'all_time': 'Semua Waktu',
      'no_data': 'Tidak ada data',
      'retry': 'Coba Lagi',
      'offline_mode': 'Mode Offline',
      'sync_now': 'Sinkronkan Sekarang',
      'last_sync': 'Terakhir sync',
      
      // v3.2: Recurring Transactions
      'recurring_title': 'Transaksi Berulang',
      'recurring_add': 'Tambah Transaksi Berulang',
      'recurring_expense': 'Pengeluaran Berulang',
      'recurring_income': 'Pemasukan Berulang',
      'recurring_frequency': 'Frekuensi',
      'recurring_daily': 'Harian',
      'recurring_weekly': 'Mingguan',
      'recurring_biweekly': 'Dua Minggu',
      'recurring_monthly': 'Bulanan',
      'recurring_quarterly': 'Triwulan',
      'recurring_yearly': 'Tahunan',
      'recurring_next_due': 'Jatuh tempo berikutnya',
      'recurring_auto_create': 'Buat Otomatis',
      'recurring_reminder': 'Pengingat',
      'recurring_active': 'Aktif',
      'recurring_inactive': 'Nonaktif',
      'recurring_no_expense': 'Belum ada pengeluaran berulang',
      'recurring_no_income': 'Belum ada pemasukan berulang',
      
      // v3.2: Multi-Currency
      'currency_title': 'Multi-Currency',
      'currency_converter': 'Konversi Mata Uang',
      'currency_primary': 'Mata Uang Utama',
      'currency_secondary': 'Mata Uang Sekunder',
      'currency_exchange_rates': 'Kurs Terkini',
      'currency_from': 'Dari',
      'currency_to': 'Ke',
      'currency_result': 'Hasil',
      'currency_settings': 'Pengaturan Mata Uang',
      'currency_show_multiple': 'Tampilkan Multi-Currency',
      'currency_auto_update': 'Update Kurs Otomatis',
      
      // v3.2: Split Transactions
      'split_title': 'Split Bill',
      'split_add': 'Split Bill Baru',
      'split_active': 'Aktif',
      'split_completed': 'Selesai',
      'split_participants': 'Peserta',
      'split_total': 'Total',
      'split_equal': 'Sama Rata',
      'split_custom': 'Kustom',
      'split_percentage': 'Persentase',
      'split_paid': 'Sudah Bayar',
      'split_unpaid': 'Belum Bayar',
      'split_mark_paid': 'Tandai Lunas',
      'split_share': 'Bagikan',
      'split_collected': 'Terkumpul',
      'split_no_active': 'Belum ada split aktif',
      'split_no_completed': 'Belum ada split yang selesai',
      
      // v3.2: Bill Reminders
      'bills_title': 'Tagihan',
      'bills_add': 'Tambah Tagihan',
      'bills_pending': 'Belum Bayar',
      'bills_overdue': 'Jatuh Tempo',
      'bills_paid': 'Sudah Bayar',
      'bills_due_date': 'Tanggal Jatuh Tempo',
      'bills_is_recurring': 'Tagihan Berulang',
      'bills_reminder': 'Pengingat',
      'bills_reminder_days': 'Ingatkan sebelum',
      'bills_category_electricity': 'Listrik',
      'bills_category_water': 'Air',
      'bills_category_internet': 'Internet',
      'bills_category_phone': 'Telepon',
      'bills_category_rent': 'Sewa',
      'bills_category_insurance': 'Asuransi',
      'bills_category_subscription': 'Langganan',
      'bills_category_tax': 'Pajak',
      'bills_category_credit_card': 'Kartu Kredit',
      'bills_category_loan': 'Cicilan',
      'bills_category_other': 'Lainnya',
      'bills_total_pending': 'Total Belum Bayar',
      'bills_overdue_count': 'Tagihan Jatuh Tempo',
      'bills_due_today': 'Jatuh tempo hari ini',
      'bills_due_tomorrow': 'Besok',
      'bills_due_days': '%d hari lagi',
      'bills_overdue_days': 'Terlambat %d hari',
      
      // v3.2: Theme
      'theme_amoled': 'AMOLED Hitam',
      'theme_amoled_desc': 'Layar hitam pekat untuk OLED',
    },
    'en': {
      // General
      'app_name': 'RUPIA',
      'app_tagline': 'Smart Financial Management',
      'ok': 'OK',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'add': 'Add',
      'close': 'Close',
      'search': 'Search',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'warning': 'Warning',
      'confirm': 'Confirm',
      'yes': 'Yes',
      'no': 'No',
      
      // Navigation
      'nav_home': 'Home',
      'nav_analytics': 'Analytics',
      'nav_budget': 'Budget',
      'nav_settings': 'Settings',
      
      // Home
      'home_balance': 'Balance',
      'home_income': 'Income',
      'home_expense': 'Expense',
      'home_recent_transactions': 'Recent Transactions',
      'home_see_all': 'See All',
      'home_no_transactions': 'No transactions yet',
      'home_quick_actions': 'Quick Actions',
      
      // Transactions
      'transaction_add': 'Add Transaction',
      'transaction_edit': 'Edit Transaction',
      'transaction_income': 'Income',
      'transaction_expense': 'Expense',
      'transaction_amount': 'Amount',
      'transaction_category': 'Category',
      'transaction_date': 'Date',
      'transaction_note': 'Note',
      'transaction_mood': 'Mood',
      'transaction_saved': 'Transaction saved successfully',
      'transaction_deleted': 'Transaction deleted successfully',
      
      // Budget
      'budget_title': 'Budget',
      'budget_add': 'Add Budget',
      'budget_edit': 'Edit Budget',
      'budget_category': 'Category',
      'budget_amount': 'Budget Limit',
      'budget_spent': 'Spent',
      'budget_remaining': 'Remaining',
      'budget_period': 'Period',
      'budget_monthly': 'Monthly',
      'budget_weekly': 'Weekly',
      'budget_exceeded': 'Budget Exceeded!',
      'budget_warning': 'Budget Almost Gone',
      'budget_on_track': 'On Track',
      
      // Analytics
      'analytics_title': 'Analytics',
      'analytics_overview': 'Overview',
      'analytics_by_category': 'By Category',
      'analytics_by_mood': 'By Mood',
      'analytics_trend': 'Trend',
      'analytics_this_month': 'This Month',
      'analytics_last_month': 'Last Month',
      
      // Mood
      'mood_happy': 'Happy',
      'mood_stress': 'Stressed',
      'mood_tired': 'Tired',
      'mood_bored': 'Bored',
      'mood_neutral': 'Neutral',
      'mood_analytics_title': 'Mood Analytics',
      'mood_insight': 'Insight: You spend the most when',
      
      // Categories
      'category_food': 'Food',
      'category_transport': 'Transport',
      'category_shopping': 'Shopping',
      'category_entertainment': 'Entertainment',
      'category_health': 'Health',
      'category_education': 'Education',
      'category_bills': 'Bills',
      'category_salary': 'Salary',
      'category_investment': 'Investment',
      'category_gift': 'Gift',
      'category_other': 'Other',
      
      // Settings
      'settings_title': 'Settings',
      'settings_account': 'Account',
      'settings_profile': 'Profile',
      'settings_language': 'Language',
      'settings_theme': 'Theme',
      'settings_theme_light': 'Light',
      'settings_theme_dark': 'Dark',
      'settings_theme_system': 'Follow System',
      'settings_notifications': 'Notifications',
      'settings_budget_alerts': 'Budget Alerts',
      'settings_sync': 'Sync',
      'settings_export': 'Export Data',
      'settings_about': 'About',
      'settings_logout': 'Logout',
      'settings_delete_account': 'Delete Account',
      
      // Auth
      'auth_login': 'Login',
      'auth_login_google': 'Sign in with Google',
      'auth_skip': 'Skip (Offline Mode)',
      'auth_logout': 'Logout',
      'auth_terms': 'By signing in, you agree to Terms & Conditions and Privacy Policy',
      
      // Profile
      'profile_title': 'Profile',
      'profile_member_since': 'Member since',
      'profile_transactions_count': 'Total Transactions',
      
      // Debt Tracker
      'debt_title': 'Debts & Receivables',
      'debt_add': 'Add Debt/Receivable',
      'debt_i_owe': 'I Owe',
      'debt_owed_to_me': 'Owed to Me',
      'debt_person_name': 'Person Name',
      'debt_amount': 'Amount',
      'debt_due_date': 'Due Date',
      'debt_note': 'Note',
      'debt_status_pending': 'Pending',
      'debt_status_partial': 'Partial',
      'debt_status_paid': 'Paid',
      'debt_mark_paid': 'Mark as Paid',
      'debt_reminder': 'Remind',
      'debt_total_owed': 'Total Owed',
      'debt_total_receivable': 'Total Receivable',
      
      // Export
      'export_title': 'Export Data',
      'export_pdf': 'Export to PDF',
      'export_excel': 'Export to Excel',
      'export_range': 'Date Range',
      'export_all': 'All Data',
      'export_this_month': 'This Month',
      'export_last_month': 'Last Month',
      'export_custom': 'Custom',
      'export_success': 'Data exported successfully',
      'export_generating': 'Generating file...',
      
      // Gamification
      'gamification_title': 'Achievements',
      'gamification_points': 'Points',
      'gamification_level': 'Level',
      'gamification_streak': 'Streak',
      'gamification_badges': 'Badges',
      'gamification_achievements': 'Achievements',
      'gamification_daily_bonus': 'Daily Bonus',
      'gamification_claim': 'Claim',
      'gamification_claimed': 'Claimed',
      
      // Achievements
      'achievement_first_transaction': 'First Transaction',
      'achievement_first_transaction_desc': 'Record your first transaction',
      'achievement_budget_master': 'Budget Master',
      'achievement_budget_master_desc': 'Stay within budget for 1 month',
      'achievement_saver': 'Super Saver',
      'achievement_saver_desc': 'Save 20% of your income',
      'achievement_streak_7': '7 Day Streak',
      'achievement_streak_7_desc': 'Record transactions for 7 consecutive days',
      'achievement_streak_30': '30 Day Streak',
      'achievement_streak_30_desc': 'Record transactions for 30 consecutive days',
      'achievement_mood_tracker': 'Mood Tracker',
      'achievement_mood_tracker_desc': 'Track mood in 50 transactions',
      
      // Notifications
      'notif_budget_warning_title': 'Budget Warning',
      'notif_budget_warning_body': '%s budget is %s%% used',
      'notif_budget_exceeded_title': 'Budget Exceeded!',
      'notif_budget_exceeded_body': '%s budget has exceeded the limit',
      'notif_debt_reminder_title': 'Debt Reminder',
      'notif_debt_reminder_body': 'Debt to %s is due tomorrow',
      'notif_daily_reminder_title': 'Don\'t Forget!',
      'notif_daily_reminder_body': 'Have you recorded today\'s expenses?',
      
      // Widgets
      'widget_balance': 'Balance',
      'widget_today_expense': 'Today\'s Expense',
      'widget_budget_status': 'Budget Status',
      
      // Onboarding
      'onboarding_welcome': 'Welcome to RUPIA',
      'onboarding_track': 'Track Your Finances',
      'onboarding_track_desc': 'Record income and expenses easily',
      'onboarding_mood': 'Understand Your Mood',
      'onboarding_mood_desc': 'Know when you spend the most',
      'onboarding_budget': 'Manage Budget',
      'onboarding_budget_desc': 'Set budget and get alerts',
      'onboarding_start': 'Get Started',
      'onboarding_skip': 'Skip',
      'onboarding_next': 'Next',
      
      // Misc
      'today': 'Today',
      'yesterday': 'Yesterday',
      'this_week': 'This Week',
      'this_month': 'This Month',
      'all_time': 'All Time',
      'no_data': 'No data',
      'retry': 'Retry',
      'offline_mode': 'Offline Mode',
      'sync_now': 'Sync Now',
      'last_sync': 'Last synced',
      
      // v3.2: Recurring Transactions
      'recurring_title': 'Recurring Transactions',
      'recurring_add': 'Add Recurring Transaction',
      'recurring_expense': 'Recurring Expense',
      'recurring_income': 'Recurring Income',
      'recurring_frequency': 'Frequency',
      'recurring_daily': 'Daily',
      'recurring_weekly': 'Weekly',
      'recurring_biweekly': 'Biweekly',
      'recurring_monthly': 'Monthly',
      'recurring_quarterly': 'Quarterly',
      'recurring_yearly': 'Yearly',
      'recurring_next_due': 'Next due date',
      'recurring_auto_create': 'Auto Create',
      'recurring_reminder': 'Reminder',
      'recurring_active': 'Active',
      'recurring_inactive': 'Inactive',
      'recurring_no_expense': 'No recurring expenses yet',
      'recurring_no_income': 'No recurring income yet',
      
      // v3.2: Multi-Currency
      'currency_title': 'Multi-Currency',
      'currency_converter': 'Currency Converter',
      'currency_primary': 'Primary Currency',
      'currency_secondary': 'Secondary Currency',
      'currency_exchange_rates': 'Current Rates',
      'currency_from': 'From',
      'currency_to': 'To',
      'currency_result': 'Result',
      'currency_settings': 'Currency Settings',
      'currency_show_multiple': 'Show Multi-Currency',
      'currency_auto_update': 'Auto Update Rates',
      
      // v3.2: Split Transactions
      'split_title': 'Split Bill',
      'split_add': 'New Split Bill',
      'split_active': 'Active',
      'split_completed': 'Completed',
      'split_participants': 'Participants',
      'split_total': 'Total',
      'split_equal': 'Equal Split',
      'split_custom': 'Custom',
      'split_percentage': 'Percentage',
      'split_paid': 'Paid',
      'split_unpaid': 'Unpaid',
      'split_mark_paid': 'Mark as Paid',
      'split_share': 'Share',
      'split_collected': 'Collected',
      'split_no_active': 'No active splits yet',
      'split_no_completed': 'No completed splits yet',
      
      // v3.2: Bill Reminders
      'bills_title': 'Bills',
      'bills_add': 'Add Bill',
      'bills_pending': 'Pending',
      'bills_overdue': 'Overdue',
      'bills_paid': 'Paid',
      'bills_due_date': 'Due Date',
      'bills_is_recurring': 'Recurring Bill',
      'bills_reminder': 'Reminder',
      'bills_reminder_days': 'Remind before',
      'bills_category_electricity': 'Electricity',
      'bills_category_water': 'Water',
      'bills_category_internet': 'Internet',
      'bills_category_phone': 'Phone',
      'bills_category_rent': 'Rent',
      'bills_category_insurance': 'Insurance',
      'bills_category_subscription': 'Subscription',
      'bills_category_tax': 'Tax',
      'bills_category_credit_card': 'Credit Card',
      'bills_category_loan': 'Loan',
      'bills_category_other': 'Other',
      'bills_total_pending': 'Total Pending',
      'bills_overdue_count': 'Overdue Bills',
      'bills_due_today': 'Due today',
      'bills_due_tomorrow': 'Tomorrow',
      'bills_due_days': '%d days left',
      'bills_overdue_days': '%d days overdue',
      
      // v3.2: Theme
      'theme_amoled': 'AMOLED Black',
      'theme_amoled_desc': 'Pure black for OLED screens',
    },
  };
  
  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
  
  // Shorthand
  String tr(String key) => translate(key);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  
  @override
  bool isSupported(Locale locale) {
    return ['id', 'en'].contains(locale.languageCode);
  }
  
  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }
  
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// Extension untuk kemudahan akses
extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  String tr(String key) => AppLocalizations.of(this).translate(key);
}
