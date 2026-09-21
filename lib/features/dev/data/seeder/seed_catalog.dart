import 'seed_models.dart';
import 'tracks/flutter.dart';
import 'tracks/kotlin.dart';
import 'tracks/react_native.dart';
import 'tracks/swift.dart';

/// Combined catalog of every track the app ships. This is the single source the
/// `AppSeeder` writes to Firestore.
final List<SeedTrack> seedTracks = [
  kotlinTrack,
  swiftTrack,
  flutterTrack,
  reactNativeTrack,
];
