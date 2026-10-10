import 'dart:async';

import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/database/database.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/database.g.dart';

Future<void> withRollback<T>({
  required T snapshot,
  required FutureOr<void> Function() action,
  required void Function(T snapshot) rollback,
}) async {
  try {
    await action();
  } catch (e, s) {
    rollback(snapshot);
    Error.throwWithStackTrace(e, s);
  }
}

Future<void> _persistOptimistically<T>(
  T previous,
  T next,
  T Function() read,
  void Function(T value) write,
  FutureOr<void> Function() action,
) async {
  write(next);
  try {
    await action();
  } catch (e, s) {
    if (identical(read(), next)) {
      write(previous);
    }
    Error.throwWithStackTrace(e, s);
  }
}

void _reportOptimisticFailure(Object error, StackTrace stackTrace) {
  commonPrint.log(
    'Optimistic database write failed: ${compactError(error)}, $stackTrace',
    logLevel: LogLevel.warning,
  );
  dialogs.showNotifier(
    currentAppLocalizations.databaseWriteFailedTip,
    level: MessageLevel.error,
  );
}

mixin OptimisticMixin<T> on AsyncNotifierMixin<T> {
  void optimistic(T next, FutureOr<void> Function() action) {
    unawaited(
      optimisticAsync(next, action).catchError(_reportOptimisticFailure),
    );
  }

  Future<void> optimisticAsync(T next, FutureOr<void> Function() action) {
    return _persistOptimistically(
      value,
      next,
      () => value,
      (v) => value = v,
      action,
    );
  }
}

@riverpod
Stream<List<Profile>> profilesStream(Ref ref) {
  return database.profilesDao.query().watch();
}

@Riverpod(keepAlive: true)
class Profiles extends _$Profiles {
  @override
  List<Profile> build() {
    return ref.watch(profilesStreamProvider).value ?? [];
  }

  void _optimistic(List<Profile> next, FutureOr<void> Function() action) {
    unawaited(
      _optimisticAsync(next, action).catchError(_reportOptimisticFailure),
    );
  }

  Future<void> _optimisticAsync(
    List<Profile> next,
    FutureOr<void> Function() action,
  ) {
    return _persistOptimistically(
      state,
      next,
      () => state,
      (v) => state = v,
      action,
    );
  }

  Profile labeled(Profile profile) => state.optimizeLabel(profile);

  void put(Profile profile) {
    final newProfile = labeled(profile);
    _optimistic(
      state.copyAndPut(newProfile, (item) => item.id == newProfile.id),
      () => database.profiles.put(newProfile.toCompanion()),
    );
  }

  Future<void> del(int id) {
    return _optimisticAsync(
      state.where((e) => e.id != id).toList(),
      () => database.deleteProfile(id),
    );
  }

  void updateProfile(int profileId, Profile Function(Profile profile) builder) {
    final index = state.indexWhere((element) => element.id == profileId);
    if (index == -1) return;
    final newProfile = builder(state[index]);
    final next = List<Profile>.from(state);
    next[index] = newProfile;
    _optimistic(next, () => database.profiles.put(newProfile.toCompanion()));
  }

  void setAndReorder(List<Profile> profiles) {
    _optimistic(
      List<Profile>.from(profiles),
      () => database.profilesDao.setAll(profiles),
    );
  }

  void reorder(List<Profile> profiles) {
    final next = List<Profile>.from(profiles);
    final needUpdate = <ProfilesCompanion>[];
    next.forEachIndexed((index, item) {
      if (item.order != index) {
        needUpdate.add(item.toCompanion(index));
      }
    });
    _optimistic(next, () => database.profilesDao.putAll(needUpdate));
  }

  @override
  bool updateShouldNotify(List<Profile> previous, List<Profile> next) {
    return !profileListEquality.equals(previous, next);
  }
}
