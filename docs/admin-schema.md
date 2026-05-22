# Admin schema additions

This doc lists the additions BoardMate (the Flutter app) now reads from
Firestore, so the admin tool can author them. Everything described here is
**additive and optional** — guides that omit these fields continue to render
correctly with the prior layout.

## Setup steps — `elements`

Path: `games/{gameId}/guide/content`, inside each item of `setupSteps[]`.

```jsonc
{
  "order": 1,
  "title": "Build the island",
  "body": "Arrange the 19 hex tiles...",
  // existing fields: tip, warning, illustrationKey, checklist, rules, images

  // NEW — optional. When present, the BoardMate setup screen renders a
  // horizontal strip of tappable cards above the mascot speech bubble. Tapping
  // a card switches the bubble to the element's `message` and briefly changes
  // the mascot's mood to `moodKey`.
  "elements": [
    {
      "name":     "Hex tiles",                      // required, label on card
      "iconKey":  "hex",                            // optional, icon registry key
      "photoKey": null,                             // optional, photo registry key
      "message":  "Each hex is a resource — ...",   // required, bubble text
      "moodKey":  "reading"                         // optional, mascot mood
    }
  ]
}
```

### Field rules

| field      | type      | required | notes |
|------------|-----------|----------|-------|
| `name`     | string    | yes      | Short label (~1–2 words). Wraps at 2 lines on the card. |
| `iconKey`  | string?   | no       | Resolves against the icon registry (`hex`, `dice`, `cards`, `settlement`, `road`, `house`, `warning`, `compass`, etc.). Falls back to a generic dice icon if unknown. |
| `photoKey` | string?   | no       | Resolves against the Unsplash photo registry. Use when an icon doesn't capture the piece. Either icon or photo is enough; if both, photo wins. |
| `message`  | string    | yes      | What the mascot says when the card is tapped. Sentence-style; ~12–24 words is a good range. |
| `moodKey`  | string?   | no       | One of: `welcome`, `thinking`, `teaching`, `reading`, `curious`, `celebrating`. Unknown values fall back to `reading`. |

The element strip is omitted entirely when `elements` is missing, `null`, or
an empty array. There is no per-game minimum; author whichever steps benefit
from it.

## Icon registry — currently supported keys

Approximate list (BoardMate's `bm_concept_image.dart`). Unknown keys fall back
to a dice icon, so prefer one of these:

`dice`, `dice-pair`, `spinner`, `meeple`, `pawn`, `king`, `queen`, `rook`,
`bishop`, `knight`, `card`, `cards`, `deck`, `hand`, `hex`, `tile`, `board`,
`grid`, `coin`, `gem`, `token`, `cube`, `star`, `heart`, `point`, `wheat`,
`wood`, `sheep`, `brick`, `ore`, `fish`, `bird`, `house`, `settlement`,
`city`, `castle`, `road`, `route`, `train`, `compass`, `map`, `players`,
`team`, `turn`, `whisper`, `eye`, `speech`, `flag`, `target`, `check`,
`warning`, `clock`, `hourglass`, `arrow`.

## How To Play — no schema change

The new tap-to-reveal interaction on the How To Play screen reuses the
existing `setupSteps[].rules[]` / `howToPlaySteps[].rules[]` shape (`number`,
`title`, `body`). No edits needed in the admin tool for that screen.

## Backward compatibility

- BoardMate parses `elements` defensively: missing fields default to safe
  values, unknown `iconKey`/`moodKey` values fall back. No crash if the field
  is malformed — the worst case is a step rendering without its element strip.
- Existing games (without `elements`) keep their current rendering exactly.
