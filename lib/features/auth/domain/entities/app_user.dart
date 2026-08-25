import 'package:equatable/equatable.dart';

/// The signed-in identity, decoupled from any Firebase type so the rest of
/// the domain never depends on firebase_auth.
class AppUser extends Equatable {
  const AppUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
  });

  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  @override
  List<Object?> get props => [uid, email, displayName, photoUrl];
}
