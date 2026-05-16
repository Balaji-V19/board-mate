import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.photoUrl,
  });

  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;

  String get initials {
    if (displayName.trim().isEmpty) {
      return email.isEmpty ? '?' : email[0].toUpperCase();
    }
    final parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  List<Object?> get props => [uid, email, displayName, photoUrl];
}
