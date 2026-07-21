// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nfc_database.dart';

// ignore_for_file: type=lint
class $ScanRecordsTable extends ScanRecords
    with TableInfo<$ScanRecordsTable, ScanRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScanRecordsTable(this.attachedDatabase, [this._alias]);
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
  late final GeneratedColumnWithTypeConverter<ScanDirection, String> direction =
      GeneratedColumn<String>(
        'direction',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ScanDirection>($ScanRecordsTable.$converterdirection);
  static const VerificationMeta _idHexMeta = const VerificationMeta('idHex');
  @override
  late final GeneratedColumn<String> idHex = GeneratedColumn<String>(
    'id_hex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _techListMeta = const VerificationMeta(
    'techList',
  );
  @override
  late final GeneratedColumn<String> techList = GeneratedColumn<String>(
    'tech_list',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _ndefSummaryMeta = const VerificationMeta(
    'ndefSummary',
  );
  @override
  late final GeneratedColumn<String> ndefSummary = GeneratedColumn<String>(
    'ndef_summary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rawDumpHexMeta = const VerificationMeta(
    'rawDumpHex',
  );
  @override
  late final GeneratedColumn<String> rawDumpHex = GeneratedColumn<String>(
    'raw_dump_hex',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
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
    direction,
    idHex,
    techList,
    ndefSummary,
    rawDumpHex,
    label,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scan_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScanRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('id_hex')) {
      context.handle(
        _idHexMeta,
        idHex.isAcceptableOrUnknown(data['id_hex']!, _idHexMeta),
      );
    } else if (isInserting) {
      context.missing(_idHexMeta);
    }
    if (data.containsKey('tech_list')) {
      context.handle(
        _techListMeta,
        techList.isAcceptableOrUnknown(data['tech_list']!, _techListMeta),
      );
    }
    if (data.containsKey('ndef_summary')) {
      context.handle(
        _ndefSummaryMeta,
        ndefSummary.isAcceptableOrUnknown(
          data['ndef_summary']!,
          _ndefSummaryMeta,
        ),
      );
    }
    if (data.containsKey('raw_dump_hex')) {
      context.handle(
        _rawDumpHexMeta,
        rawDumpHex.isAcceptableOrUnknown(
          data['raw_dump_hex']!,
          _rawDumpHexMeta,
        ),
      );
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
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
  ScanRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScanRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      direction: $ScanRecordsTable.$converterdirection.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}direction'],
        )!,
      ),
      idHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id_hex'],
      )!,
      techList: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tech_list'],
      )!,
      ndefSummary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ndef_summary'],
      ),
      rawDumpHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_dump_hex'],
      ),
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ScanRecordsTable createAlias(String alias) {
    return $ScanRecordsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ScanDirection, String, String> $converterdirection =
      const EnumNameConverter<ScanDirection>(ScanDirection.values);
}

class ScanRecord extends DataClass implements Insertable<ScanRecord> {
  final int id;
  final ScanDirection direction;
  final String idHex;
  final String techList;
  final String? ndefSummary;
  final String? rawDumpHex;
  final String? label;
  final DateTime createdAt;
  const ScanRecord({
    required this.id,
    required this.direction,
    required this.idHex,
    required this.techList,
    this.ndefSummary,
    this.rawDumpHex,
    this.label,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['direction'] = Variable<String>(
        $ScanRecordsTable.$converterdirection.toSql(direction),
      );
    }
    map['id_hex'] = Variable<String>(idHex);
    map['tech_list'] = Variable<String>(techList);
    if (!nullToAbsent || ndefSummary != null) {
      map['ndef_summary'] = Variable<String>(ndefSummary);
    }
    if (!nullToAbsent || rawDumpHex != null) {
      map['raw_dump_hex'] = Variable<String>(rawDumpHex);
    }
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ScanRecordsCompanion toCompanion(bool nullToAbsent) {
    return ScanRecordsCompanion(
      id: Value(id),
      direction: Value(direction),
      idHex: Value(idHex),
      techList: Value(techList),
      ndefSummary: ndefSummary == null && nullToAbsent
          ? const Value.absent()
          : Value(ndefSummary),
      rawDumpHex: rawDumpHex == null && nullToAbsent
          ? const Value.absent()
          : Value(rawDumpHex),
      label: label == null && nullToAbsent
          ? const Value.absent()
          : Value(label),
      createdAt: Value(createdAt),
    );
  }

  factory ScanRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScanRecord(
      id: serializer.fromJson<int>(json['id']),
      direction: $ScanRecordsTable.$converterdirection.fromJson(
        serializer.fromJson<String>(json['direction']),
      ),
      idHex: serializer.fromJson<String>(json['idHex']),
      techList: serializer.fromJson<String>(json['techList']),
      ndefSummary: serializer.fromJson<String?>(json['ndefSummary']),
      rawDumpHex: serializer.fromJson<String?>(json['rawDumpHex']),
      label: serializer.fromJson<String?>(json['label']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'direction': serializer.toJson<String>(
        $ScanRecordsTable.$converterdirection.toJson(direction),
      ),
      'idHex': serializer.toJson<String>(idHex),
      'techList': serializer.toJson<String>(techList),
      'ndefSummary': serializer.toJson<String?>(ndefSummary),
      'rawDumpHex': serializer.toJson<String?>(rawDumpHex),
      'label': serializer.toJson<String?>(label),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ScanRecord copyWith({
    int? id,
    ScanDirection? direction,
    String? idHex,
    String? techList,
    Value<String?> ndefSummary = const Value.absent(),
    Value<String?> rawDumpHex = const Value.absent(),
    Value<String?> label = const Value.absent(),
    DateTime? createdAt,
  }) => ScanRecord(
    id: id ?? this.id,
    direction: direction ?? this.direction,
    idHex: idHex ?? this.idHex,
    techList: techList ?? this.techList,
    ndefSummary: ndefSummary.present ? ndefSummary.value : this.ndefSummary,
    rawDumpHex: rawDumpHex.present ? rawDumpHex.value : this.rawDumpHex,
    label: label.present ? label.value : this.label,
    createdAt: createdAt ?? this.createdAt,
  );
  ScanRecord copyWithCompanion(ScanRecordsCompanion data) {
    return ScanRecord(
      id: data.id.present ? data.id.value : this.id,
      direction: data.direction.present ? data.direction.value : this.direction,
      idHex: data.idHex.present ? data.idHex.value : this.idHex,
      techList: data.techList.present ? data.techList.value : this.techList,
      ndefSummary: data.ndefSummary.present
          ? data.ndefSummary.value
          : this.ndefSummary,
      rawDumpHex: data.rawDumpHex.present
          ? data.rawDumpHex.value
          : this.rawDumpHex,
      label: data.label.present ? data.label.value : this.label,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScanRecord(')
          ..write('id: $id, ')
          ..write('direction: $direction, ')
          ..write('idHex: $idHex, ')
          ..write('techList: $techList, ')
          ..write('ndefSummary: $ndefSummary, ')
          ..write('rawDumpHex: $rawDumpHex, ')
          ..write('label: $label, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    direction,
    idHex,
    techList,
    ndefSummary,
    rawDumpHex,
    label,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScanRecord &&
          other.id == this.id &&
          other.direction == this.direction &&
          other.idHex == this.idHex &&
          other.techList == this.techList &&
          other.ndefSummary == this.ndefSummary &&
          other.rawDumpHex == this.rawDumpHex &&
          other.label == this.label &&
          other.createdAt == this.createdAt);
}

class ScanRecordsCompanion extends UpdateCompanion<ScanRecord> {
  final Value<int> id;
  final Value<ScanDirection> direction;
  final Value<String> idHex;
  final Value<String> techList;
  final Value<String?> ndefSummary;
  final Value<String?> rawDumpHex;
  final Value<String?> label;
  final Value<DateTime> createdAt;
  const ScanRecordsCompanion({
    this.id = const Value.absent(),
    this.direction = const Value.absent(),
    this.idHex = const Value.absent(),
    this.techList = const Value.absent(),
    this.ndefSummary = const Value.absent(),
    this.rawDumpHex = const Value.absent(),
    this.label = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ScanRecordsCompanion.insert({
    this.id = const Value.absent(),
    required ScanDirection direction,
    required String idHex,
    this.techList = const Value.absent(),
    this.ndefSummary = const Value.absent(),
    this.rawDumpHex = const Value.absent(),
    this.label = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : direction = Value(direction),
       idHex = Value(idHex);
  static Insertable<ScanRecord> custom({
    Expression<int>? id,
    Expression<String>? direction,
    Expression<String>? idHex,
    Expression<String>? techList,
    Expression<String>? ndefSummary,
    Expression<String>? rawDumpHex,
    Expression<String>? label,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (direction != null) 'direction': direction,
      if (idHex != null) 'id_hex': idHex,
      if (techList != null) 'tech_list': techList,
      if (ndefSummary != null) 'ndef_summary': ndefSummary,
      if (rawDumpHex != null) 'raw_dump_hex': rawDumpHex,
      if (label != null) 'label': label,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ScanRecordsCompanion copyWith({
    Value<int>? id,
    Value<ScanDirection>? direction,
    Value<String>? idHex,
    Value<String>? techList,
    Value<String?>? ndefSummary,
    Value<String?>? rawDumpHex,
    Value<String?>? label,
    Value<DateTime>? createdAt,
  }) {
    return ScanRecordsCompanion(
      id: id ?? this.id,
      direction: direction ?? this.direction,
      idHex: idHex ?? this.idHex,
      techList: techList ?? this.techList,
      ndefSummary: ndefSummary ?? this.ndefSummary,
      rawDumpHex: rawDumpHex ?? this.rawDumpHex,
      label: label ?? this.label,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(
        $ScanRecordsTable.$converterdirection.toSql(direction.value),
      );
    }
    if (idHex.present) {
      map['id_hex'] = Variable<String>(idHex.value);
    }
    if (techList.present) {
      map['tech_list'] = Variable<String>(techList.value);
    }
    if (ndefSummary.present) {
      map['ndef_summary'] = Variable<String>(ndefSummary.value);
    }
    if (rawDumpHex.present) {
      map['raw_dump_hex'] = Variable<String>(rawDumpHex.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScanRecordsCompanion(')
          ..write('id: $id, ')
          ..write('direction: $direction, ')
          ..write('idHex: $idHex, ')
          ..write('techList: $techList, ')
          ..write('ndefSummary: $ndefSummary, ')
          ..write('rawDumpHex: $rawDumpHex, ')
          ..write('label: $label, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$NfcDatabase extends GeneratedDatabase {
  _$NfcDatabase(QueryExecutor e) : super(e);
  $NfcDatabaseManager get managers => $NfcDatabaseManager(this);
  late final $ScanRecordsTable scanRecords = $ScanRecordsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [scanRecords];
}

typedef $$ScanRecordsTableCreateCompanionBuilder =
    ScanRecordsCompanion Function({
      Value<int> id,
      required ScanDirection direction,
      required String idHex,
      Value<String> techList,
      Value<String?> ndefSummary,
      Value<String?> rawDumpHex,
      Value<String?> label,
      Value<DateTime> createdAt,
    });
typedef $$ScanRecordsTableUpdateCompanionBuilder =
    ScanRecordsCompanion Function({
      Value<int> id,
      Value<ScanDirection> direction,
      Value<String> idHex,
      Value<String> techList,
      Value<String?> ndefSummary,
      Value<String?> rawDumpHex,
      Value<String?> label,
      Value<DateTime> createdAt,
    });

class $$ScanRecordsTableFilterComposer
    extends Composer<_$NfcDatabase, $ScanRecordsTable> {
  $$ScanRecordsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<ScanDirection, ScanDirection, String>
  get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get idHex => $composableBuilder(
    column: $table.idHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get techList => $composableBuilder(
    column: $table.techList,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ndefSummary => $composableBuilder(
    column: $table.ndefSummary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawDumpHex => $composableBuilder(
    column: $table.rawDumpHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ScanRecordsTableOrderingComposer
    extends Composer<_$NfcDatabase, $ScanRecordsTable> {
  $$ScanRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idHex => $composableBuilder(
    column: $table.idHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get techList => $composableBuilder(
    column: $table.techList,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ndefSummary => $composableBuilder(
    column: $table.ndefSummary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawDumpHex => $composableBuilder(
    column: $table.rawDumpHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScanRecordsTableAnnotationComposer
    extends Composer<_$NfcDatabase, $ScanRecordsTable> {
  $$ScanRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ScanDirection, String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<String> get idHex =>
      $composableBuilder(column: $table.idHex, builder: (column) => column);

  GeneratedColumn<String> get techList =>
      $composableBuilder(column: $table.techList, builder: (column) => column);

  GeneratedColumn<String> get ndefSummary => $composableBuilder(
    column: $table.ndefSummary,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawDumpHex => $composableBuilder(
    column: $table.rawDumpHex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ScanRecordsTableTableManager
    extends
        RootTableManager<
          _$NfcDatabase,
          $ScanRecordsTable,
          ScanRecord,
          $$ScanRecordsTableFilterComposer,
          $$ScanRecordsTableOrderingComposer,
          $$ScanRecordsTableAnnotationComposer,
          $$ScanRecordsTableCreateCompanionBuilder,
          $$ScanRecordsTableUpdateCompanionBuilder,
          (
            ScanRecord,
            BaseReferences<_$NfcDatabase, $ScanRecordsTable, ScanRecord>,
          ),
          ScanRecord,
          PrefetchHooks Function()
        > {
  $$ScanRecordsTableTableManager(_$NfcDatabase db, $ScanRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScanRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScanRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScanRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<ScanDirection> direction = const Value.absent(),
                Value<String> idHex = const Value.absent(),
                Value<String> techList = const Value.absent(),
                Value<String?> ndefSummary = const Value.absent(),
                Value<String?> rawDumpHex = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ScanRecordsCompanion(
                id: id,
                direction: direction,
                idHex: idHex,
                techList: techList,
                ndefSummary: ndefSummary,
                rawDumpHex: rawDumpHex,
                label: label,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required ScanDirection direction,
                required String idHex,
                Value<String> techList = const Value.absent(),
                Value<String?> ndefSummary = const Value.absent(),
                Value<String?> rawDumpHex = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ScanRecordsCompanion.insert(
                id: id,
                direction: direction,
                idHex: idHex,
                techList: techList,
                ndefSummary: ndefSummary,
                rawDumpHex: rawDumpHex,
                label: label,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ScanRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$NfcDatabase,
      $ScanRecordsTable,
      ScanRecord,
      $$ScanRecordsTableFilterComposer,
      $$ScanRecordsTableOrderingComposer,
      $$ScanRecordsTableAnnotationComposer,
      $$ScanRecordsTableCreateCompanionBuilder,
      $$ScanRecordsTableUpdateCompanionBuilder,
      (
        ScanRecord,
        BaseReferences<_$NfcDatabase, $ScanRecordsTable, ScanRecord>,
      ),
      ScanRecord,
      PrefetchHooks Function()
    >;

class $NfcDatabaseManager {
  final _$NfcDatabase _db;
  $NfcDatabaseManager(this._db);
  $$ScanRecordsTableTableManager get scanRecords =>
      $$ScanRecordsTableTableManager(_db, _db.scanRecords);
}
