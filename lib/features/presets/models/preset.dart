import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:crypto/crypto.dart';

class Preset extends Equatable {
  final String id;
  final String name;
  final List<double> positions; // expected length: 4
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String checksum;

  const Preset({
    required this.id,
    required this.name,
    required this.positions,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.checksum,
  });

  static String computeChecksum({
    required String id,
    required String name,
    required List<double> positions,
    required int version,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) {
    final payload = jsonEncode({
      'id': id,
      'name': name,
      'positions': positions,
      'version': version,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    });
    return sha1.convert(utf8.encode(payload)).toString();
  }

  Preset copyWith({
    String? id,
    String? name,
    List<double>? positions,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? checksum,
  }) {
    final updated = Preset(
      id: id ?? this.id,
      name: name ?? this.name,
      positions: positions ?? this.positions,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      checksum: checksum ?? this.checksum,
    );
    return updated;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'positions': positions,
    'version': version,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'checksum': checksum,
  };

  static Preset fromJson(Map<String, dynamic> json) {
    final positions = (json['positions'] as List)
        .map((e) => (e as num).toDouble())
        .toList();
    final id = json['id'] as String;
    final name = json['name'] as String;
    final version = json['version'] as int;
    final createdAt = DateTime.parse(json['createdAt'] as String);
    final updatedAt = DateTime.parse(json['updatedAt'] as String);
    final checksum = json['checksum'] as String;

    // Recompute and verify checksum
    final expected = computeChecksum(
      id: id,
      name: name,
      positions: positions,
      version: version,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );

    if (expected != checksum) {
      throw const FormatException('Preset integrity check failed');
    }

    return Preset(
      id: id,
      name: name,
      positions: positions,
      version: version,
      createdAt: createdAt,
      updatedAt: updatedAt,
      checksum: checksum,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    positions,
    version,
    createdAt,
    updatedAt,
    checksum,
  ];
}
