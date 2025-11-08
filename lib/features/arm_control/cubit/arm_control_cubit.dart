import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../features/bluetooth/data/bluetooth_repository.dart';

part 'arm_control_state.dart';

@injectable
class ArmControlCubit extends Cubit<ArmControlState> {
  final BluetoothRepository _bluetoothRepository;

  ArmControlCubit(this._bluetoothRepository)
    : super(const ArmControlState.initial());

  void updateServoPosition(int servoIndex, double angle) {
    if (servoIndex < 0 || servoIndex >= 5) return;

    final currentPositions = [...state.servoPositions];
    currentPositions[servoIndex] = angle;

    emit(
      ArmControlState(
        servoPositions: currentPositions,
        savedPositions: state.savedPositions,
      ),
    );

    _sendServoCommand(servoIndex, angle.round());
  }

  void saveCurrentPosition(String name) {
    final newPosition = ServoPreset(
      name: name,
      positions: List.from(state.servoPositions),
    );

    final updatedPositions = [...state.savedPositions, newPosition];
    emit(
      ArmControlState(
        servoPositions: state.servoPositions,
        savedPositions: updatedPositions,
      ),
    );
  }

  void loadPreset(ServoPreset preset) {
    emit(
      ArmControlState(
        servoPositions: List.from(preset.positions),
        savedPositions: state.savedPositions,
      ),
    );

    // Send commands to all servos
    for (var i = 0; i < preset.positions.length; i++) {
      _sendServoCommand(i, preset.positions[i].round());
    }
  }

  void deletePreset(ServoPreset preset) {
    final updatedPositions = state.savedPositions
        .where((position) => position != preset)
        .toList();

    emit(
      ArmControlState(
        servoPositions: state.servoPositions,
        savedPositions: updatedPositions,
      ),
    );
  }

  void _sendServoCommand(int servoIndex, int angle) {
    final command = [
      0xFF,
      servoIndex,
      angle,
    ]; // Simple protocol: FF <servo_index> <angle>
    _bluetoothRepository.sendData(command);
  }
}
