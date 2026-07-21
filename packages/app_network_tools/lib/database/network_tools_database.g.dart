// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_tools_database.dart';

// ignore_for_file: type=lint
class $NetworkResultsTable extends NetworkResults
    with TableInfo<$NetworkResultsTable, NetworkResult> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NetworkResultsTable(this.attachedDatabase, [this._alias]);
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
  @override
  late final GeneratedColumnWithTypeConverter<NetworkToolType, String>
  toolType = GeneratedColumn<String>(
    'tool_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<NetworkToolType>($NetworkResultsTable.$convertertoolType);
  static const VerificationMeta _targetMeta = const VerificationMeta('target');
  @override
  late final GeneratedColumn<String> target = GeneratedColumn<String>(
    'target',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detailsMeta = const VerificationMeta(
    'details',
  );
  @override
  late final GeneratedColumn<String> details = GeneratedColumn<String>(
    'details',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  List<GeneratedColumn> get $columns => [
    id,
    toolType,
    target,
    summary,
    details,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'network_results';
  @override
  VerificationContext validateIntegrity(
    Insertable<NetworkResult> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('target')) {
      context.handle(
        _targetMeta,
        target.isAcceptableOrUnknown(data['target']!, _targetMeta),
      );
    } else if (isInserting) {
      context.missing(_targetMeta);
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    } else if (isInserting) {
      context.missing(_summaryMeta);
    }
    if (data.containsKey('details')) {
      context.handle(
        _detailsMeta,
        details.isAcceptableOrUnknown(data['details']!, _detailsMeta),
      );
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
  NetworkResult map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NetworkResult(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      toolType: $NetworkResultsTable.$convertertoolType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tool_type'],
        )!,
      ),
      target: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target'],
      )!,
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      )!,
      details: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}details'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $NetworkResultsTable createAlias(String alias) {
    return $NetworkResultsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<NetworkToolType, String, String>
  $convertertoolType = const EnumNameConverter<NetworkToolType>(
    NetworkToolType.values,
  );
}

class NetworkResult extends DataClass implements Insertable<NetworkResult> {
  final int id;
  final NetworkToolType toolType;
  final String target;
  final String summary;
  final String? details;
  final DateTime createdAt;
  const NetworkResult({
    required this.id,
    required this.toolType,
    required this.target,
    required this.summary,
    this.details,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['tool_type'] = Variable<String>(
        $NetworkResultsTable.$convertertoolType.toSql(toolType),
      );
    }
    map['target'] = Variable<String>(target);
    map['summary'] = Variable<String>(summary);
    if (!nullToAbsent || details != null) {
      map['details'] = Variable<String>(details);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  NetworkResultsCompanion toCompanion(bool nullToAbsent) {
    return NetworkResultsCompanion(
      id: Value(id),
      toolType: Value(toolType),
      target: Value(target),
      summary: Value(summary),
      details: details == null && nullToAbsent
          ? const Value.absent()
          : Value(details),
      createdAt: Value(createdAt),
    );
  }

  factory NetworkResult.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NetworkResult(
      id: serializer.fromJson<int>(json['id']),
      toolType: $NetworkResultsTable.$convertertoolType.fromJson(
        serializer.fromJson<String>(json['toolType']),
      ),
      target: serializer.fromJson<String>(json['target']),
      summary: serializer.fromJson<String>(json['summary']),
      details: serializer.fromJson<String?>(json['details']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'toolType': serializer.toJson<String>(
        $NetworkResultsTable.$convertertoolType.toJson(toolType),
      ),
      'target': serializer.toJson<String>(target),
      'summary': serializer.toJson<String>(summary),
      'details': serializer.toJson<String?>(details),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  NetworkResult copyWith({
    int? id,
    NetworkToolType? toolType,
    String? target,
    String? summary,
    Value<String?> details = const Value.absent(),
    DateTime? createdAt,
  }) => NetworkResult(
    id: id ?? this.id,
    toolType: toolType ?? this.toolType,
    target: target ?? this.target,
    summary: summary ?? this.summary,
    details: details.present ? details.value : this.details,
    createdAt: createdAt ?? this.createdAt,
  );
  NetworkResult copyWithCompanion(NetworkResultsCompanion data) {
    return NetworkResult(
      id: data.id.present ? data.id.value : this.id,
      toolType: data.toolType.present ? data.toolType.value : this.toolType,
      target: data.target.present ? data.target.value : this.target,
      summary: data.summary.present ? data.summary.value : this.summary,
      details: data.details.present ? data.details.value : this.details,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NetworkResult(')
          ..write('id: $id, ')
          ..write('toolType: $toolType, ')
          ..write('target: $target, ')
          ..write('summary: $summary, ')
          ..write('details: $details, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, toolType, target, summary, details, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NetworkResult &&
          other.id == this.id &&
          other.toolType == this.toolType &&
          other.target == this.target &&
          other.summary == this.summary &&
          other.details == this.details &&
          other.createdAt == this.createdAt);
}

class NetworkResultsCompanion extends UpdateCompanion<NetworkResult> {
  final Value<int> id;
  final Value<NetworkToolType> toolType;
  final Value<String> target;
  final Value<String> summary;
  final Value<String?> details;
  final Value<DateTime> createdAt;
  const NetworkResultsCompanion({
    this.id = const Value.absent(),
    this.toolType = const Value.absent(),
    this.target = const Value.absent(),
    this.summary = const Value.absent(),
    this.details = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  NetworkResultsCompanion.insert({
    this.id = const Value.absent(),
    required NetworkToolType toolType,
    required String target,
    required String summary,
    this.details = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : toolType = Value(toolType),
       target = Value(target),
       summary = Value(summary);
  static Insertable<NetworkResult> custom({
    Expression<int>? id,
    Expression<String>? toolType,
    Expression<String>? target,
    Expression<String>? summary,
    Expression<String>? details,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (toolType != null) 'tool_type': toolType,
      if (target != null) 'target': target,
      if (summary != null) 'summary': summary,
      if (details != null) 'details': details,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  NetworkResultsCompanion copyWith({
    Value<int>? id,
    Value<NetworkToolType>? toolType,
    Value<String>? target,
    Value<String>? summary,
    Value<String?>? details,
    Value<DateTime>? createdAt,
  }) {
    return NetworkResultsCompanion(
      id: id ?? this.id,
      toolType: toolType ?? this.toolType,
      target: target ?? this.target,
      summary: summary ?? this.summary,
      details: details ?? this.details,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (toolType.present) {
      map['tool_type'] = Variable<String>(
        $NetworkResultsTable.$convertertoolType.toSql(toolType.value),
      );
    }
    if (target.present) {
      map['target'] = Variable<String>(target.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (details.present) {
      map['details'] = Variable<String>(details.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NetworkResultsCompanion(')
          ..write('id: $id, ')
          ..write('toolType: $toolType, ')
          ..write('target: $target, ')
          ..write('summary: $summary, ')
          ..write('details: $details, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$NetworkToolsDatabase extends GeneratedDatabase {
  _$NetworkToolsDatabase(QueryExecutor e) : super(e);
  $NetworkToolsDatabaseManager get managers =>
      $NetworkToolsDatabaseManager(this);
  late final $NetworkResultsTable networkResults = $NetworkResultsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [networkResults];
}

typedef $$NetworkResultsTableCreateCompanionBuilder =
    NetworkResultsCompanion Function({
      Value<int> id,
      required NetworkToolType toolType,
      required String target,
      required String summary,
      Value<String?> details,
      Value<DateTime> createdAt,
    });
typedef $$NetworkResultsTableUpdateCompanionBuilder =
    NetworkResultsCompanion Function({
      Value<int> id,
      Value<NetworkToolType> toolType,
      Value<String> target,
      Value<String> summary,
      Value<String?> details,
      Value<DateTime> createdAt,
    });

class $$NetworkResultsTableFilterComposer
    extends Composer<_$NetworkToolsDatabase, $NetworkResultsTable> {
  $$NetworkResultsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<NetworkToolType, NetworkToolType, String>
  get toolType => $composableBuilder(
    column: $table.toolType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get details => $composableBuilder(
    column: $table.details,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NetworkResultsTableOrderingComposer
    extends Composer<_$NetworkToolsDatabase, $NetworkResultsTable> {
  $$NetworkResultsTableOrderingComposer({
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

  ColumnOrderings<String> get toolType => $composableBuilder(
    column: $table.toolType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get details => $composableBuilder(
    column: $table.details,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NetworkResultsTableAnnotationComposer
    extends Composer<_$NetworkToolsDatabase, $NetworkResultsTable> {
  $$NetworkResultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<NetworkToolType, String> get toolType =>
      $composableBuilder(column: $table.toolType, builder: (column) => column);

  GeneratedColumn<String> get target =>
      $composableBuilder(column: $table.target, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get details =>
      $composableBuilder(column: $table.details, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$NetworkResultsTableTableManager
    extends
        RootTableManager<
          _$NetworkToolsDatabase,
          $NetworkResultsTable,
          NetworkResult,
          $$NetworkResultsTableFilterComposer,
          $$NetworkResultsTableOrderingComposer,
          $$NetworkResultsTableAnnotationComposer,
          $$NetworkResultsTableCreateCompanionBuilder,
          $$NetworkResultsTableUpdateCompanionBuilder,
          (
            NetworkResult,
            BaseReferences<
              _$NetworkToolsDatabase,
              $NetworkResultsTable,
              NetworkResult
            >,
          ),
          NetworkResult,
          PrefetchHooks Function()
        > {
  $$NetworkResultsTableTableManager(
    _$NetworkToolsDatabase db,
    $NetworkResultsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NetworkResultsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NetworkResultsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NetworkResultsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<NetworkToolType> toolType = const Value.absent(),
                Value<String> target = const Value.absent(),
                Value<String> summary = const Value.absent(),
                Value<String?> details = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => NetworkResultsCompanion(
                id: id,
                toolType: toolType,
                target: target,
                summary: summary,
                details: details,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required NetworkToolType toolType,
                required String target,
                required String summary,
                Value<String?> details = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => NetworkResultsCompanion.insert(
                id: id,
                toolType: toolType,
                target: target,
                summary: summary,
                details: details,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NetworkResultsTableProcessedTableManager =
    ProcessedTableManager<
      _$NetworkToolsDatabase,
      $NetworkResultsTable,
      NetworkResult,
      $$NetworkResultsTableFilterComposer,
      $$NetworkResultsTableOrderingComposer,
      $$NetworkResultsTableAnnotationComposer,
      $$NetworkResultsTableCreateCompanionBuilder,
      $$NetworkResultsTableUpdateCompanionBuilder,
      (
        NetworkResult,
        BaseReferences<
          _$NetworkToolsDatabase,
          $NetworkResultsTable,
          NetworkResult
        >,
      ),
      NetworkResult,
      PrefetchHooks Function()
    >;

class $NetworkToolsDatabaseManager {
  final _$NetworkToolsDatabase _db;
  $NetworkToolsDatabaseManager(this._db);
  $$NetworkResultsTableTableManager get networkResults =>
      $$NetworkResultsTableTableManager(_db, _db.networkResults);
}
