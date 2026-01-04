import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../constants/app_constants.dart';

class DatabaseService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initialize();
    return _database!;
  }

  static Database get instance {
    if (_database == null) {
      throw Exception('Database not initialized. Call initialize() first.');
    }
    return _database!;
  }

  static Future<Database> initialize() async {
    if (_database != null) return _database!;

    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, '${AppConstants.dbName}.db');

    _database = await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    
    return _database!;
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Create transactions table
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        description TEXT NOT NULL,
        date INTEGER NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        mood TEXT,
        note TEXT,
        receiptImagePath TEXT,
        isSynced INTEGER DEFAULT 0,
        syncedAt INTEGER,
        userId TEXT,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER
      )
    ''');

    // Create categories table
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        colorValue INTEGER NOT NULL,
        isIncome INTEGER NOT NULL,
        isCustom INTEGER DEFAULT 0,
        isActive INTEGER DEFAULT 1,
        userId TEXT,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER
      )
    ''');

    // Create budgets table
    await db.execute('''
      CREATE TABLE budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        amount REAL NOT NULL,
        spent REAL DEFAULT 0,
        month INTEGER NOT NULL,
        year INTEGER NOT NULL,
        categoryName TEXT,
        userId TEXT,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER
      )
    ''');

    // Create geofences table
    await db.execute('''
      CREATE TABLE geofences (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        radius REAL NOT NULL,
        budgetAmount REAL,
        category TEXT,
        isActive INTEGER DEFAULT 1,
        userId TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT
      )
    ''');

    // Create indexes for better query performance
    await db.execute(
        'CREATE INDEX idx_transactions_date ON transactions(date DESC)');
    await db.execute(
        'CREATE INDEX idx_transactions_type ON transactions(type)');
    await db.execute(
        'CREATE INDEX idx_transactions_category ON transactions(category)');
    await db.execute(
        'CREATE INDEX idx_budgets_month_year ON budgets(month, year)');
    await db.execute(
        'CREATE INDEX idx_geofences_active ON geofences(isActive)');

    // v2: Create debts table
    await db.execute('''
      CREATE TABLE debts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        paid_amount REAL DEFAULT 0,
        status TEXT NOT NULL,
        due_date TEXT,
        description TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');

    // v3: Create custom_categories table
    await db.execute('''
      CREATE TABLE custom_categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon_name TEXT NOT NULL,
        color_hex TEXT NOT NULL,
        type TEXT NOT NULL,
        is_default INTEGER DEFAULT 0,
        sort_order INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');

    // Insert default categories
    await _insertDefaultCategories(db);

    // v4: Create recurring_transactions table
    await db.execute('''
      CREATE TABLE recurring_transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        recurrence TEXT NOT NULL,
        start_date TEXT NOT NULL,
        next_due_date TEXT,
        end_date TEXT,
        is_active INTEGER DEFAULT 1,
        auto_create INTEGER DEFAULT 1,
        reminder_days_before INTEGER,
        last_created_date TEXT,
        note TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');

    // v4: Create currency_preferences table
    await db.execute('''
      CREATE TABLE currency_preferences (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        primary_currency TEXT NOT NULL DEFAULT 'IDR',
        secondary_currencies TEXT,
        show_in_multiple_currencies INTEGER DEFAULT 0,
        auto_update_rates INTEGER DEFAULT 1,
        last_rate_update TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');

    // v4: Create exchange_rates table
    await db.execute('''
      CREATE TABLE exchange_rates (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        from_currency TEXT NOT NULL,
        to_currency TEXT NOT NULL,
        rate REAL NOT NULL,
        source TEXT,
        fetched_at TEXT NOT NULL
      )
    ''');

    // v4: Create split_transactions table
    await db.execute('''
      CREATE TABLE split_transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        total_amount REAL NOT NULL,
        split_type TEXT NOT NULL,
        note TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');

    // v4: Create split_items table
    await db.execute('''
      CREATE TABLE split_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        split_transaction_id INTEGER NOT NULL,
        participant_name TEXT NOT NULL,
        amount REAL NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        paid_at TEXT,
        FOREIGN KEY (split_transaction_id) REFERENCES split_transactions(id) ON DELETE CASCADE
      )
    ''');

    // v4: Create bills table
    await db.execute('''
      CREATE TABLE bills (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        due_date TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        is_recurring INTEGER DEFAULT 0,
        recurrence TEXT,
        reminder_enabled INTEGER DEFAULT 1,
        reminder_days_before INTEGER DEFAULT 3,
        paid_at TEXT,
        note TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');

    // Create indexes for new tables
    await db.execute('CREATE INDEX idx_recurring_active ON recurring_transactions(is_active)');
    await db.execute('CREATE INDEX idx_recurring_next_due ON recurring_transactions(next_due_date)');
    await db.execute('CREATE INDEX idx_bills_status ON bills(status)');
    await db.execute('CREATE INDEX idx_bills_due_date ON bills(due_date)');
    await db.execute('CREATE INDEX idx_split_items_split_id ON split_items(split_transaction_id)');
  }

  static Future<void> _insertDefaultCategories(Database db) async {
    final defaultCategories = [
      // Expense categories
      {'name': 'Makanan & Minuman', 'icon_name': 'restaurant', 'color_hex': 'FF9800', 'type': 'expense', 'is_default': 1, 'sort_order': 1},
      {'name': 'Transport', 'icon_name': 'directions_car', 'color_hex': '2196F3', 'type': 'expense', 'is_default': 1, 'sort_order': 2},
      {'name': 'Belanja', 'icon_name': 'shopping_cart', 'color_hex': '9C27B0', 'type': 'expense', 'is_default': 1, 'sort_order': 3},
      {'name': 'Hiburan', 'icon_name': 'movie', 'color_hex': 'E91E63', 'type': 'expense', 'is_default': 1, 'sort_order': 4},
      {'name': 'Tagihan', 'icon_name': 'receipt', 'color_hex': 'F44336', 'type': 'expense', 'is_default': 1, 'sort_order': 5},
      {'name': 'Kesehatan', 'icon_name': 'medical_services', 'color_hex': '4CAF50', 'type': 'expense', 'is_default': 1, 'sort_order': 6},
      {'name': 'Pendidikan', 'icon_name': 'school', 'color_hex': '3F51B5', 'type': 'expense', 'is_default': 1, 'sort_order': 7},
      {'name': 'Lainnya', 'icon_name': 'more_horiz', 'color_hex': '607D8B', 'type': 'expense', 'is_default': 1, 'sort_order': 99},
      
      // Income categories
      {'name': 'Gaji', 'icon_name': 'account_balance', 'color_hex': '4CAF50', 'type': 'income', 'is_default': 1, 'sort_order': 1},
      {'name': 'Bisnis', 'icon_name': 'business_center', 'color_hex': '2196F3', 'type': 'income', 'is_default': 1, 'sort_order': 2},
      {'name': 'Investasi', 'icon_name': 'trending_up', 'color_hex': 'FF5722', 'type': 'income', 'is_default': 1, 'sort_order': 3},
      {'name': 'Hadiah', 'icon_name': 'card_giftcard', 'color_hex': 'E91E63', 'type': 'income', 'is_default': 1, 'sort_order': 4},
      {'name': 'Lainnya', 'icon_name': 'more_horiz', 'color_hex': '607D8B', 'type': 'income', 'is_default': 1, 'sort_order': 99},
    ];

    for (var category in defaultCategories) {
      await db.insert('custom_categories', {
        ...category,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
    if (oldVersion < 2) {
      // Add geofences table for v2
      await db.execute('''
        CREATE TABLE IF NOT EXISTS geofences (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          latitude REAL NOT NULL,
          longitude REAL NOT NULL,
          radius REAL NOT NULL,
          budgetAmount REAL,
          category TEXT,
          isActive INTEGER DEFAULT 1,
          userId TEXT,
          createdAt TEXT NOT NULL,
          updatedAt TEXT
        )
      ''');
      await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_geofences_active ON geofences(isActive)');

      // Add debts table for v2
      await db.execute('''
        CREATE TABLE IF NOT EXISTS debts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          type TEXT NOT NULL,
          amount REAL NOT NULL,
          paid_amount REAL DEFAULT 0,
          status TEXT NOT NULL,
          due_date TEXT,
          description TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT
        )
      ''');
    }

    if (oldVersion < 3) {
      // Add custom_categories table for v3
      await db.execute('''
        CREATE TABLE IF NOT EXISTS custom_categories (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          icon_name TEXT NOT NULL,
          color_hex TEXT NOT NULL,
          type TEXT NOT NULL,
          is_default INTEGER DEFAULT 0,
          sort_order INTEGER DEFAULT 0,
          created_at TEXT NOT NULL,
          updated_at TEXT
        )
      ''');

      // Insert default categories
      await _insertDefaultCategories(db);
    }

    if (oldVersion < 4) {
      // v4: Create recurring_transactions table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS recurring_transactions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          amount REAL NOT NULL,
          type TEXT NOT NULL,
          category TEXT NOT NULL,
          recurrence TEXT NOT NULL,
          start_date TEXT NOT NULL,
          next_due_date TEXT,
          end_date TEXT,
          is_active INTEGER DEFAULT 1,
          auto_create INTEGER DEFAULT 1,
          reminder_days_before INTEGER,
          last_created_date TEXT,
          note TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT
        )
      ''');

      // v4: Create currency_preferences table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS currency_preferences (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          primary_currency TEXT NOT NULL DEFAULT 'IDR',
          secondary_currencies TEXT,
          show_in_multiple_currencies INTEGER DEFAULT 0,
          auto_update_rates INTEGER DEFAULT 1,
          last_rate_update TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT
        )
      ''');

      // v4: Create exchange_rates table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS exchange_rates (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          from_currency TEXT NOT NULL,
          to_currency TEXT NOT NULL,
          rate REAL NOT NULL,
          source TEXT,
          fetched_at TEXT NOT NULL
        )
      ''');

      // v4: Create split_transactions table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS split_transactions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          total_amount REAL NOT NULL,
          split_type TEXT NOT NULL,
          note TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT
        )
      ''');

      // v4: Create split_items table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS split_items (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          split_transaction_id INTEGER NOT NULL,
          participant_name TEXT NOT NULL,
          amount REAL NOT NULL,
          status TEXT NOT NULL DEFAULT 'pending',
          paid_at TEXT,
          FOREIGN KEY (split_transaction_id) REFERENCES split_transactions(id) ON DELETE CASCADE
        )
      ''');

      // v4: Create bills table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS bills (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          amount REAL NOT NULL,
          category TEXT NOT NULL,
          due_date TEXT NOT NULL,
          status TEXT NOT NULL DEFAULT 'pending',
          is_recurring INTEGER DEFAULT 0,
          recurrence TEXT,
          reminder_enabled INTEGER DEFAULT 1,
          reminder_days_before INTEGER DEFAULT 3,
          paid_at TEXT,
          note TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT
        )
      ''');

      // Create indexes for new tables
      await db.execute('CREATE INDEX IF NOT EXISTS idx_recurring_active ON recurring_transactions(is_active)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_recurring_next_due ON recurring_transactions(next_due_date)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_bills_status ON bills(status)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_bills_due_date ON bills(due_date)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_split_items_split_id ON split_items(split_transaction_id)');
    }
  }

  static Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  // CRUD Helper Methods
  static Future<int> insert(
      String table, Map<String, dynamic> values) async {
    return await instance.insert(table, values);
  }

  static Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    return await instance.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
  }

  static Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    return await instance.update(
      table,
      values,
      where: where,
      whereArgs: whereArgs,
    );
  }

  static Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    return await instance.delete(
      table,
      where: where,
      whereArgs: whereArgs,
    );
  }

  static Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    return await instance.rawQuery(sql, arguments);
  }

  static Future<int> rawUpdate(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    return await instance.rawUpdate(sql, arguments);
  }
}
