import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../../domain/entities/app_user.dart';

/// Data-layer representation of [AppUser] with a Firebase mapping.
class UserModel extends Equatable {
  const UserModel({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
  });

  factory UserModel.fromFirebase(fb.User user) => UserModel(
    uid: user.uid,
    email: user.email,
    displayName: user.displayName,
    photoUrl: user.photoURL,
  );

  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  AppUser toEntity() => AppUser(
    uid: uid,
    email: email,
    displayName: displayName,
    photoUrl: photoUrl,
  );

  @override
  List<Object?> get props => [uid, email, displayName, photoUrl];
}
