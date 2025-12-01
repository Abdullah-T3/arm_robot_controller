import '../models/preset.dart';

sealed class PresetsState {
  const PresetsState();

  factory PresetsState.initial() => const PresetsInitial();
  factory PresetsState.loading() => const PresetsLoading();
  factory PresetsState.loaded({
    required List<Preset> presets,
    String? message,
    bool canUndo = false,
    bool canRedo = false,
  }) => PresetsLoaded(
    presets: presets,
    message: message,
    canUndo: canUndo,
    canRedo: canRedo,
  );
  factory PresetsState.error(String message) => PresetsError(message);

  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(
      List<Preset> presets,
      String? message,
      bool canUndo,
      bool canRedo,
    )
    loaded,
    required T Function(String message) error,
  }) {
    final state = this;
    if (state is PresetsInitial) return initial();
    if (state is PresetsLoading) return loading();
    if (state is PresetsLoaded) {
      return loaded(state.presets, state.message, state.canUndo, state.canRedo);
    }
    if (state is PresetsError) return error(state.message);
    throw Exception('Unknown PresetsState: $state');
  }

  T? whenOrNull<T>({
    T Function()? initial,
    T Function()? loading,
    T Function(
      List<Preset> presets,
      String? message,
      bool canUndo,
      bool canRedo,
    )?
    loaded,
    T Function(String message)? error,
  }) {
    final state = this;
    if (state is PresetsInitial && initial != null) return initial();
    if (state is PresetsLoading && loading != null) return loading();
    if (state is PresetsLoaded && loaded != null) {
      return loaded(state.presets, state.message, state.canUndo, state.canRedo);
    }
    if (state is PresetsError && error != null) return error(state.message);
    return null;
  }
}

class PresetsInitial extends PresetsState {
  const PresetsInitial();
}

class PresetsLoading extends PresetsState {
  const PresetsLoading();
}

class PresetsLoaded extends PresetsState {
  final List<Preset> presets;
  final String? message;
  final bool canUndo;
  final bool canRedo;

  const PresetsLoaded({
    required this.presets,
    this.message,
    this.canUndo = false,
    this.canRedo = false,
  });
}

class PresetsError extends PresetsState {
  final String message;
  const PresetsError(this.message);
}
