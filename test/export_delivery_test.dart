import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:file_picker_platform_interface/file_picker_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:stackprep/core/error/failures.dart';
import 'package:stackprep/core/usecases/usecase.dart';
import 'package:stackprep/features/export/data/progress_report_exporter.dart';
import 'package:stackprep/features/export/domain/usecases/build_progress_report.dart';
import 'package:stackprep/features/onboarding/domain/usecases/get_stack_tracks.dart';
import 'package:stackprep/features/progress/domain/entities/progress_overview.dart';
import 'package:stackprep/features/progress/domain/repositories/progress_repository.dart';
import 'package:stackprep/features/progress/domain/usecases/get_progress_overview.dart';

/// Records what the system save picker was asked to do, and answers with
/// whatever a phone would hand back.
class _FakeFilePicker extends FilePickerPlatform {
  _FakeFilePicker({this.result});

  /// The URI the picker resolves to, or null to stand in for the user closing
  /// the dialog.
  final Uri? result;

  String? savedFileName;
  Uint8List? savedBytes;
  String? savedMimeType;

  @override
  Future<Uri?> saveFile({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
    String? dialogTitle,
    String? initialDirectory,
    Function(FilePickerStatus)? onFileSaving,
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async {
    savedFileName = fileName;
    savedBytes = bytes;
    savedMimeType = mimeType;
    return result;
  }
}

/// Stands in for a device that can answer every path_provider lookup.
///
/// The real implementations hand back directories that already exist, so the
/// fake creates them too.
class _FakePathProvider extends PathProviderPlatform {
  _FakePathProvider(this.root, {this.downloadsAvailable = true});

  final String root;
  final bool downloadsAvailable;

  String _existing(String name) {
    final dir = Directory('$root/$name')..createSync(recursive: true);
    return dir.path;
  }

  @override
  Future<String?> getDownloadsPath() async =>
      downloadsAvailable ? _existing('Downloads') : null;

  @override
  Future<String?> getApplicationDocumentsPath() async => _existing('Documents');

  @override
  Future<String?> getTemporaryPath() async => _existing('tmp');

  @override
  Future<String?> getApplicationSupportPath() async => _existing('Support');
}

class _ThrowingPathProvider extends PathProviderPlatform {
  @override
  Future<String?> getDownloadsPath() async =>
      throw UnimplementedError('no downloads');

  @override
  Future<String?> getApplicationDocumentsPath() async =>
      throw UnimplementedError('no documents');

  @override
  Future<String?> getTemporaryPath() async =>
      throw UnimplementedError('no temp');
}

/// Answers only the temp folder, so it is the last resort in the chain.
class _TempOnlyProvider extends PathProviderPlatform {
  _TempOnlyProvider(this.root);

  final String root;

  @override
  Future<String?> getDownloadsPath() async => null;

  @override
  Future<String?> getApplicationDocumentsPath() async =>
      throw UnimplementedError('no documents');

  @override
  Future<String?> getTemporaryPath() async {
    final dir = Directory('$root/tmp')..createSync(recursive: true);
    return dir.path;
  }
}

/// Claims a Downloads folder that does not exist, which is what a headless or
/// freshly installed Linux account looks like.
class _MissingDownloadsProvider extends PathProviderPlatform {
  _MissingDownloadsProvider(this.root);

  final String root;

  @override
  Future<String?> getDownloadsPath() async => '$root/does-not-exist';

  @override
  Future<String?> getApplicationDocumentsPath() async {
    final dir = Directory('$root/Documents')..createSync(recursive: true);
    return dir.path;
  }

  @override
  Future<String?> getTemporaryPath() async {
    final dir = Directory('$root/tmp')..createSync(recursive: true);
    return dir.path;
  }
}

class _EmptyProgressRepository implements ProgressRepository {
  @override
  Future<Either<Failure, ProgressOverview>> getProgressOverview() async =>
      const Left(CacheFailure('unused'));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _EmptyGetStackTracks implements GetStackTracks {
  @override
  Future<Either<Failure, List<Never>>> call(NoParams params) async =>
      const Right(<Never>[]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ProgressReportExporter _exporter() => ProgressReportExporter(
  buildReport: BuildProgressReport(
    getProgressOverview: GetProgressOverview(
      repository: _EmptyProgressRepository(),
    ),
    getStackTracks: _EmptyGetStackTracks(),
  ),
);

/// A recognisable, valid PDF header followed by filler.
Uint8List _pdfBytes() {
  final header = '%PDF-1.4 test'.codeUnits;
  return Uint8List.fromList([...header, ...List.filled(64, 0x20)]);
}

void main() {
  late Directory root;
  late ProgressReportExporter exporter;
  late FilePickerPlatform originalFilePicker;

  setUp(() {
    root = Directory.systemTemp.createTempSync('stackprep-export-test');
    PathProviderPlatform.instance = _FakePathProvider(root.path);
    originalFilePicker = FilePickerPlatform.instance;
    // `flutter test` reports Android by default, which would send every save
    // below through the system picker. These cases are about the desktop
    // folder-resolution chain, so start from a desktop target.
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    exporter = _exporter();
  });

  tearDown(() {
    if (root.existsSync()) root.deleteSync(recursive: true);
    FilePickerPlatform.instance = originalFilePicker;
    debugDefaultTargetPlatformOverride = null;
  });

  // This is the case that was broken: there is no print dialog to fall back
  // on, so the report has to be written straight to a real file.
  test('writes a valid PDF into Downloads', () async {
    final result = (await exporter.save(_pdfBytes(), 'report.pdf'))!;

    expect(result.path, '${root.path}/Downloads/report.pdf');
    expect(result.location, 'Report saved to ${root.path}/Downloads/report.pdf');
    final file = File(result.path);
    expect(file.existsSync(), isTrue);
    expect(file.readAsBytesSync().sublist(0, 5), '%PDF-'.codeUnits);
  });

  test('behaves identically on every desktop platform', () async {
    for (final platform in [
      TargetPlatform.linux,
      TargetPlatform.macOS,
      TargetPlatform.windows,
    ]) {
      debugDefaultTargetPlatformOverride = platform;

      final result = (await exporter.save(_pdfBytes(), 'report.pdf'))!;

      expect(
        result.path,
        '${root.path}/Downloads/report.pdf',
        reason: 'on $platform',
      );
    }
  });

  test('falls through to the documents folder without Downloads', () async {
    PathProviderPlatform.instance = _FakePathProvider(
      root.path,
      downloadsAvailable: false,
    );

    final result = (await exporter.save(_pdfBytes(), 'report.pdf'))!;

    expect(result.path, '${root.path}/Documents/report.pdf');
    expect(File('${root.path}/Documents/report.pdf').existsSync(), isTrue);
  });

  test(
    'falls through to a temp folder when nothing else is available',
    () async {
      PathProviderPlatform.instance = _TempOnlyProvider(root.path);

      final result = (await exporter.save(_pdfBytes(), 'report.pdf'))!;

      expect(result.path, '${root.path}/tmp/report.pdf');
      expect(File('${root.path}/tmp/report.pdf').existsSync(), isTrue);
    },
  );

  test('falls through when Downloads is reported but does not exist', () async {
    // path_provider can hand back a folder that is not actually there, and the
    // write is what discovers it.
    PathProviderPlatform.instance = _MissingDownloadsProvider(root.path);

    final result = (await exporter.save(_pdfBytes(), 'report.pdf'))!;

    expect(result.path, '${root.path}/Documents/report.pdf');
    expect(File('${root.path}/Documents/report.pdf').existsSync(), isTrue);
  });

  test('reports a failure when nothing is writable', () async {
    PathProviderPlatform.instance = _ThrowingPathProvider();

    await expectLater(
      exporter.save(_pdfBytes(), 'report.pdf'),
      throwsA(isA<CacheFailure>()),
    );
  });

  // Phones have no writable Downloads folder, so the bytes go through the
  // system document provider instead of a path_provider directory.
  test('hands the PDF to the system save picker on phones', () async {
    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      final picker = _FakeFilePicker(
        result: Uri.parse('content://externalstorage/document/report.pdf'),
      );
      FilePickerPlatform.instance = picker;
      debugDefaultTargetPlatformOverride = platform;

      final bytes = _pdfBytes();
      final result = (await exporter.save(bytes, 'report.pdf'))!;

      expect(result.path, 'content://externalstorage/document/report.pdf');
      // The URI is meaningless to a person, so only the file name is shown.
      expect(result.location, 'Report saved as report.pdf');
      expect(picker.savedFileName, 'report.pdf');
      expect(picker.savedMimeType, 'application/pdf');
      expect(picker.savedBytes, bytes, reason: 'on $platform');
    }
  });

  test('treats a dismissed save picker as a cancellation', () async {
    FilePickerPlatform.instance = _FakeFilePicker();
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    final result = await exporter.save(_pdfBytes(), 'report.pdf');

    expect(result, isNull);
  });
}
