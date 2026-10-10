// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../database.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(profilesStream)
final profilesStreamProvider = ProfilesStreamProvider._();

final class ProfilesStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Profile>>,
          List<Profile>,
          Stream<List<Profile>>
        >
    with $FutureModifier<List<Profile>>, $StreamProvider<List<Profile>> {
  ProfilesStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profilesStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profilesStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<Profile>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Profile>> create(Ref ref) {
    return profilesStream(ref);
  }
}

String _$profilesStreamHash() => r'ea944e081294567f0f63286e95e4e66cdc650383';

@ProviderFor(Profiles)
final profilesProvider = ProfilesProvider._();

final class ProfilesProvider
    extends $NotifierProvider<Profiles, List<Profile>> {
  ProfilesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profilesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profilesHash();

  @$internal
  @override
  Profiles create() => Profiles();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Profile> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Profile>>(value),
    );
  }
}

String _$profilesHash() => r'1dd5cfe634e3360c5d42176b49acfd8f44f525dc';

abstract class _$Profiles extends $Notifier<List<Profile>> {
  List<Profile> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<Profile>, List<Profile>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Profile>, List<Profile>>,
              List<Profile>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
