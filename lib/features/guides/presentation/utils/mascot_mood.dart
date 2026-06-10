import '../../../mascot/domain/entities/mascot_mood.dart';

/// Maps a string mood key from authored content (setup elements, etc.) to
/// the [MascotMood] enum used by the speech bubble. Defaults to
/// [MascotMood.reading] for null or unknown keys.
MascotMood mascotMoodFromKey(String? key) {
  switch (key) {
    case 'welcome':
      return MascotMood.welcome;
    case 'thinking':
      return MascotMood.thinking;
    case 'teaching':
      return MascotMood.teaching;
    case 'curious':
      return MascotMood.curious;
    case 'celebrating':
      return MascotMood.celebrating;
    case 'reading':
    default:
      return MascotMood.reading;
  }
}
