/// Mirrors the full `GET /api/v1/broll/template` / `PATCH
/// /api/v1/broll/template` payload — the persistent overlay template
/// applied to every generated clip.
class BrollTemplateModel {
  final String? id;
  final bool enabled;
  final String? activeAsset;
  final String position;
  final String sizePreset;
  final double customWidth;
  final double customHeight;
  final int opacity;
  final int borderRadius;
  final bool showBorder;
  final String borderColor;
  final DateTime? updatedAt;

  const BrollTemplateModel({
    this.id,
    required this.enabled,
    this.activeAsset,
    required this.position,
    required this.sizePreset,
    required this.customWidth,
    required this.customHeight,
    required this.opacity,
    required this.borderRadius,
    required this.showBorder,
    required this.borderColor,
    this.updatedAt,
  });

  /// The real defaults returned by a fresh `GET /broll/template`.
  factory BrollTemplateModel.defaults() => const BrollTemplateModel(
    enabled: false,
    position: 'bottom-right',
    sizePreset: 'medium',
    customWidth: 25,
    customHeight: 25,
    opacity: 90,
    borderRadius: 12,
    showBorder: true,
    borderColor: '#ffffff',
  );

  factory BrollTemplateModel.fromJson(Map<String, dynamic> json) {
    return BrollTemplateModel(
      id: json['id'] as String?,
      enabled: json['enabled'] as bool? ?? false,
      activeAsset: json['active_asset'] as String?,
      position: json['position'] as String? ?? 'bottom-right',
      sizePreset: json['size_preset'] as String? ?? 'medium',
      customWidth: (json['custom_width'] as num?)?.toDouble() ?? 25,
      customHeight: (json['custom_height'] as num?)?.toDouble() ?? 25,
      opacity: (json['opacity'] as num?)?.toInt() ?? 90,
      borderRadius: (json['border_radius'] as num?)?.toInt() ?? 12,
      showBorder: json['show_border'] as bool? ?? true,
      borderColor: json['border_color'] as String? ?? '#ffffff',
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'active_asset': activeAsset,
    'position': position,
    'size_preset': sizePreset,
    'custom_width': customWidth,
    'custom_height': customHeight,
    'opacity': opacity,
    'border_radius': borderRadius,
    'show_border': showBorder,
    'border_color': borderColor,
  };

  BrollTemplateModel copyWith({
    bool? enabled,
    String? activeAsset,
    String? position,
    String? sizePreset,
    double? customWidth,
    double? customHeight,
    int? opacity,
    int? borderRadius,
    bool? showBorder,
    String? borderColor,
  }) {
    return BrollTemplateModel(
      id: id,
      enabled: enabled ?? this.enabled,
      activeAsset: activeAsset ?? this.activeAsset,
      position: position ?? this.position,
      sizePreset: sizePreset ?? this.sizePreset,
      customWidth: customWidth ?? this.customWidth,
      customHeight: customHeight ?? this.customHeight,
      opacity: opacity ?? this.opacity,
      borderRadius: borderRadius ?? this.borderRadius,
      showBorder: showBorder ?? this.showBorder,
      borderColor: borderColor ?? this.borderColor,
      updatedAt: updatedAt,
    );
  }

  /// Fraction of the video frame each size preset occupies.
  double get sizeFraction => switch (sizePreset) {
    'small' => 0.20,
    'medium' => 0.30,
    'large' => 0.40,
    'custom' => (customWidth / 100).clamp(0.05, 1.0),
    _ => 0.30,
  };
}
