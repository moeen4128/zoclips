import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import '../widgets/app_snackbar.dart';

/// Downloads [url] to a temp file then saves it to the device's photo
/// gallery (Gal needs a local path — it can't save straight from a URL),
/// handling permission prompts and surfacing success/failure as a snackbar.
/// Returns true on success, so callers can update their own loading state.
Future<bool> downloadVideoToGallery({
  required BuildContext context,
  required String url,
  required String fileName,
  String album = 'Zoclips',
}) async {
  try {
    if (!await Gal.hasAccess()) {
      final granted = await Gal.requestAccess();
      if (!granted) {
        if (context.mounted) {
          AppSnackbar.error(
            context,
            'Photos access is needed to save this clip.',
          );
        }
        return false;
      }
    }
    final tempPath = '${Directory.systemTemp.path}/$fileName';
    await Dio().download(url, tempPath);
    await Gal.putVideo(tempPath, album: album);
    if (context.mounted) {
      AppSnackbar.info(context, 'Saved to gallery');
    }
    return true;
  } on GalException catch (e) {
    if (context.mounted) {
      AppSnackbar.error(context, e.type.message);
    }
    return false;
  } catch (_) {
    if (context.mounted) {
      AppSnackbar.error(context, 'Could not download this clip.');
    }
    return false;
  }
}
