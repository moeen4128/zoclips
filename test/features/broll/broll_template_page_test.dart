import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zoclips/core/theme/app_theme.dart';
import 'package:zoclips/core/widgets/shimmer.dart';
import 'package:zoclips/features/broll/data/datasources/broll_remote_datasource.dart';
import 'package:zoclips/features/broll/data/models/broll_template_model.dart';
import 'package:zoclips/features/broll/data/models/broll_upload_presign_model.dart';
import 'package:zoclips/features/broll/presentation/cubit/broll_template_cubit.dart';
import 'package:zoclips/features/broll/presentation/pages/broll_template_page.dart';
import 'package:zoclips/injection_container.dart';

/// Resolves [getTemplate] only once pumped past its delay, so the test can
/// observe the loading state before it settles.
class _SlowBrollRemoteDataSource implements BrollRemoteDataSource {
  @override
  Future<BrollTemplateModel> getTemplate() async {
    await Future.delayed(const Duration(seconds: 2));
    return BrollTemplateModel.defaults();
  }

  @override
  Future<BrollTemplateModel> saveTemplate(BrollTemplateModel template) async =>
      template;

  @override
  Future<BrollUploadPresignModel> presignUpload({
    required String filename,
    required String contentType,
  }) => throw UnimplementedError();

  @override
  Future<void> uploadToPresignedUrl({
    required String uploadUrl,
    required List<int> bytes,
    required String contentType,
  }) => throw UnimplementedError();
}

void main() {
  testWidgets('shows a shimmer skeleton while loading, not a spinner', (
    tester,
  ) async {
    sl.registerFactory<BrollTemplateCubit>(
      () => BrollTemplateCubit(_SlowBrollRemoteDataSource()),
    );
    addTearDown(() => sl.unregister<BrollTemplateCubit>());

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.darkTheme, home: const BrollTemplatePage()),
    );
    await tester.pump();

    expect(find.byType(Shimmer), findsOneWidget);
    expect(find.byType(ShimmerBox), findsWidgets);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // Let the slow load resolve so the pending timer doesn't leak past the
    // test.
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('B-Roll Template'), findsOneWidget);
  });
}
