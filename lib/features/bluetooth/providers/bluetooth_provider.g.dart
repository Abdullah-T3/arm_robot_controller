// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bluetooth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(bluetoothClassic)
const bluetoothClassicProvider = BluetoothClassicProvider._();

final class BluetoothClassicProvider
    extends
        $FunctionalProvider<
          BluetoothClassic,
          BluetoothClassic,
          BluetoothClassic
        >
    with $Provider<BluetoothClassic> {
  const BluetoothClassicProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bluetoothClassicProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bluetoothClassicHash();

  @$internal
  @override
  $ProviderElement<BluetoothClassic> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BluetoothClassic create(Ref ref) {
    return bluetoothClassic(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BluetoothClassic value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BluetoothClassic>(value),
    );
  }
}

String _$bluetoothClassicHash() => r'bb21fa369ed89dffc6f188adafad16fd2772f687';

@ProviderFor(Bluetooth)
const bluetoothProvider = BluetoothProvider._();

final class BluetoothProvider
    extends $NotifierProvider<Bluetooth, BluetoothState> {
  const BluetoothProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bluetoothProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bluetoothHash();

  @$internal
  @override
  Bluetooth create() => Bluetooth();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BluetoothState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BluetoothState>(value),
    );
  }
}

String _$bluetoothHash() => r'9e97ac6ede73f329e7f25fa78125798060de64c6';

abstract class _$Bluetooth extends $Notifier<BluetoothState> {
  BluetoothState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<BluetoothState, BluetoothState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BluetoothState, BluetoothState>,
              BluetoothState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
