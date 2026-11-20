# Saajan - Milestone 1

Keyboard note-event decoding and tone generation.

## Files

1. **`note_decoder.v`**: keyboard byte -> which note, which player, is the key held.
2. **`tone_gen.v`**: note -> square-wave sound value for the audio controller.

## Keys

| Keys | Meaning |
| --- | --- |
| A S D F | Player 1, notes 0..3 |
| H J K L | Player 2, notes 0..3 (same sounds as Player 1) |

Notes 0..3 = C, D, E, F (262, 294, 330, 349 Hz), matching the labels on Kavin's display. Other keys are ignored.

## Outputs

| Signal | Meaning | Goes to |
| --- | --- | --- |
| `note_id` (2 bits) | Note 0..3 | `tone_gen` and Kavin's `note_id` |
| `player` | 0 = A S D F, 1 = H J K L | Kavin's `active_player` and LEDR[9] |
| `note_on` | 1 while the key is held | `tone_gen` and Kavin's `note_active` |

## Tests

ModelSim: from `ModelSim/`, `do note_decoder.do` or `do tone_gen.do`.
The tone test pretends the clock is 1 MHz so each wave is short enough to see.
