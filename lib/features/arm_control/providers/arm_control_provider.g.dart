// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'arm_control_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(bluetoothRepository)
const bluetoothRepositoryProvider = BluetoothRepositoryProvider._();

final class BluetoothRepositoryProvider
    extends
        $FunctionalProvider<
          BluetoothRepository,
          BluetoothRepository,
          BluetoothRepository
        >
    with $Provider<BluetoothRepository> {
  const BluetoothRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bluetoothRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bluetoothRepositoryHash();

  @$internal
  @override
  $ProviderElement<BluetoothRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BluetoothRepository create(Ref ref) {
    return bluetoothRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BluetoothRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BluetoothRepository>(value),
    );
  }
}

String _$bluetoothRepositoryHash() =>
    r'093c3f74458c1bb93d049b9630278e47a72752ce';

@ProviderFor(ArmControl)
const armControlProvider = ArmControlProvider._();

final class ArmControlProvider
    extends $NotifierProvider<ArmControl, ArmControlState> {
  const ArmControlProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'armControlProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$armControlHash();

  @$internal
  @override
  ArmControl create() => ArmControl();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ArmControlState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ArmControlState>(value),
    );
  }
}

String _$armControlHash() => r'140d94dc7607e43b94e064538e7b9bb128bca8b3';

abstract class _$ArmControl extends $Notifier<ArmControlState> {
  ArmControlState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ArmControlState, ArmControlState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ArmControlState, ArmControlState>,
              ArmControlState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
