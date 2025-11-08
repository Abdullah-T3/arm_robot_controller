import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../data/preset_repository.dart';
import '../models/preset.dart';
import 'presets_state.dart';

class PresetsCubit extends Cubit<PresetsState> {
  final PresetRepository _repo;

  // Undo/Redo stacks
  final List<List<Preset>> _past = [];
  final List<List<Preset>> _future = [];

  PresetsCubit(this._repo) : super(PresetsInitial());

  Future<void> load() async {
    emit(PresetsLoading());
    try {
      final items = await _repo.listPresets();
      emit(PresetsLoaded(items));
    } catch (e) {
      emit(PresetsError('Failed to load presets: $e'));
    }
  }

  Future<void> createPreset(String name, List<double> positions) async {
    emit(PresetsLoading());
    try {
      if (await _repo.existsByName(name)) {
        emit(PresetsError('Duplicate preset name'));
        return;
      }
      final saved = await _repo.savePreset(name: name, positions: positions);
      final items = await _repo.listPresets();
      _pushHistory(items);
      emit(PresetsLoaded(items, message: 'Preset "${saved.name}" saved'));
    } catch (e) {
      emit(PresetsError('Failed to save preset: $e'));
    }
  }

  Future<void> updatePreset({required String id, String? name, List<double>? positions}) async {
    emit(PresetsLoading());
    try {
      if (name != null && await _repo.existsByName(name)) {
        emit(PresetsError('Duplicate preset name'));
        return;
      }
      await _repo.updatePreset(id: id, name: name, positions: positions);
      final items = await _repo.listPresets();
      _pushHistory(items);
      emit(PresetsLoaded(items, message: 'Preset updated'));
    } catch (e) {
      emit(PresetsError('Failed to update preset: $e'));
    }
  }

  Future<void> deletePreset(String id) async {
    emit(PresetsLoading());
    try {
      await _repo.deletePreset(id: id);
      final items = await _repo.listPresets();
      _pushHistory(items);
      emit(PresetsLoaded(items, message: 'Preset deleted'));
    } catch (e) {
      emit(PresetsError('Failed to delete preset: $e'));
    }
  }

  Future<Preset?> getById(String id) => _repo.loadPresetById(id);

  void undo() async {
    if (_past.isEmpty) return;
    final current = state is PresetsLoaded ? (state as PresetsLoaded).presets : <Preset>[];
    _future.add(current);
    final previous = _past.removeLast();
    // Rehydrate storage to match previous
    await _rehydrate(previous);
    emit(PresetsLoaded(previous, message: 'Undone'));
  }

  void redo() async {
    if (_future.isEmpty) return;
    final current = state is PresetsLoaded ? (state as PresetsLoaded).presets : <Preset>[];
    _past.add(current);
    final next = _future.removeLast();
    await _rehydrate(next);
    emit(PresetsLoaded(next, message: 'Redone'));
  }

  void _pushHistory(List<Preset> snapshot) {
    final current = state is PresetsLoaded ? (state as PresetsLoaded).presets : <Preset>[];
    _past.add(current);
    _future.clear();
  }

  Future<void> _rehydrate(List<Preset> items) async {
    // Clear and write all presets to storage for integrity with history operations
    final box = Hive.box('presets');
    await box.clear();
    for (final p in items) {
      await box.put(p.id, p.toJson());
    }
  }
}