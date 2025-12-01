import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../bluetooth/data/bluetooth_repository.dart';
import '../../bluetooth/providers/bluetooth_provider.dart';
import '../models/arm_control_state.dart';

part 'arm_control_provider.g.dart';

// Provider for BluetoothRepository
@riverpod
BluetoothRepository bluetoothRepository(Ref ref) {
  return BluetoothRepositoryImpl(ref.read(bluetoothClassicProvider));
}

@riverpod
class ArmControl extends Notifier<ArmControlState> {
  @override
  ArmControlState build() {
    return ArmControlState.initial();
  }

  BluetoothRepository get _bluetoothRepository =>
      ref.read(bluetoothRepositoryProvider);

  void updateServoPosition(int servoIndex, double angle) {
    if (servoIndex < 0 || servoIndex >= 4) return;

    final currentPositions = [...state.servoPositions];
    currentPositions[servoIndex] = angle;

    state = state.copyWith(servoPositions: currentPositions, error: null);

    _sendServoCommand(servoIndex, angle.round());
  }

  void saveCurrentPosition(String name) {
    try {
      final newPosition = ServoPreset(
        name: name,
        positions: List.from(state.servoPositions),
      );

      final updatedPositions = [...state.savedPositions, newPosition];
      state = state.copyWith(savedPositions: updatedPositions, error: null);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void loadPreset(ServoPreset preset) {
    try {
      state = state.copyWith(
        servoPositions: List.from(preset.positions),
        isSending: true,
        error: null,
      );

      // Send commands to all servos
      for (var i = 0; i < preset.positions.length; i++) {
        _sendServoCommand(i, preset.positions[i].round());
      }

      state = state.copyWith(isSending: false);
    } catch (e) {
      state = state.copyWith(isSending: false, error: e.toString());
    }
  }

  void deletePreset(ServoPreset preset) {
    try {
      final updatedPositions = state.savedPositions
          .where((position) => position != preset)
          .toList();

      state = state.copyWith(savedPositions: updatedPositions, error: null);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void _sendServoCommand(int servoIndex, int angle) {
    try {
      var sentAngle = angle;

      final command = [
        0xFF,
        servoIndex,
        sentAngle,
      ]; // Simple protocol: FF <servo_index> <angle>
      _bluetoothRepository.sendData(command);
    } catch (e) {
      state = state.copyWith(error: 'Failed to send command: ${e.toString()}');
    }
  }
}
