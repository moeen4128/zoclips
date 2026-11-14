import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/broll_remote_datasource.dart';
import '../../data/models/broll_template_model.dart';
import 'broll_template_state.dart';

class BrollTemplateCubit extends Cubit<BrollTemplateState> {
  final BrollRemoteDataSource dataSource;

  BrollTemplateCubit(this.dataSource)
    : super(const BrollTemplateState.initial());

  Future<void> load() async {
    emit(state.copyWith(status: BrollPageStatus.loading));
    try {
      final template = await dataSource.getTemplate();
      emit(state.copyWith(status: BrollPageStatus.loaded, template: template));
    } catch (_) {
      emit(
        state.copyWith(
          status: BrollPageStatus.error,
          errorMessage: 'Could not load your B-Roll template. Try again.',
        ),
      );
    }
  }

  void setEnabled(bool enabled) =>
      emit(state.copyWith(template: state.template.copyWith(enabled: enabled)));

  void setPosition(String position) => emit(
    state.copyWith(template: state.template.copyWith(position: position)),
  );

  void setSizePreset(String preset) => emit(
    state.copyWith(template: state.template.copyWith(sizePreset: preset)),
  );

  void setCustomWidth(double width) => emit(
    state.copyWith(template: state.template.copyWith(customWidth: width)),
  );

  void setCustomHeight(double height) => emit(
    state.copyWith(template: state.template.copyWith(customHeight: height)),
  );

  void setOpacity(int opacity) =>
      emit(state.copyWith(template: state.template.copyWith(opacity: opacity)));

  void setBorderRadius(int radius) => emit(
    state.copyWith(template: state.template.copyWith(borderRadius: radius)),
  );

  void setShowBorder(bool show) =>
      emit(state.copyWith(template: state.template.copyWith(showBorder: show)));

  void setBorderColor(String color) => emit(
    state.copyWith(template: state.template.copyWith(borderColor: color)),
  );

  Future<void> uploadMedia({
    required String filename,
    required List<int> bytes,
    required String localPath,
  }) async {
    emit(state.copyWith(uploading: true, clearUploadError: true));
    try {
      final contentType = _contentTypeFor(filename);
      final presign = await dataSource.presignUpload(
        filename: filename,
        contentType: contentType,
      );
      await dataSource.uploadToPresignedUrl(
        uploadUrl: presign.uploadUrl,
        bytes: bytes,
        contentType: contentType,
      );
      emit(
        state.copyWith(
          uploading: false,
          localAssetPreviewPath: localPath,
          template: state.template.copyWith(activeAsset: presign.storageKey),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          uploading: false,
          uploadError: 'Could not upload media. Please try again.',
        ),
      );
    }
  }

  Future<bool> save() async {
    emit(state.copyWith(saving: true));
    try {
      final saved = await dataSource.saveTemplate(state.template);
      emit(state.copyWith(saving: false, template: saved));
      return true;
    } catch (_) {
      emit(state.copyWith(saving: false));
      return false;
    }
  }

  void resetToDefaults() => emit(
    state.copyWith(
      template: BrollTemplateModel.defaults(),
      clearLocalAssetPreviewPath: true,
    ),
  );

  static String _contentTypeFor(String filename) {
    final ext = filename.toLowerCase().split('.').last;
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'webm':
        return 'video/webm';
      default:
        return 'application/octet-stream';
    }
  }
}
