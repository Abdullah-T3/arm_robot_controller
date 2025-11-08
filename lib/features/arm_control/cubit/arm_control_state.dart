part of 'arm_control_cubit.dart';

class ServoPreset extends Equatable {
  final String name;
  final List<double> positions;

  const ServoPreset({required this.name, required this.positions});

  @override
  List<Object?> get props => [name, positions];
}

class ArmControlState extends Equatable {
  final List<double> servoPositions;
  final List<ServoPreset> savedPositions;

  const ArmControlState({
    this.servoPositions = const [90, 45, 120, 75, 10],
    this.savedPositions = const [],
  });

  const ArmControlState.initial()
    : servoPositions = const [90, 45, 120, 75, 10],
      savedPositions = const [];

  @override
  List<Object?> get props => [servoPositions, savedPositions];
}
