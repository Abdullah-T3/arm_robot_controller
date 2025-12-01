import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/preset_repository.dart';
import '../models/preset.dart';
import '../models/presets_state.dart';

part 'presets_provider.g.dart';

// Provider for PresetRepository
@riverpod
PresetRepository presetRepository(Ref ref) {
  return HivePresetRepository();
}

@riverpod
class Presets extends _$Presets {
  // Undo/Redo stacks
  final List<List<Preset>> _past = [];
  final List<List<Preset>> _future = [];

  @override
  PresetsState build() {
    return PresetsState.initial();
  }

  PresetRepository get _repo => ref.read(presetRepositoryProvider);

  Future<void> load() async {
    state = PresetsState.loading();
    try {
      final items = await _repo.listPresets();
      state = PresetsState.loaded(
        presets: items,
        canUndo: _past.isNotEmpty,
        canRedo: _future.isNotEmpty,
      );
    } catch (e) {
      state = PresetsState.error('Failed to load presets: $e');
    }
  }

  Future<void> createPreset(String name, List<double> positions) async {
    state = PresetsState.loading();
    try {
      if (await _repo.existsByName(name)) {
        state = PresetsState.error('Duplicate preset name');
        return;
      }
      final saved = await _repo.savePreset(name: name, positions: positions);
      final items = await _repo.listPresets();
      _pushHistory(items);
      state = PresetsState.loaded(
        presets: items,
        message: 'Preset "${saved.name}" saved',
        canUndo: _past.isNotEmpty,
        canRedo: _future.isNotEmpty,
      );
    } catch (e) {
      state = PresetsState.error('Failed to save preset: $e');
    }
  }

  Future<void> updatePreset({
    required String id,
    String? name,
    List<double>? positions,
  }) async {
    state = PresetsState.loading();
    try {
      if (name != null && await _repo.existsByName(name)) {
        state = PresetsState.error('Duplicate preset name');
        return;
      }
      await _repo.updatePreset(id: id, name: name, positions: positions);
      final items = await _repo.listPresets();
      _pushHistory(items);
      state = PresetsState.loaded(
        presets: items,
        message: 'Preset updated',
        canUndo: _past.isNotEmpty,
        canRedo: _future.isNotEmpty,
      );
    } catch (e) {
      state = PresetsState.error('Failed to update preset: $e');
    }
  }

  Future<void> deletePreset(String id) async {
    state = PresetsState.loading();
    try {
      await _repo.deletePreset(id: id);
      final items = await _repo.listPresets();
      _pushHistory(items);
      state = PresetsState.loaded(
        presets: items,
        message: 'Preset deleted',
        canUndo: _past.isNotEmpty,
        canRedo: _future.isNotEmpty,
      );
    } catch (e) {
      state = PresetsState.error('Failed to delete preset: $e');
    }
  }

  Future<Preset?> getById(String id) => _repo.loadPresetById(id);

  Future<void> undo() async {
    if (_past.isEmpty) return;

    state.whenOrNull(
      loaded: (presets, _, __, ___) {
        _future.add(presets);
      },
    );

    final previous = _past.removeLast();
    // Rehydrate storage to match previous
    await _rehydrate(previous);
    state = PresetsState.loaded(
      presets: previous,
      message: 'Undone',
      canUndo: _past.isNotEmpty,
      canRedo: _future.isNotEmpty,
    );
  }

  Future<void> redo() async {
    if (_future.isEmpty) return;

    state.whenOrNull(
      loaded: (presets, _, __, ___) {
        _past.add(presets);
      },
    );

    final next = _future.removeLast();
    await _rehydrate(next);
    state = PresetsState.loaded(
      presets: next,
      message: 'Redone',
      canUndo: _past.isNotEmpty,
      canRedo: _future.isNotEmpty,
    );
  }

  void _pushHistory(List<Preset> snapshot) {
    state.whenOrNull(
      loaded: (presets, _, __, ___) {
        _past.add(presets);
      },
    );
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
