/// Single source of truth for external legal URLs surfaced in Settings.
///
/// Replace each `TODO` URL with the GitHub-hosted (or anywhere-hosted) page
/// once it's live. The app reads these as `https://…` and opens them in the
/// system browser via `url_launcher`.
///
/// Keeping them in one file means you never have to grep the codebase when
/// you publish or change a hosted document.
class LegalLinks {
  LegalLinks._();

  /// Privacy policy. Required for App Store / Play Store submission.
  static const String privacyPolicyUrl =
      'https://github.com/Balaji-V19/board-mate/blob/main/legal/PRIVACY.md';

  /// Terms of service. Optional but recommended.
  static const String termsOfServiceUrl =
      'https://github.com/Balaji-V19/board-mate/blob/main/legal/TERMS.md';

  /// Support landing page — referenced from the "Help & FAQ" row in Settings
  /// and submitted to App Store Connect as the required Support URL.
  static const String supportUrl =
      'https://github.com/Balaji-V19/board-mate/blob/main/SUPPORT.md';

  /// Copyright line shown at the bottom of Settings.
  static const String copyrightOwner = 'Balaji Venkatachalam';
  static const String copyrightYear = '2026';
  static String get copyrightLine =>
      '© $copyrightYear $copyrightOwner. All rights reserved.';
}
