import 'package:cross_file/cross_file.dart';
import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stackprep/core/error/failures.dart';
import 'package:stackprep/features/auth/domain/entities/app_user.dart';
import 'package:stackprep/features/export/data/progress_pdf_generator.dart';
import 'package:stackprep/features/export/domain/entities/progress_report.dart';
import 'package:stackprep/features/export/domain/usecases/build_progress_report.dart';

/// The PDF was written somewhere the user can reach.
class ExportSaved {
  const ExportSaved({required this.path, required this.name, this.folder});

  /// Where the file landed.
  ///
  /// A real filesystem path on desktop and the web. On a phone it comes from
  /// the system save picker, where it is an opaque `content://` or `file://`
  /// URI that a person cannot act on.
  final String path;

  /// The name the file was saved under.
  final String name;

  /// The folder the file went into, or null when the platform never names one:
  /// the web triggers a browser download, and a phone's save picker only hands
  /// back a URI.
  final String? folder;

  /// The line shown to the user after a successful save, because nothing on
  /// screen points at the file otherwise.
  String get location => folder == null
      ? 'Report saved as $name'
      : 'Report saved to $folder/$name';
}

/// Drives the Export Data flow end to end: pull live data, render the PDF,
/// then deliver it through whichever mechanism the platform actually supports.
class ProgressReportExporter {
  ProgressReportExporter({
    required BuildProgressReport buildReport,
    ProgressPdfGenerator generator = const ProgressPdfGenerator(),
  }) : _buildReport = buildReport,
       _generator = generator;

  final BuildProgressReport _buildReport;
  final ProgressPdfGenerator _generator;

  Future<Either<Failure, ProgressReport>> build({AppUser? user}) {
    return _buildReport(
      BuildProgressReportParams(user: user, generatedAt: DateTime.now()),
    );
  }

  Future<Either<Failure, Uint8List>> generate(ProgressReport report) async {
    try {
      return Right(await _generator.generate(report));
    } catch (error, stackTrace) {
      debugPrint('PDF generation failed: $error\n$stackTrace');
      return const Left(CacheFailure('Could not generate the report.'));
    }
  }

  /// Saves the PDF and returns where it landed, or null if the user backed out
  /// of the system save picker.
  ///
  /// Phones are routed through the platform save picker because neither Android
  /// nor iOS gives an app a writable "Downloads" folder: iOS has no such folder
  /// in its sandbox at all, and Android has blocked direct writes to external
  /// storage since API 29. The picker hands the bytes to the system document
  /// provider instead, which is the only supported way to reach Downloads.
  ///
  /// Everywhere else the file is written straight to a real folder. There is no
  /// print dialog in that path on purpose: the `printing` plugin's save channel
  /// is not implemented on Linux, so relying on it means Save either crashes or
  /// silently does nothing.
  Future<ExportSaved?> save(Uint8List bytes, String name) async {
    if (_usesSystemPicker) {
      final uri = await FilePicker.saveFile(
        dialogTitle: _dialogTitle,
        fileName: name,
        bytes: bytes,
        mimeType: _mimeType,
      );
      // A null result means the user dismissed the picker. That is not a
      // failure, so it is reported as a cancellation rather than an error.
      if (uri == null) return null;
      return ExportSaved(path: uri.toString(), name: name);
    }
    return _writeToUserFolder(bytes, name);
  }

  /// Writes the PDF to the most user-facing writable location available, and
  /// returns where it landed. On the web this downloads the file instead.
  ///
  /// The write goes through [XFile.saveTo] rather than [File] so the same code
  /// path works on the web, where it triggers a browser download.
  Future<ExportSaved> _writeToUserFolder(Uint8List bytes, String name) async {
    if (kIsWeb) {
      await _writeTo(bytes, name);
      return ExportSaved(path: name, name: name);
    }

    Object? lastError;
    for (final candidate in _directoryCandidates) {
      try {
        final dir = await candidate();
        if (dir == null) continue;
        final path = '$dir/$name';
        // The write is part of the chain, not a separate step: a folder can be
        // reported as available and still be missing or read-only.
        await _writeTo(bytes, path);
        return ExportSaved(path: path, name: name, folder: dir);
      } catch (error) {
        lastError = error;
        debugPrint('Could not write there, trying the next folder: $error');
      }
    }
    throw CacheFailure(
      'Could not save the report.${lastError == null ? '' : ' ($lastError)'}',
    );
  }

  /// Phones save through the system picker; every other target has a real
  /// folder the app can write to directly.
  bool get _usesSystemPicker =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> _writeTo(Uint8List bytes, String path) {
    return XFile.fromData(bytes, mimeType: _mimeType, name: path).saveTo(path);
  }

  /// Folders to try, most user-facing first.
  ///
  /// These resolve to a path rather than a `Directory` so this file stays free
  /// of `dart:io` and therefore still compiles for the web.
  List<Future<String?> Function()> get _directoryCandidates => [
    () async => (await getDownloadsDirectory())?.path,
    () async => (await getApplicationDocumentsDirectory()).path,
    () async => (await getTemporaryDirectory()).path,
  ];

  static const String _mimeType = 'application/pdf';
  static const String _dialogTitle = 'Save progress report';
}
