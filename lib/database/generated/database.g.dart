// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../database.dart';

// ignore_for_file: type=lint
class $ProfilesTable extends Profiles
    with TableInfo<$ProfilesTable, RawProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentGroupNameMeta = const VerificationMeta(
    'currentGroupName',
  );
  @override
  late final GeneratedColumn<String> currentGroupName = GeneratedColumn<String>(
    'current_group_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastUpdateDateMeta = const VerificationMeta(
    'lastUpdateDate',
  );
  @override
  late final GeneratedColumn<DateTime> lastUpdateDate =
      GeneratedColumn<DateTime>(
        'last_update_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _autoUpdateDurationMillisMeta =
      const VerificationMeta('autoUpdateDurationMillis');
  @override
  late final GeneratedColumn<int> autoUpdateDurationMillis =
      GeneratedColumn<int>(
        'auto_update_duration_millis',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  @override
  late final GeneratedColumnWithTypeConverter<SubscriptionInfo?, String>
  subscriptionInfo = GeneratedColumn<String>(
    'subscription_info',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<SubscriptionInfo?>($ProfilesTable.$convertersubscriptionInfo);
  static const VerificationMeta _autoUpdateMeta = const VerificationMeta(
    'autoUpdate',
  );
  @override
  late final GeneratedColumn<bool> autoUpdate = GeneratedColumn<bool>(
    'auto_update',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("auto_update" IN (0, 1))',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, String>, String>
  selectedMap = GeneratedColumn<String>(
    'selected_map',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<Map<String, String>>($ProfilesTable.$converterselectedMap);
  @override
  late final GeneratedColumnWithTypeConverter<Set<String>, String> unfoldSet =
      GeneratedColumn<String>(
        'unfold_set',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Set<String>>($ProfilesTable.$converterunfoldSet);
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
    'order',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    label,
    currentGroupName,
    url,
    lastUpdateDate,
    autoUpdateDurationMillis,
    subscriptionInfo,
    autoUpdate,
    selectedMap,
    unfoldSet,
    order,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<RawProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('current_group_name')) {
      context.handle(
        _currentGroupNameMeta,
        currentGroupName.isAcceptableOrUnknown(
          data['current_group_name']!,
          _currentGroupNameMeta,
        ),
      );
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('last_update_date')) {
      context.handle(
        _lastUpdateDateMeta,
        lastUpdateDate.isAcceptableOrUnknown(
          data['last_update_date']!,
          _lastUpdateDateMeta,
        ),
      );
    }
    if (data.containsKey('auto_update_duration_millis')) {
      context.handle(
        _autoUpdateDurationMillisMeta,
        autoUpdateDurationMillis.isAcceptableOrUnknown(
          data['auto_update_duration_millis']!,
          _autoUpdateDurationMillisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_autoUpdateDurationMillisMeta);
    }
    if (data.containsKey('auto_update')) {
      context.handle(
        _autoUpdateMeta,
        autoUpdate.isAcceptableOrUnknown(data['auto_update']!, _autoUpdateMeta),
      );
    } else if (isInserting) {
      context.missing(_autoUpdateMeta);
    }
    if (data.containsKey('order')) {
      context.handle(
        _orderMeta,
        order.isAcceptableOrUnknown(data['order']!, _orderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RawProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RawProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      currentGroupName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_group_name'],
      ),
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      lastUpdateDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_update_date'],
      ),
      autoUpdateDurationMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}auto_update_duration_millis'],
      )!,
      subscriptionInfo: $ProfilesTable.$convertersubscriptionInfo.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}subscription_info'],
        ),
      ),
      autoUpdate: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}auto_update'],
      )!,
      selectedMap: $ProfilesTable.$converterselectedMap.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}selected_map'],
        )!,
      ),
      unfoldSet: $ProfilesTable.$converterunfoldSet.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}unfold_set'],
        )!,
      ),
      order: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order'],
      ),
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }

  static TypeConverter<SubscriptionInfo?, String?> $convertersubscriptionInfo =
      const SubscriptionInfoConverter();
  static TypeConverter<Map<String, String>, String> $converterselectedMap =
      const StringMapConverter();
  static TypeConverter<Set<String>, String> $converterunfoldSet =
      const StringSetConverter();
}

class RawProfile extends DataClass implements Insertable<RawProfile> {
  final int id;
  final String label;
  final String? currentGroupName;
  final String url;
  final DateTime? lastUpdateDate;
  final int autoUpdateDurationMillis;
  final SubscriptionInfo? subscriptionInfo;
  final bool autoUpdate;
  final Map<String, String> selectedMap;
  final Set<String> unfoldSet;
  final int? order;
  const RawProfile({
    required this.id,
    required this.label,
    this.currentGroupName,
    required this.url,
    this.lastUpdateDate,
    required this.autoUpdateDurationMillis,
    this.subscriptionInfo,
    required this.autoUpdate,
    required this.selectedMap,
    required this.unfoldSet,
    this.order,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['label'] = Variable<String>(label);
    if (!nullToAbsent || currentGroupName != null) {
      map['current_group_name'] = Variable<String>(currentGroupName);
    }
    map['url'] = Variable<String>(url);
    if (!nullToAbsent || lastUpdateDate != null) {
      map['last_update_date'] = Variable<DateTime>(lastUpdateDate);
    }
    map['auto_update_duration_millis'] = Variable<int>(
      autoUpdateDurationMillis,
    );
    if (!nullToAbsent || subscriptionInfo != null) {
      map['subscription_info'] = Variable<String>(
        $ProfilesTable.$convertersubscriptionInfo.toSql(subscriptionInfo),
      );
    }
    map['auto_update'] = Variable<bool>(autoUpdate);
    {
      map['selected_map'] = Variable<String>(
        $ProfilesTable.$converterselectedMap.toSql(selectedMap),
      );
    }
    {
      map['unfold_set'] = Variable<String>(
        $ProfilesTable.$converterunfoldSet.toSql(unfoldSet),
      );
    }
    if (!nullToAbsent || order != null) {
      map['order'] = Variable<int>(order);
    }
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      label: Value(label),
      currentGroupName: currentGroupName == null && nullToAbsent
          ? const Value.absent()
          : Value(currentGroupName),
      url: Value(url),
      lastUpdateDate: lastUpdateDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUpdateDate),
      autoUpdateDurationMillis: Value(autoUpdateDurationMillis),
      subscriptionInfo: subscriptionInfo == null && nullToAbsent
          ? const Value.absent()
          : Value(subscriptionInfo),
      autoUpdate: Value(autoUpdate),
      selectedMap: Value(selectedMap),
      unfoldSet: Value(unfoldSet),
      order: order == null && nullToAbsent
          ? const Value.absent()
          : Value(order),
    );
  }

  factory RawProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RawProfile(
      id: serializer.fromJson<int>(json['id']),
      label: serializer.fromJson<String>(json['label']),
      currentGroupName: serializer.fromJson<String?>(json['currentGroupName']),
      url: serializer.fromJson<String>(json['url']),
      lastUpdateDate: serializer.fromJson<DateTime?>(json['lastUpdateDate']),
      autoUpdateDurationMillis: serializer.fromJson<int>(
        json['autoUpdateDurationMillis'],
      ),
      subscriptionInfo: serializer.fromJson<SubscriptionInfo?>(
        json['subscriptionInfo'],
      ),
      autoUpdate: serializer.fromJson<bool>(json['autoUpdate']),
      selectedMap: serializer.fromJson<Map<String, String>>(
        json['selectedMap'],
      ),
      unfoldSet: serializer.fromJson<Set<String>>(json['unfoldSet']),
      order: serializer.fromJson<int?>(json['order']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'label': serializer.toJson<String>(label),
      'currentGroupName': serializer.toJson<String?>(currentGroupName),
      'url': serializer.toJson<String>(url),
      'lastUpdateDate': serializer.toJson<DateTime?>(lastUpdateDate),
      'autoUpdateDurationMillis': serializer.toJson<int>(
        autoUpdateDurationMillis,
      ),
      'subscriptionInfo': serializer.toJson<SubscriptionInfo?>(
        subscriptionInfo,
      ),
      'autoUpdate': serializer.toJson<bool>(autoUpdate),
      'selectedMap': serializer.toJson<Map<String, String>>(selectedMap),
      'unfoldSet': serializer.toJson<Set<String>>(unfoldSet),
      'order': serializer.toJson<int?>(order),
    };
  }

  RawProfile copyWith({
    int? id,
    String? label,
    Value<String?> currentGroupName = const Value.absent(),
    String? url,
    Value<DateTime?> lastUpdateDate = const Value.absent(),
    int? autoUpdateDurationMillis,
    Value<SubscriptionInfo?> subscriptionInfo = const Value.absent(),
    bool? autoUpdate,
    Map<String, String>? selectedMap,
    Set<String>? unfoldSet,
    Value<int?> order = const Value.absent(),
  }) => RawProfile(
    id: id ?? this.id,
    label: label ?? this.label,
    currentGroupName: currentGroupName.present
        ? currentGroupName.value
        : this.currentGroupName,
    url: url ?? this.url,
    lastUpdateDate: lastUpdateDate.present
        ? lastUpdateDate.value
        : this.lastUpdateDate,
    autoUpdateDurationMillis:
        autoUpdateDurationMillis ?? this.autoUpdateDurationMillis,
    subscriptionInfo: subscriptionInfo.present
        ? subscriptionInfo.value
        : this.subscriptionInfo,
    autoUpdate: autoUpdate ?? this.autoUpdate,
    selectedMap: selectedMap ?? this.selectedMap,
    unfoldSet: unfoldSet ?? this.unfoldSet,
    order: order.present ? order.value : this.order,
  );
  RawProfile copyWithCompanion(ProfilesCompanion data) {
    return RawProfile(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      currentGroupName: data.currentGroupName.present
          ? data.currentGroupName.value
          : this.currentGroupName,
      url: data.url.present ? data.url.value : this.url,
      lastUpdateDate: data.lastUpdateDate.present
          ? data.lastUpdateDate.value
          : this.lastUpdateDate,
      autoUpdateDurationMillis: data.autoUpdateDurationMillis.present
          ? data.autoUpdateDurationMillis.value
          : this.autoUpdateDurationMillis,
      subscriptionInfo: data.subscriptionInfo.present
          ? data.subscriptionInfo.value
          : this.subscriptionInfo,
      autoUpdate: data.autoUpdate.present
          ? data.autoUpdate.value
          : this.autoUpdate,
      selectedMap: data.selectedMap.present
          ? data.selectedMap.value
          : this.selectedMap,
      unfoldSet: data.unfoldSet.present ? data.unfoldSet.value : this.unfoldSet,
      order: data.order.present ? data.order.value : this.order,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RawProfile(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('currentGroupName: $currentGroupName, ')
          ..write('url: $url, ')
          ..write('lastUpdateDate: $lastUpdateDate, ')
          ..write('autoUpdateDurationMillis: $autoUpdateDurationMillis, ')
          ..write('subscriptionInfo: $subscriptionInfo, ')
          ..write('autoUpdate: $autoUpdate, ')
          ..write('selectedMap: $selectedMap, ')
          ..write('unfoldSet: $unfoldSet, ')
          ..write('order: $order')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    label,
    currentGroupName,
    url,
    lastUpdateDate,
    autoUpdateDurationMillis,
    subscriptionInfo,
    autoUpdate,
    selectedMap,
    unfoldSet,
    order,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RawProfile &&
          other.id == this.id &&
          other.label == this.label &&
          other.currentGroupName == this.currentGroupName &&
          other.url == this.url &&
          other.lastUpdateDate == this.lastUpdateDate &&
          other.autoUpdateDurationMillis == this.autoUpdateDurationMillis &&
          other.subscriptionInfo == this.subscriptionInfo &&
          other.autoUpdate == this.autoUpdate &&
          other.selectedMap == this.selectedMap &&
          other.unfoldSet == this.unfoldSet &&
          other.order == this.order);
}

class ProfilesCompanion extends UpdateCompanion<RawProfile> {
  final Value<int> id;
  final Value<String> label;
  final Value<String?> currentGroupName;
  final Value<String> url;
  final Value<DateTime?> lastUpdateDate;
  final Value<int> autoUpdateDurationMillis;
  final Value<SubscriptionInfo?> subscriptionInfo;
  final Value<bool> autoUpdate;
  final Value<Map<String, String>> selectedMap;
  final Value<Set<String>> unfoldSet;
  final Value<int?> order;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.currentGroupName = const Value.absent(),
    this.url = const Value.absent(),
    this.lastUpdateDate = const Value.absent(),
    this.autoUpdateDurationMillis = const Value.absent(),
    this.subscriptionInfo = const Value.absent(),
    this.autoUpdate = const Value.absent(),
    this.selectedMap = const Value.absent(),
    this.unfoldSet = const Value.absent(),
    this.order = const Value.absent(),
  });
  ProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String label,
    this.currentGroupName = const Value.absent(),
    required String url,
    this.lastUpdateDate = const Value.absent(),
    required int autoUpdateDurationMillis,
    this.subscriptionInfo = const Value.absent(),
    required bool autoUpdate,
    required Map<String, String> selectedMap,
    required Set<String> unfoldSet,
    this.order = const Value.absent(),
  }) : label = Value(label),
       url = Value(url),
       autoUpdateDurationMillis = Value(autoUpdateDurationMillis),
       autoUpdate = Value(autoUpdate),
       selectedMap = Value(selectedMap),
       unfoldSet = Value(unfoldSet);
  static Insertable<RawProfile> custom({
    Expression<int>? id,
    Expression<String>? label,
    Expression<String>? currentGroupName,
    Expression<String>? url,
    Expression<DateTime>? lastUpdateDate,
    Expression<int>? autoUpdateDurationMillis,
    Expression<String>? subscriptionInfo,
    Expression<bool>? autoUpdate,
    Expression<String>? selectedMap,
    Expression<String>? unfoldSet,
    Expression<int>? order,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (currentGroupName != null) 'current_group_name': currentGroupName,
      if (url != null) 'url': url,
      if (lastUpdateDate != null) 'last_update_date': lastUpdateDate,
      if (autoUpdateDurationMillis != null)
        'auto_update_duration_millis': autoUpdateDurationMillis,
      if (subscriptionInfo != null) 'subscription_info': subscriptionInfo,
      if (autoUpdate != null) 'auto_update': autoUpdate,
      if (selectedMap != null) 'selected_map': selectedMap,
      if (unfoldSet != null) 'unfold_set': unfoldSet,
      if (order != null) 'order': order,
    });
  }

  ProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? label,
    Value<String?>? currentGroupName,
    Value<String>? url,
    Value<DateTime?>? lastUpdateDate,
    Value<int>? autoUpdateDurationMillis,
    Value<SubscriptionInfo?>? subscriptionInfo,
    Value<bool>? autoUpdate,
    Value<Map<String, String>>? selectedMap,
    Value<Set<String>>? unfoldSet,
    Value<int?>? order,
  }) {
    return ProfilesCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      currentGroupName: currentGroupName ?? this.currentGroupName,
      url: url ?? this.url,
      lastUpdateDate: lastUpdateDate ?? this.lastUpdateDate,
      autoUpdateDurationMillis:
          autoUpdateDurationMillis ?? this.autoUpdateDurationMillis,
      subscriptionInfo: subscriptionInfo ?? this.subscriptionInfo,
      autoUpdate: autoUpdate ?? this.autoUpdate,
      selectedMap: selectedMap ?? this.selectedMap,
      unfoldSet: unfoldSet ?? this.unfoldSet,
      order: order ?? this.order,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (currentGroupName.present) {
      map['current_group_name'] = Variable<String>(currentGroupName.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (lastUpdateDate.present) {
      map['last_update_date'] = Variable<DateTime>(lastUpdateDate.value);
    }
    if (autoUpdateDurationMillis.present) {
      map['auto_update_duration_millis'] = Variable<int>(
        autoUpdateDurationMillis.value,
      );
    }
    if (subscriptionInfo.present) {
      map['subscription_info'] = Variable<String>(
        $ProfilesTable.$convertersubscriptionInfo.toSql(subscriptionInfo.value),
      );
    }
    if (autoUpdate.present) {
      map['auto_update'] = Variable<bool>(autoUpdate.value);
    }
    if (selectedMap.present) {
      map['selected_map'] = Variable<String>(
        $ProfilesTable.$converterselectedMap.toSql(selectedMap.value),
      );
    }
    if (unfoldSet.present) {
      map['unfold_set'] = Variable<String>(
        $ProfilesTable.$converterunfoldSet.toSql(unfoldSet.value),
      );
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('currentGroupName: $currentGroupName, ')
          ..write('url: $url, ')
          ..write('lastUpdateDate: $lastUpdateDate, ')
          ..write('autoUpdateDurationMillis: $autoUpdateDurationMillis, ')
          ..write('subscriptionInfo: $subscriptionInfo, ')
          ..write('autoUpdate: $autoUpdate, ')
          ..write('selectedMap: $selectedMap, ')
          ..write('unfoldSet: $unfoldSet, ')
          ..write('order: $order')
          ..write(')'))
        .toString();
  }
}

class $IconRecordsTable extends IconRecords
    with TableInfo<$IconRecordsTable, IconRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IconRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastAccessedMeta = const VerificationMeta(
    'lastAccessed',
  );
  @override
  late final GeneratedColumn<int> lastAccessed = GeneratedColumn<int>(
    'last_accessed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [url, lastAccessed];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'icon_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<IconRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('last_accessed')) {
      context.handle(
        _lastAccessedMeta,
        lastAccessed.isAcceptableOrUnknown(
          data['last_accessed']!,
          _lastAccessedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastAccessedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {url};
  @override
  IconRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IconRecord(
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      lastAccessed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_accessed'],
      )!,
    );
  }

  @override
  $IconRecordsTable createAlias(String alias) {
    return $IconRecordsTable(attachedDatabase, alias);
  }
}

class IconRecord extends DataClass implements Insertable<IconRecord> {
  final String url;
  final int lastAccessed;
  const IconRecord({required this.url, required this.lastAccessed});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['url'] = Variable<String>(url);
    map['last_accessed'] = Variable<int>(lastAccessed);
    return map;
  }

  IconRecordsCompanion toCompanion(bool nullToAbsent) {
    return IconRecordsCompanion(
      url: Value(url),
      lastAccessed: Value(lastAccessed),
    );
  }

  factory IconRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IconRecord(
      url: serializer.fromJson<String>(json['url']),
      lastAccessed: serializer.fromJson<int>(json['lastAccessed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'url': serializer.toJson<String>(url),
      'lastAccessed': serializer.toJson<int>(lastAccessed),
    };
  }

  IconRecord copyWith({String? url, int? lastAccessed}) => IconRecord(
    url: url ?? this.url,
    lastAccessed: lastAccessed ?? this.lastAccessed,
  );
  IconRecord copyWithCompanion(IconRecordsCompanion data) {
    return IconRecord(
      url: data.url.present ? data.url.value : this.url,
      lastAccessed: data.lastAccessed.present
          ? data.lastAccessed.value
          : this.lastAccessed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IconRecord(')
          ..write('url: $url, ')
          ..write('lastAccessed: $lastAccessed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(url, lastAccessed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IconRecord &&
          other.url == this.url &&
          other.lastAccessed == this.lastAccessed);
}

class IconRecordsCompanion extends UpdateCompanion<IconRecord> {
  final Value<String> url;
  final Value<int> lastAccessed;
  final Value<int> rowid;
  const IconRecordsCompanion({
    this.url = const Value.absent(),
    this.lastAccessed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IconRecordsCompanion.insert({
    required String url,
    required int lastAccessed,
    this.rowid = const Value.absent(),
  }) : url = Value(url),
       lastAccessed = Value(lastAccessed);
  static Insertable<IconRecord> custom({
    Expression<String>? url,
    Expression<int>? lastAccessed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (url != null) 'url': url,
      if (lastAccessed != null) 'last_accessed': lastAccessed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IconRecordsCompanion copyWith({
    Value<String>? url,
    Value<int>? lastAccessed,
    Value<int>? rowid,
  }) {
    return IconRecordsCompanion(
      url: url ?? this.url,
      lastAccessed: lastAccessed ?? this.lastAccessed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (lastAccessed.present) {
      map['last_accessed'] = Variable<int>(lastAccessed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IconRecordsCompanion(')
          ..write('url: $url, ')
          ..write('lastAccessed: $lastAccessed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$Database extends GeneratedDatabase {
  _$Database(QueryExecutor e) : super(e);
  $DatabaseManager get managers => $DatabaseManager(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $IconRecordsTable iconRecords = $IconRecordsTable(this);
  late final Index lastAccessedUrl = Index(
    'last_accessed_url',
    'CREATE INDEX last_accessed_url ON icon_records (last_accessed, url)',
  );
  late final ProfilesDao profilesDao = ProfilesDao(this as Database);
  late final IconRecordsDao iconRecordsDao = IconRecordsDao(this as Database);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    profiles,
    iconRecords,
    lastAccessedUrl,
  ];
}

typedef $$ProfilesTableCreateCompanionBuilder =
    ProfilesCompanion Function({
      Value<int> id,
      required String label,
      Value<String?> currentGroupName,
      required String url,
      Value<DateTime?> lastUpdateDate,
      required int autoUpdateDurationMillis,
      Value<SubscriptionInfo?> subscriptionInfo,
      required bool autoUpdate,
      required Map<String, String> selectedMap,
      required Set<String> unfoldSet,
      Value<int?> order,
    });
typedef $$ProfilesTableUpdateCompanionBuilder =
    ProfilesCompanion Function({
      Value<int> id,
      Value<String> label,
      Value<String?> currentGroupName,
      Value<String> url,
      Value<DateTime?> lastUpdateDate,
      Value<int> autoUpdateDurationMillis,
      Value<SubscriptionInfo?> subscriptionInfo,
      Value<bool> autoUpdate,
      Value<Map<String, String>> selectedMap,
      Value<Set<String>> unfoldSet,
      Value<int?> order,
    });

class $$ProfilesTableFilterComposer
    extends Composer<_$Database, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
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

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentGroupName => $composableBuilder(
    column: $table.currentGroupName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUpdateDate => $composableBuilder(
    column: $table.lastUpdateDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get autoUpdateDurationMillis => $composableBuilder(
    column: $table.autoUpdateDurationMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SubscriptionInfo?, SubscriptionInfo, String>
  get subscriptionInfo => $composableBuilder(
    column: $table.subscriptionInfo,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get autoUpdate => $composableBuilder(
    column: $table.autoUpdate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    Map<String, String>,
    Map<String, String>,
    String
  >
  get selectedMap => $composableBuilder(
    column: $table.selectedMap,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<Set<String>, Set<String>, String>
  get unfoldSet => $composableBuilder(
    column: $table.unfoldSet,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$Database, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
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

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentGroupName => $composableBuilder(
    column: $table.currentGroupName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUpdateDate => $composableBuilder(
    column: $table.lastUpdateDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get autoUpdateDurationMillis => $composableBuilder(
    column: $table.autoUpdateDurationMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subscriptionInfo => $composableBuilder(
    column: $table.subscriptionInfo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get autoUpdate => $composableBuilder(
    column: $table.autoUpdate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get selectedMap => $composableBuilder(
    column: $table.selectedMap,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unfoldSet => $composableBuilder(
    column: $table.unfoldSet,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$Database, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get currentGroupName => $composableBuilder(
    column: $table.currentGroupName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdateDate => $composableBuilder(
    column: $table.lastUpdateDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get autoUpdateDurationMillis => $composableBuilder(
    column: $table.autoUpdateDurationMillis,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SubscriptionInfo?, String>
  get subscriptionInfo => $composableBuilder(
    column: $table.subscriptionInfo,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get autoUpdate => $composableBuilder(
    column: $table.autoUpdate,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Map<String, String>, String>
  get selectedMap => $composableBuilder(
    column: $table.selectedMap,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Set<String>, String> get unfoldSet =>
      $composableBuilder(column: $table.unfoldSet, builder: (column) => column);

  GeneratedColumn<int> get order =>
      $composableBuilder(column: $table.order, builder: (column) => column);
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$Database,
          $ProfilesTable,
          RawProfile,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (RawProfile, BaseReferences<_$Database, $ProfilesTable, RawProfile>),
          RawProfile,
          PrefetchHooks Function()
        > {
  $$ProfilesTableTableManager(_$Database db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String?> currentGroupName = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<DateTime?> lastUpdateDate = const Value.absent(),
                Value<int> autoUpdateDurationMillis = const Value.absent(),
                Value<SubscriptionInfo?> subscriptionInfo =
                    const Value.absent(),
                Value<bool> autoUpdate = const Value.absent(),
                Value<Map<String, String>> selectedMap = const Value.absent(),
                Value<Set<String>> unfoldSet = const Value.absent(),
                Value<int?> order = const Value.absent(),
              }) => ProfilesCompanion(
                id: id,
                label: label,
                currentGroupName: currentGroupName,
                url: url,
                lastUpdateDate: lastUpdateDate,
                autoUpdateDurationMillis: autoUpdateDurationMillis,
                subscriptionInfo: subscriptionInfo,
                autoUpdate: autoUpdate,
                selectedMap: selectedMap,
                unfoldSet: unfoldSet,
                order: order,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String label,
                Value<String?> currentGroupName = const Value.absent(),
                required String url,
                Value<DateTime?> lastUpdateDate = const Value.absent(),
                required int autoUpdateDurationMillis,
                Value<SubscriptionInfo?> subscriptionInfo =
                    const Value.absent(),
                required bool autoUpdate,
                required Map<String, String> selectedMap,
                required Set<String> unfoldSet,
                Value<int?> order = const Value.absent(),
              }) => ProfilesCompanion.insert(
                id: id,
                label: label,
                currentGroupName: currentGroupName,
                url: url,
                lastUpdateDate: lastUpdateDate,
                autoUpdateDurationMillis: autoUpdateDurationMillis,
                subscriptionInfo: subscriptionInfo,
                autoUpdate: autoUpdate,
                selectedMap: selectedMap,
                unfoldSet: unfoldSet,
                order: order,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $ProfilesTable,
      RawProfile,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (RawProfile, BaseReferences<_$Database, $ProfilesTable, RawProfile>),
      RawProfile,
      PrefetchHooks Function()
    >;
typedef $$IconRecordsTableCreateCompanionBuilder =
    IconRecordsCompanion Function({
      required String url,
      required int lastAccessed,
      Value<int> rowid,
    });
typedef $$IconRecordsTableUpdateCompanionBuilder =
    IconRecordsCompanion Function({
      Value<String> url,
      Value<int> lastAccessed,
      Value<int> rowid,
    });

class $$IconRecordsTableFilterComposer
    extends Composer<_$Database, $IconRecordsTable> {
  $$IconRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastAccessed => $composableBuilder(
    column: $table.lastAccessed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IconRecordsTableOrderingComposer
    extends Composer<_$Database, $IconRecordsTable> {
  $$IconRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastAccessed => $composableBuilder(
    column: $table.lastAccessed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IconRecordsTableAnnotationComposer
    extends Composer<_$Database, $IconRecordsTable> {
  $$IconRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<int> get lastAccessed => $composableBuilder(
    column: $table.lastAccessed,
    builder: (column) => column,
  );
}

class $$IconRecordsTableTableManager
    extends
        RootTableManager<
          _$Database,
          $IconRecordsTable,
          IconRecord,
          $$IconRecordsTableFilterComposer,
          $$IconRecordsTableOrderingComposer,
          $$IconRecordsTableAnnotationComposer,
          $$IconRecordsTableCreateCompanionBuilder,
          $$IconRecordsTableUpdateCompanionBuilder,
          (
            IconRecord,
            BaseReferences<_$Database, $IconRecordsTable, IconRecord>,
          ),
          IconRecord,
          PrefetchHooks Function()
        > {
  $$IconRecordsTableTableManager(_$Database db, $IconRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IconRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IconRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IconRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> url = const Value.absent(),
                Value<int> lastAccessed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IconRecordsCompanion(
                url: url,
                lastAccessed: lastAccessed,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String url,
                required int lastAccessed,
                Value<int> rowid = const Value.absent(),
              }) => IconRecordsCompanion.insert(
                url: url,
                lastAccessed: lastAccessed,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IconRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $IconRecordsTable,
      IconRecord,
      $$IconRecordsTableFilterComposer,
      $$IconRecordsTableOrderingComposer,
      $$IconRecordsTableAnnotationComposer,
      $$IconRecordsTableCreateCompanionBuilder,
      $$IconRecordsTableUpdateCompanionBuilder,
      (IconRecord, BaseReferences<_$Database, $IconRecordsTable, IconRecord>),
      IconRecord,
      PrefetchHooks Function()
    >;

class $DatabaseManager {
  final _$Database _db;
  $DatabaseManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$IconRecordsTableTableManager get iconRecords =>
      $$IconRecordsTableTableManager(_db, _db.iconRecords);
}

mixin _$ProfilesDaoMixin on DatabaseAccessor<Database> {
  $ProfilesTable get profiles => attachedDatabase.profiles;
  ProfilesDaoManager get managers => ProfilesDaoManager(this);
}

class ProfilesDaoManager {
  final _$ProfilesDaoMixin _db;
  ProfilesDaoManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
}

mixin _$IconRecordsDaoMixin on DatabaseAccessor<Database> {
  $IconRecordsTable get iconRecords => attachedDatabase.iconRecords;
  IconRecordsDaoManager get managers => IconRecordsDaoManager(this);
}

class IconRecordsDaoManager {
  final _$IconRecordsDaoMixin _db;
  IconRecordsDaoManager(this._db);
  $$IconRecordsTableTableManager get iconRecords =>
      $$IconRecordsTableTableManager(_db.attachedDatabase, _db.iconRecords);
}
