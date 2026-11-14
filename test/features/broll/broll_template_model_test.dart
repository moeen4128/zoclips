import 'package:flutter_test/flutter_test.dart';
import 'package:zoclips/features/broll/data/models/broll_template_model.dart';

void main() {
  test('parses a real GET /broll/template response', () {
    final template = BrollTemplateModel.fromJson({
      'id': '18991d1a-d7d0-44ba-8a14-f38ebed29b76',
      'enabled': false,
      'active_asset': null,
      'position': 'bottom-right',
      'size_preset': 'medium',
      'custom_width': 25,
      'custom_height': 25,
      'opacity': 90,
      'border_radius': 12,
      'show_border': true,
      'border_color': '#ffffff',
      'updated_at': '2026-07-16T20:43:25.260158Z',
    });

    expect(template.enabled, isFalse);
    expect(template.position, 'bottom-right');
    expect(template.sizePreset, 'medium');
    expect(template.opacity, 90);
    expect(template.borderRadius, 12);
    expect(template.showBorder, isTrue);
    expect(template.borderColor, '#ffffff');
  });

  test('parses a real PATCH /broll/template response', () {
    final template = BrollTemplateModel.fromJson({
      'id': '18991d1a-d7d0-44ba-8a14-f38ebed29b76',
      'enabled': true,
      'active_asset': null,
      'position': 'bottom-right',
      'size_preset': 'medium',
      'custom_width': 25,
      'custom_height': 25,
      'opacity': 100,
      'border_radius': 20,
      'show_border': true,
      'border_color': 'var(--info-color)',
      'updated_at': '2026-10-11T10:35:15.553238Z',
    });

    expect(template.enabled, isTrue);
    expect(template.opacity, 100);
    expect(template.borderRadius, 20);
    expect(template.borderColor, 'var(--info-color)');
  });

  test('toJson round-trips the fields the PATCH endpoint expects', () {
    const template = BrollTemplateModel(
      enabled: true,
      activeAsset: 'broll/user/asset.webp',
      position: 'top-left',
      sizePreset: 'small',
      customWidth: 20,
      customHeight: 20,
      opacity: 80,
      borderRadius: 8,
      showBorder: false,
      borderColor: '#000000',
    );

    final json = template.toJson();

    expect(json['enabled'], true);
    expect(json['active_asset'], 'broll/user/asset.webp');
    expect(json['position'], 'top-left');
    expect(json['size_preset'], 'small');
    expect(json['show_border'], false);
    expect(json.containsKey('id'), isFalse); // server-assigned, never sent
  });

  group('sizeFraction', () {
    test('maps each preset to its documented frame fraction', () {
      const base = BrollTemplateModel(
        enabled: true,
        position: 'bottom-right',
        sizePreset: 'small',
        customWidth: 25,
        customHeight: 25,
        opacity: 90,
        borderRadius: 12,
        showBorder: true,
        borderColor: '#ffffff',
      );

      expect(base.sizeFraction, 0.20);
      expect(base.copyWith(sizePreset: 'medium').sizeFraction, 0.30);
      expect(base.copyWith(sizePreset: 'large').sizeFraction, 0.40);
    });

    test('custom preset derives from customWidth', () {
      const template = BrollTemplateModel(
        enabled: true,
        position: 'bottom-right',
        sizePreset: 'custom',
        customWidth: 35,
        customHeight: 35,
        opacity: 90,
        borderRadius: 12,
        showBorder: true,
        borderColor: '#ffffff',
      );

      expect(template.sizeFraction, 0.35);
    });
  });
}
