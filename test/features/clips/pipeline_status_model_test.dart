import 'package:flutter_test/flutter_test.dart';
import 'package:zoclips/features/clips/data/models/pipeline_status_model.dart';

void main() {
  test('parses the exact pipeline-status example from the Swagger docs', () {
    final json = {
      'clip_id': '3fa85f64-5717-4562-b3fc-2c963f66afa6',
      'editing_plan_id': '3fa85f64-5717-4562-b3fc-2c963f66afa6',
      'editing_plan_status': 'pending',
      'camera_analysis_id': '3fa85f64-5717-4562-b3fc-2c963f66afa6',
      'camera_analysis_status': 'pending',
      'timeline_direction_id': '3fa85f64-5717-4562-b3fc-2c963f66afa6',
      'timeline_direction_status': 'pending',
      'latest_render': {
        'id': '3fa85f64-5717-4562-b3fc-2c963f66afa6',
        'clip_candidate_id': '3fa85f64-5717-4562-b3fc-2c963f66afa6',
        'editing_plan_id': '3fa85f64-5717-4562-b3fc-2c963f66afa6',
        'status': 'queued',
        'progress': 0,
        'error_message': 'string',
        'started_at': '2026-09-11T09:01:53.862Z',
        'completed_at': '2026-09-11T09:01:53.862Z',
        'render_time_seconds': 0,
        'output_url': 'string',
        'thumbnail_url': 'string',
        'created_at': '2026-09-11T09:01:53.862Z',
      },
      'error_message': 'string',
      'publish_status': 'scheduled',
      'published_url': 'string',
    };

    final status = PipelineStatusModel.fromJson(json);

    expect(status.clipId, '3fa85f64-5717-4562-b3fc-2c963f66afa6');
    expect(status.editingPlanStatus, 'pending');
    expect(status.publishStatus, 'scheduled');
    expect(status.latestRender, isNotNull);
    expect(status.latestRender!.status, 'queued');
    expect(status.latestRender!.outputUrl, 'string');
    expect(status.latestRender!.hasOutput, isTrue);
    expect(status.publishedUrl, 'string');
  });

  test('parses a real published clip response', () {
    final status = PipelineStatusModel.fromJson({
      'clip_id': 'f86312b9-a75c-42dd-88d0-8b9db2a182fc',
      'editing_plan_status': 'ready',
      'camera_analysis_status': 'ready',
      'timeline_direction_status': 'ready',
      'latest_render': {
        'id': 'e842bdfd-b673-4c6b-a523-6a981cda449c',
        'status': 'completed',
        'progress': 100,
        'output_url': 'https://example.com/clip.mp4',
        'thumbnail_url': 'https://example.com/clip_thumb.jpg',
      },
      'error_message': null,
      'publish_status': 'published',
      'published_url': 'https://www.youtube.com/watch?v=_Zr38BCRRvg',
    });

    expect(status.publishStatus, 'published');
    expect(status.publishedUrl, 'https://www.youtube.com/watch?v=_Zr38BCRRvg');
  });

  test('treats a missing/empty output_url as not having output', () {
    final status = PipelineStatusModel.fromJson({
      'clip_id': 'abc',
      'editing_plan_status': 'pending',
      'camera_analysis_status': 'pending',
      'timeline_direction_status': 'pending',
      'publish_status': 'draft',
      'latest_render': {'id': 'r1', 'status': 'processing', 'progress': 40},
    });

    expect(status.latestRender!.hasOutput, isFalse);
    expect(status.latestRender!.progress, 40);
  });

  test('tolerates a null latest_render (not queued yet)', () {
    final status = PipelineStatusModel.fromJson({
      'clip_id': 'abc',
      'editing_plan_status': 'pending',
      'camera_analysis_status': 'pending',
      'timeline_direction_status': 'pending',
      'publish_status': 'draft',
    });

    expect(status.latestRender, isNull);
  });
}
