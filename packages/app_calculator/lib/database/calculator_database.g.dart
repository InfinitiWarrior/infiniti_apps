// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calculator_database.dart';

// ignore_for_file: type=lint
class $HistoryEntriesTable extends HistoryEntries
    with TableInfo<$HistoryEntriesTable, HistoryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HistoryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _expressionMeta = const VerificationMeta(
    'expression',
  );
  @override
  late final GeneratedColumn<String> expression = GeneratedColumn<String>(
    'expression',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resultMeta = const VerificationMeta('result');
  @override
  late final GeneratedColumn<String> result = GeneratedColumn<String>(
    'result',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, expression, result, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'history_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<HistoryEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('expression')) {
      context.handle(
        _expressionMeta,
        expression.isAcceptableOrUnknown(data['expression']!, _expressionMeta),
      );
    } else if (isInserting) {
      context.missing(_expressionMeta);
    }
    if (data.containsKey('result')) {
      context.handle(
        _resultMeta,
        result.isAcceptableOrUnknown(data['result']!, _resultMeta),
      );
    } else if (isInserting) {
      context.missing(_resultMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HistoryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HistoryEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      expression: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}expression'],
      )!,
      result: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $HistoryEntriesTable createAlias(String alias) {
    return $HistoryEntriesTable(attachedDatabase, alias);
  }
}

class HistoryEntry extends DataClass implements Insertable<HistoryEntry> {
  final int id;
  final String expression;
  final String result;
  final DateTime createdAt;
  const HistoryEntry({
    required this.id,
    required this.expression,
    required this.result,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['expression'] = Variable<String>(expression);
    map['result'] = Variable<String>(result);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  HistoryEntriesCompanion toCompanion(bool nullToAbsent) {
    return HistoryEntriesCompanion(
      id: Value(id),
      expression: Value(expression),
      result: Value(result),
      createdAt: Value(createdAt),
    );
  }

  factory HistoryEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HistoryEntry(
      id: serializer.fromJson<int>(json['id']),
      expression: serializer.fromJson<String>(json['expression']),
      result: serializer.fromJson<String>(json['result']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'expression': serializer.toJson<String>(expression),
      'result': serializer.toJson<String>(result),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  HistoryEntry copyWith({
    int? id,
    String? expression,
    String? result,
    DateTime? createdAt,
  }) => HistoryEntry(
    id: id ?? this.id,
    expression: expression ?? this.expression,
    result: result ?? this.result,
    createdAt: createdAt ?? this.createdAt,
  );
  HistoryEntry copyWithCompanion(HistoryEntriesCompanion data) {
    return HistoryEntry(
      id: data.id.present ? data.id.value : this.id,
      expression: data.expression.present
          ? data.expression.value
          : this.expression,
      result: data.result.present ? data.result.value : this.result,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HistoryEntry(')
          ..write('id: $id, ')
          ..write('expression: $expression, ')
          ..write('result: $result, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, expression, result, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HistoryEntry &&
          other.id == this.id &&
          other.expression == this.expression &&
          other.result == this.result &&
          other.createdAt == this.createdAt);
}

class HistoryEntriesCompanion extends UpdateCompanion<HistoryEntry> {
  final Value<int> id;
  final Value<String> expression;
  final Value<String> result;
  final Value<DateTime> createdAt;
  const HistoryEntriesCompanion({
    this.id = const Value.absent(),
    this.expression = const Value.absent(),
    this.result = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  HistoryEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String expression,
    required String result,
    this.createdAt = const Value.absent(),
  }) : expression = Value(expression),
       result = Value(result);
  static Insertable<HistoryEntry> custom({
    Expression<int>? id,
    Expression<String>? expression,
    Expression<String>? result,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (expression != null) 'expression': expression,
      if (result != null) 'result': result,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  HistoryEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? expression,
    Value<String>? result,
    Value<DateTime>? createdAt,
  }) {
    return HistoryEntriesCompanion(
      id: id ?? this.id,
      expression: expression ?? this.expression,
      result: result ?? this.result,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (expression.present) {
      map['expression'] = Variable<String>(expression.value);
    }
    if (result.present) {
      map['result'] = Variable<String>(result.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HistoryEntriesCompanion(')
          ..write('id: $id, ')
          ..write('expression: $expression, ')
          ..write('result: $result, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$CalculatorDatabase extends GeneratedDatabase {
  _$CalculatorDatabase(QueryExecutor e) : super(e);
  $CalculatorDatabaseManager get managers => $CalculatorDatabaseManager(this);
  late final $HistoryEntriesTable historyEntries = $HistoryEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [historyEntries];
}

typedef $$HistoryEntriesTableCreateCompanionBuilder =
    HistoryEntriesCompanion Function({
      Value<int> id,
      required String expression,
      required String result,
      Value<DateTime> createdAt,
    });
typedef $$HistoryEntriesTableUpdateCompanionBuilder =
    HistoryEntriesCompanion Function({
      Value<int> id,
      Value<String> expression,
      Value<String> result,
      Value<DateTime> createdAt,
    });

class $$HistoryEntriesTableFilterComposer
    extends Composer<_$CalculatorDatabase, $HistoryEntriesTable> {
  $$HistoryEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get expression => $composableBuilder(
    column: $table.expression,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HistoryEntriesTableOrderingComposer
    extends Composer<_$CalculatorDatabase, $HistoryEntriesTable> {
  $$HistoryEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get expression => $composableBuilder(
    column: $table.expression,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HistoryEntriesTableAnnotationComposer
    extends Composer<_$CalculatorDatabase, $HistoryEntriesTable> {
  $$HistoryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get expression => $composableBuilder(
    column: $table.expression,
    builder: (column) => column,
  );

  GeneratedColumn<String> get result =>
      $composableBuilder(column: $table.result, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$HistoryEntriesTableTableManager
    extends
        RootTableManager<
          _$CalculatorDatabase,
          $HistoryEntriesTable,
          HistoryEntry,
          $$HistoryEntriesTableFilterComposer,
          $$HistoryEntriesTableOrderingComposer,
          $$HistoryEntriesTableAnnotationComposer,
          $$HistoryEntriesTableCreateCompanionBuilder,
          $$HistoryEntriesTableUpdateCompanionBuilder,
          (
            HistoryEntry,
            BaseReferences<
              _$CalculatorDatabase,
              $HistoryEntriesTable,
              HistoryEntry
            >,
          ),
          HistoryEntry,
          PrefetchHooks Function()
        > {
  $$HistoryEntriesTableTableManager(
    _$CalculatorDatabase db,
    $HistoryEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HistoryEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HistoryEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HistoryEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> expression = const Value.absent(),
                Value<String> result = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => HistoryEntriesCompanion(
                id: id,
                expression: expression,
                result: result,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String expression,
                required String result,
                Value<DateTime> createdAt = const Value.absent(),
              }) => HistoryEntriesCompanion.insert(
                id: id,
                expression: expression,
                result: result,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HistoryEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$CalculatorDatabase,
      $HistoryEntriesTable,
      HistoryEntry,
      $$HistoryEntriesTableFilterComposer,
      $$HistoryEntriesTableOrderingComposer,
      $$HistoryEntriesTableAnnotationComposer,
      $$HistoryEntriesTableCreateCompanionBuilder,
      $$HistoryEntriesTableUpdateCompanionBuilder,
      (
        HistoryEntry,
        BaseReferences<
          _$CalculatorDatabase,
          $HistoryEntriesTable,
          HistoryEntry
        >,
      ),
      HistoryEntry,
      PrefetchHooks Function()
    >;

class $CalculatorDatabaseManager {
  final _$CalculatorDatabase _db;
  $CalculatorDatabaseManager(this._db);
  $$HistoryEntriesTableTableManager get historyEntries =>
      $$HistoryEntriesTableTableManager(_db, _db.historyEntries);
}
