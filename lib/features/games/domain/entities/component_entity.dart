import 'package:equatable/equatable.dart';

class ComponentEntity extends Equatable {
  const ComponentEntity({
    required this.name,
    required this.count,
    this.description = '',
    this.iconKey,
    this.photoKey,
    this.url,
  });

  final String name;
  final int count;
  final String description;
  final String? iconKey;

  /// Concept key from the photo registry in `BmConceptImage`.
  final String? photoKey;

  /// Direct image URL (e.g. uploaded to Firebase Storage from the admin).
  /// Beats [photoKey] / [iconKey] when set.
  final String? url;

  /// True when the component has any visual (URL, photo key, or icon key).
  /// Drives whether the mobile UI shows an image slot or falls back to a
  /// text-only row.
  bool get hasVisual =>
      (url != null && url!.isNotEmpty) ||
      (photoKey != null && photoKey!.isNotEmpty) ||
      (iconKey != null && iconKey!.isNotEmpty);

  @override
  List<Object?> get props =>
      [name, count, description, iconKey, photoKey, url];
}
