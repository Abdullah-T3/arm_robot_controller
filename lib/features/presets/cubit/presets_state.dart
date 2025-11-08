import 'package:equatable/equatable.dart';

import '../models/preset.dart';

sealed class PresetsState extends Equatable {
  const PresetsState();

  @override
  List<Object?> get props => [];
}

class PresetsInitial extends PresetsState {}

class PresetsLoading extends PresetsState {}

class PresetsLoaded extends PresetsState {
  final List<Preset> presets;
  final String? message; // success feedback

  const PresetsLoaded(this.presets, {this.message});

  @override
  List<Object?> get props => [presets, message];
}

class PresetsError extends PresetsState {
  final String message;
  const PresetsError(this.message);

  @override
  List<Object?> get props => [message];
}