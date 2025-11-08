import 'dart:math';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/preset.dart';

abstract class PresetRepository {
  Future<List<Preset>> listPresets();
  Future<Preset> savePreset({required String name, required List<double> positions});
  Future<Preset> updatePreset({required String id, String? name, List<double>? positions});
  Future<void> deletePreset({required String id});
  Future<Preset?> loadPresetById(String id);
  Future<bool> existsByName(String name);
}

class HivePresetRepository implements PresetRepository {
  static const String _boxName = 'presets';

  Box<dynamic> get _box => Hive.box(_boxName);

  @override
  Future<List<Preset>> listPresets() async {
    final keys = _box.keys;
    final presets = <Preset>[];
    for (final key in keys) {
      final raw = _box.get(key);
      if (raw is Map) {
        try {
          presets.add(Preset.fromJson(Map<String, dynamic>.from(raw)));
        } catch (_) {
          // Skip corrupted entries gracefully
          continue;
        }
      }
    }
    // Sort by updatedAt desc
    presets.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return presets;
  }

  @override
  Future<Preset?> loadPresetById(String id) async {
    final raw = _box.get(id);
    if (raw is Map) {
      try {
        return Preset.fromJson(Map<String, dynamic>.from(raw));
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  @override
  Future<Preset> savePreset({required String name, required List<double> positions}) async {
    _validatePositions(positions);
    final now = DateTime.now();
    final id = _generateId();
    final checksum = Preset.computeChecksum(
      id: id,
      name: name,
      positions: positions,
      version: 1,
      createdAt: now,
      updatedAt: now,
    );
    final preset = Preset(
      id: id,
      name: name,
      positions: positions,
      version: 1,
      createdAt: now,
      updatedAt: now,
      checksum: checksum,
    );
    await _box.put(id, preset.toJson());
    return preset;
  }

  @override
  Future<Preset> updatePreset({required String id, String? name, List<double>? positions}) async {
    final existing = await loadPresetById(id);
    if (existing == null) {
      throw StateError('Preset not found');
    }
    final newPositions = positions ?? existing.positions;
    _validatePositions(newPositions);
    final newName = name ?? existing.name;
    final updatedAt = DateTime.now();
    final version = existing.version + 1;
    final checksum = Preset.computeChecksum(
      id: id,
      name: newName,
      positions: newPositions,
      version: version,
      createdAt: existing.createdAt,
      updatedAt: updatedAt,
    );
    final updated = existing.copyWith(
      name: newName,
      positions: newPositions,
      version: version,
      updatedAt: updatedAt,
      checksum: checksum,
    );
    await _box.put(id, updated.toJson());
    return updated;
  }

  @override
  Future<void> deletePreset({required String id}) async {
    await _box.delete(id);
  }

  @override
  Future<bool> existsByName(String name) async {
    final keys = _box.keys;
    for (final key in keys) {
      final raw = _box.get(key);
      if (raw is Map && raw['name'] == name) return true;
    }
    return false;
  }

  void _validatePositions(List<double> positions) {
    if (positions.length != 5) {
      throw ArgumentError('Expected 5 servo positions');
    }
    for (final v in positions) {
      if (v < 0 || v > 180) {
        throw ArgumentError('Servo angle out of range: $v');
      }
    }
  }

  String _generateId() {
    // Simple unique id based on time and random
    final millis = DateTime.now().millisecondsSinceEpoch;
    final rand = Random().nextInt(1 << 32);
    return 'p_${millis}_$rand';
  }
}