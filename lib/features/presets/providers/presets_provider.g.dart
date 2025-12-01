// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presets_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(presetRepository)
const presetRepositoryProvider = PresetRepositoryProvider._();

final class PresetRepositoryProvider
    extends
        $FunctionalProvider<
          PresetRepository,
          PresetRepository,
          PresetRepository
        >
    with $Provider<PresetRepository> {
  const PresetRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'presetRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$presetRepositoryHash();

  @$internal
  @override
  $ProviderElement<PresetRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PresetRepository create(Ref ref) {
    return presetRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PresetRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PresetRepository>(value),
    );
  }
}

String _$presetRepositoryHash() => r'a4ea548bc6de695de174a0f0e6a071f61a4cfdf5';

@ProviderFor(Presets)
const presetsProvider = PresetsProvider._();

final class PresetsProvider extends $NotifierProvider<Presets, PresetsState> {
  const PresetsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'presetsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$presetsHash();

  @$internal
  @override
  Presets create() => Presets();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PresetsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PresetsState>(value),
    );
  }
}

String _$presetsHash() => r'16145e3ff591454a4b465a6ccfe78e8e4a8a14c3';

abstract class _$Presets extends $Notifier<PresetsState> {
  PresetsState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<PresetsState, PresetsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PresetsState, PresetsState>,
              PresetsState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
