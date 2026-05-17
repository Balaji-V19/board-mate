/// Attribution data for third-party images used as game cover photos and
/// guide-step references. Wikimedia Commons photos are user-submitted under
/// Creative Commons licences and require credit. Unsplash photos do not
/// strictly require attribution but we credit photographers anyway.
class ImageCredit {
  const ImageCredit({
    required this.label,
    required this.author,
    required this.license,
    required this.sourcePage,
  });

  /// What this image represents in the app (e.g. "Catan — cover").
  final String label;

  /// Photographer or uploader name as listed on the source page.
  final String author;

  /// License short name, e.g. "CC BY-SA 4.0", "CC BY 2.0", "Unsplash".
  final String license;

  /// URL where the original file + its licence terms live.
  final String sourcePage;
}

const imageCredits = <ImageCredit>[
  ImageCredit(
    label: 'Catan — cover',
    author: 'Wikimedia Commons contributors',
    license: 'CC BY-SA',
    sourcePage:
        'https://commons.wikimedia.org/wiki/File:Seafarers_of_Catan_-_Midgame.jpg',
  ),
  ImageCredit(
    label: 'Ticket to Ride — cover',
    author: 'Wikimedia Commons contributors',
    license: 'CC BY-SA',
    sourcePage:
        'https://commons.wikimedia.org/wiki/File:Ticket_to_Ride_Europe_starting.jpg',
  ),
  ImageCredit(
    label: 'Codenames — cover',
    author: 'Wikimedia Commons contributors',
    license: 'CC BY-SA',
    sourcePage:
        'https://commons.wikimedia.org/wiki/File:Codenames_board_game.jpg',
  ),
  ImageCredit(
    label: 'Pandemic — cover',
    author: 'Wikimedia Commons contributors',
    license: 'CC BY-SA',
    sourcePage:
        'https://commons.wikimedia.org/wiki/File:Pandemic_board_game.jpg',
  ),
  ImageCredit(
    label: 'Wingspan — cover',
    author: 'Wikimedia Commons contributors',
    license: 'CC BY-SA',
    sourcePage:
        'https://commons.wikimedia.org/wiki/File:Cards_in_Wingspan_board_game.jpg',
  ),
  ImageCredit(
    label: 'Chess — cover',
    author: 'Wikimedia Commons contributors',
    license: 'CC BY-SA',
    sourcePage:
        'https://commons.wikimedia.org/wiki/File:Plastic_chess_pieces.jpg',
  ),
  ImageCredit(
    label: 'Carcassonne — cover',
    author: 'Wikimedia Commons contributors',
    license: 'CC BY-SA',
    sourcePage:
        'https://commons.wikimedia.org/wiki/File:Carcassone_jogo-game.jpg',
  ),
  ImageCredit(
    label: '7 Wonders — cover',
    author: 'Marcin Wichary (Wikimedia Commons)',
    license: 'CC BY-SA',
    sourcePage:
        'https://commons.wikimedia.org/wiki/File:7_Wonders_game.jpg',
  ),
  ImageCredit(
    label: 'Splendor, Azul, King of Tokyo — covers',
    author: 'Unsplash placeholders (no CC photos available on Wikimedia)',
    license: 'Unsplash Licence',
    sourcePage: 'https://unsplash.com/license',
  ),
  ImageCredit(
    label: 'Guide step photos',
    author: 'Various Unsplash photographers',
    license: 'Unsplash Licence',
    sourcePage: 'https://unsplash.com/license',
  ),
];
