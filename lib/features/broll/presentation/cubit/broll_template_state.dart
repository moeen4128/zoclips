import 'package:equatable/equatable.dart';
import '../../data/models/broll_template_model.dart';

enum BrollPageStatus { loading, loaded, error }

class BrollTemplateState extends Equatable {
  final BrollPageStatus status;
  final String? errorMessage;
  final BrollTemplateModel template;

  /// Local file path of the most recently picked media — shown in the
  /// preview immediately since the uploaded asset lives behind a private,
  /// unsigned storage key with no public GET URL to fetch it back from.
  final String? localAssetPreviewPath;

  final bool uploading;
  final String? uploadError;
  final bool saving;

  const BrollTemplateState._({
    required this.status,
    this.errorMessage,
    required this.template,
    this.localAssetPreviewPath,
    this.uploading = false,
    this.uploadError,
    this.saving = false,
  });

  const BrollTemplateState.initial()
    : this._(
        status: BrollPageStatus.loading,
        template: const BrollTemplateModel(
          enabled: false,
          position: 'bottom-right',
          sizePreset: 'medium',
          customWidth: 25,
          customHeight: 25,
          opacity: 90,
          borderRadius: 12,
          showBorder: true,
          borderColor: '#ffffff',
        ),
      );

  BrollTemplateState copyWith({
    BrollPageStatus? status,
    String? errorMessage,
    BrollTemplateModel? template,
    String? localAssetPreviewPath,
    bool clearLocalAssetPreviewPath = false,
    bool? uploading,
    String? uploadError,
    bool clearUploadError = false,
    bool? saving,
  }) {
    return BrollTemplateState._(
      status: status ?? this.status,
      errorMessage: errorMessage,
      template: template ?? this.template,
      localAssetPreviewPath: clearLocalAssetPreviewPath
          ? null
          : (localAssetPreviewPath ?? this.localAssetPreviewPath),
      uploading: uploading ?? this.uploading,
      uploadError: clearUploadError ? null : (uploadError ?? this.uploadError),
      saving: saving ?? this.saving,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    template,
    localAssetPreviewPath,
    uploading,
    uploadError,
    saving,
  ];
}
