import 'package:flutter_test/flutter_test.dart';
import 'package:zoclips/features/broll/data/datasources/broll_remote_datasource.dart';
import 'package:zoclips/features/broll/data/models/broll_template_model.dart';
import 'package:zoclips/features/broll/data/models/broll_upload_presign_model.dart';
import 'package:zoclips/features/broll/presentation/cubit/broll_template_cubit.dart';
import 'package:zoclips/features/broll/presentation/cubit/broll_template_state.dart';

class _FakeBrollRemoteDataSource implements BrollRemoteDataSource {
  final Object? loadError;
  final Object? presignError;
  final Object? saveError;
  BrollTemplateModel? lastSaved;
  _FakeBrollRemoteDataSource({
    this.loadError,
    this.presignError,
    this.saveError,
  });

  @override
  Future<BrollTemplateModel> getTemplate() async {
    if (loadError != null) throw loadError!;
    return BrollTemplateModel.defaults();
  }

  @override
  Future<BrollTemplateModel> saveTemplate(BrollTemplateModel template) async {
    if (saveError != null) throw saveError!;
    lastSaved = template;
    return template.copyWith();
  }

  @override
  Future<BrollUploadPresignModel> presignUpload({
    required String filename,
    required String contentType,
  }) async {
    if (presignError != null) throw presignError!;
    return BrollUploadPresignModel(
      uploadUrl: 'https://example.com/upload?sig=abc',
      storageKey: 'broll/user-1/$filename',
      expiresIn: 3600,
    );
  }

  @override
  Future<void> uploadToPresignedUrl({
    required String uploadUrl,
    required List<int> bytes,
    required String contentType,
  }) async {}
}

void main() {
  test('load fetches the saved template', () async {
    final cubit = BrollTemplateCubit(_FakeBrollRemoteDataSource());
    addTearDown(cubit.close);

    await cubit.load();

    expect(cubit.state.status, BrollPageStatus.loaded);
    expect(cubit.state.template.position, 'bottom-right');
  });

  test('load emits an error state on failure', () async {
    final cubit = BrollTemplateCubit(
      _FakeBrollRemoteDataSource(loadError: Exception('boom')),
    );
    addTearDown(cubit.close);

    await cubit.load();

    expect(cubit.state.status, BrollPageStatus.error);
    expect(cubit.state.errorMessage, isNotNull);
  });

  test('setters update the draft template', () async {
    final cubit = BrollTemplateCubit(_FakeBrollRemoteDataSource());
    addTearDown(cubit.close);
    await cubit.load();

    cubit.setEnabled(true);
    cubit.setPosition('top-left');
    cubit.setSizePreset('custom');
    cubit.setCustomWidth(40);
    cubit.setOpacity(70);
    cubit.setBorderRadius(24);
    cubit.setShowBorder(false);
    cubit.setBorderColor('#000000');

    expect(cubit.state.template.enabled, isTrue);
    expect(cubit.state.template.position, 'top-left');
    expect(cubit.state.template.sizePreset, 'custom');
    expect(cubit.state.template.customWidth, 40);
    expect(cubit.state.template.opacity, 70);
    expect(cubit.state.template.borderRadius, 24);
    expect(cubit.state.template.showBorder, isFalse);
    expect(cubit.state.template.borderColor, '#000000');
  });

  test('uploadMedia presigns, uploads, and stores the active asset', () async {
    final dataSource = _FakeBrollRemoteDataSource();
    final cubit = BrollTemplateCubit(dataSource);
    addTearDown(cubit.close);
    await cubit.load();

    await cubit.uploadMedia(
      filename: 'overlay.webp',
      bytes: [1, 2, 3],
      localPath: '/tmp/overlay.webp',
    );

    expect(cubit.state.uploading, isFalse);
    expect(cubit.state.uploadError, isNull);
    expect(cubit.state.localAssetPreviewPath, '/tmp/overlay.webp');
    expect(cubit.state.template.activeAsset, 'broll/user-1/overlay.webp');
  });

  test('uploadMedia surfaces an error when the presign call fails', () async {
    final cubit = BrollTemplateCubit(
      _FakeBrollRemoteDataSource(presignError: Exception('boom')),
    );
    addTearDown(cubit.close);
    await cubit.load();

    await cubit.uploadMedia(
      filename: 'overlay.webp',
      bytes: [1, 2, 3],
      localPath: '/tmp/overlay.webp',
    );

    expect(cubit.state.uploading, isFalse);
    expect(cubit.state.uploadError, isNotNull);
    expect(cubit.state.template.activeAsset, isNull);
  });

  test('save sends the draft template and returns true on success', () async {
    final dataSource = _FakeBrollRemoteDataSource();
    final cubit = BrollTemplateCubit(dataSource);
    addTearDown(cubit.close);
    await cubit.load();
    cubit.setEnabled(true);
    cubit.setPosition('top-right');

    final success = await cubit.save();

    expect(success, isTrue);
    expect(cubit.state.saving, isFalse);
    expect(dataSource.lastSaved?.position, 'top-right');
  });

  test('save returns false on failure', () async {
    final cubit = BrollTemplateCubit(
      _FakeBrollRemoteDataSource(saveError: Exception('boom')),
    );
    addTearDown(cubit.close);
    await cubit.load();

    final success = await cubit.save();

    expect(success, isFalse);
    expect(cubit.state.saving, isFalse);
  });

  test(
    'resetToDefaults restores the default template and clears preview',
    () async {
      final cubit = BrollTemplateCubit(_FakeBrollRemoteDataSource());
      addTearDown(cubit.close);
      await cubit.load();
      cubit.setEnabled(true);
      cubit.setPosition('top-left');
      cubit.setOpacity(50);

      cubit.resetToDefaults();

      expect(cubit.state.template.enabled, isFalse);
      expect(cubit.state.template.position, 'bottom-right');
      expect(cubit.state.template.opacity, 90);
      expect(cubit.state.localAssetPreviewPath, isNull);
    },
  );
}
