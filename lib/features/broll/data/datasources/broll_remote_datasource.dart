import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/broll_template_model.dart';
import '../models/broll_upload_presign_model.dart';

abstract class BrollRemoteDataSource {
  /// `GET /api/v1/broll/template` — the user's saved overlay template.
  Future<BrollTemplateModel> getTemplate();

  /// `PATCH /api/v1/broll/template` — saves the full template, returns the
  /// server's copy (with the refreshed `updated_at`).
  Future<BrollTemplateModel> saveTemplate(BrollTemplateModel template);

  /// `POST /api/v1/broll/assets/uploads/presign` — a short-lived signed URL
  /// to upload [filename] (of [contentType]) straight to object storage.
  Future<BrollUploadPresignModel> presignUpload({
    required String filename,
    required String contentType,
  });

  /// PUTs the raw file bytes to the presigned [uploadUrl] returned above.
  Future<void> uploadToPresignedUrl({
    required String uploadUrl,
    required List<int> bytes,
    required String contentType,
  });
}

class BrollRemoteDataSourceImpl implements BrollRemoteDataSource {
  final DioClient client;
  const BrollRemoteDataSourceImpl(this.client);

  @override
  Future<BrollTemplateModel> getTemplate() async {
    final response = await client.get(ApiConstants.brollTemplate);
    return BrollTemplateModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<BrollTemplateModel> saveTemplate(BrollTemplateModel template) async {
    final response = await client.patch(
      ApiConstants.brollTemplate,
      data: template.toJson(),
    );
    return BrollTemplateModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<BrollUploadPresignModel> presignUpload({
    required String filename,
    required String contentType,
  }) async {
    final response = await client.post(
      ApiConstants.brollUploadPresign,
      data: {'filename': filename, 'content_type': contentType},
    );
    return BrollUploadPresignModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<void> uploadToPresignedUrl({
    required String uploadUrl,
    required List<int> bytes,
    required String contentType,
  }) async {
    // A bare Dio — the presigned URL's signature only covers
    // content-type/host, and the app's bearer token has no business being
    // sent to third-party object storage.
    await Dio().put(
      uploadUrl,
      data: Stream.fromIterable([bytes]),
      options: Options(
        headers: {
          Headers.contentTypeHeader: contentType,
          Headers.contentLengthHeader: bytes.length,
        },
      ),
    );
  }
}
