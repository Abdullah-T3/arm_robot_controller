class ServoPreset {
  final String name;
  final List<double> positions;

  const ServoPreset({required this.name, required this.positions});
}

class ArmControlState {
  final List<double> servoPositions;
  final List<ServoPreset> savedPositions;
  final bool isSending;
  final String? error;

  // Joint Limits
  static const double baseMin = 0;
  static const double baseMax = 180;
  static const double shoulderMin = 90;
  static const double shoulderMax = 180;
  static const double wristMin = 0;
  static const double wristMax = 180;
  static const double gripperMin = 15;
  static const double gripperMax = 55;

  const ArmControlState({
    this.servoPositions = const [180, 180, 90, 55],
    this.savedPositions = const [],
    this.isSending = false,
    this.error,
  });

  factory ArmControlState.initial() => const ArmControlState();

  ArmControlState copyWith({
    List<double>? servoPositions,
    List<ServoPreset>? savedPositions,
    bool? isSending,
    String? error,
  }) {
    return ArmControlState(
      servoPositions: servoPositions ?? this.servoPositions,
      savedPositions: savedPositions ?? this.savedPositions,
      isSending: isSending ?? this.isSending,
      error: error ?? this.error,
    );
  }
}
