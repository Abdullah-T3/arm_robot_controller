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
  
  const ArmControlState({
    this.servoPositions = const [90, 45, 120, 75, 10],
    this.savedPositions = const [],
    this.isSending = false,
    this.error,
  });

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
