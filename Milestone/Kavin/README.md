# Kavin - Milestone 1

Four project Verilog files, plus the unchanged ECE241 VGA starter code.
The display shows eight white keys, highlights the active note green, and
uses a coloured bar to show the game phase.

## Read the code in this order

1. **`game_fsm.v`**: one clocked `case` statement changes the game phase:
   IDLE -> RECORD -> REPLAY -> MATCH -> RESULT. A new start begins another round.
   Empty recordings cannot advance to REPLAY.
2. **`frame_writer.v`**: the first `always` block chooses a pixel's colour.
   The second moves across the screen, one pixel per clock. At the end of each
   screen it saves the latest note and phase before drawing again.
3. **`kavin_milestone1.v`**: wires the FSM and writer to the official VGA adapter.
4. **`kavin_board_demo.v`**: connects switches and reset for a standalone VGA test.
   Its two-stage registers synchronize the physical inputs to the board clock.

The writer works directly in **160x120 coordinates**. Each stored pixel becomes
a 4x4 square on the monitor. Colours are nine bits: `RRR_GGG_BBB`, with three
bits per red, green and blue channel. No coordinate scaling or colour conversion
is needed in the project code.

A full screen takes 19,201 clocks (about 0.384 ms at 50 MHz). Redrawing the whole
screen is simple and erases the previous highlight. This is a single framebuffer;
updates are not guaranteed to be tear-free relative to the monitor scan.

## Test on your Mac

Requires Icarus Verilog and Make. From this folder:

```sh
make          # three simulation suites, then compile both tops
make -B test  # force all simulations to run again
```

Tests check FSM transitions, all eight key highlights and borders, screen write
coverage, consistent updates, released-note erasure, and the course adapter's
VGA frame and RGB output. Build files go into ignored `.build/`.

**Local simulation uses simplified RAM/PLL models** in `tests/sim/` because
Icarus does not provide Intel's FPGA primitives. Those models do not check PLL
lock/timing, MIF loading or read/write collisions. The RAM zero-fills to match
our black MIF. Quartus uses the real supplied IP instead. Missing-timescale
warnings in supplied code are suppressed; other warnings stay enabled.

## Test on the DE1-SoC

Open **`kavin.qpf`** in Quartus. The top is `kavin_board_demo`; clock, VGA, reset
and switch pins come from the course's DE1-SoC COLORS example.

1. Compile, inspect timing/resources and program the board.
2. Press KEY[0] to reset.
3. Use SW[2:0] to select C, D, E, F, G, A, B or upper C (IDs 0..7).
4. SW[3] high highlights that note; low releases it.

This VGA-only demo stays in IDLE. It has no keyboard or sound yet. Changing
multiple switches may briefly select an intermediate note. Clock constraints
are included, but I/O constraints, timing closure and monitor compatibility
still need review on ECF. Quartus/ModelSim/hardware have not been verified here.

## Connect Saajan's modules

Use `kavin_milestone1` in the final board wrapper. All inputs use `CLOCK_50`:

| Signal | Meaning |
| --- | --- |
| `reset` | Active-high reset held across at least one clock edge |
| `note_id`, `note_active` | Note ID 0..7 and high while that note is sounding |
| `start` | One-clock pulse: begin a round from IDLE or RESULT |
| `finish_record` | One-clock pulse: end recording, including a future full-memory condition |
| `sequence_nonempty` | At least one note is stored |
| `replay_done`, `match_done` | One-clock completion pulses from future modules |
| `game_state` | 0=IDLE, 1=RECORD, 2=REPLAY, 3=MATCH, 4=RESULT |
| `record_enable`, `replay_enable`, `match_enable` | Phase enables for other modules |

Synchronize/debounce physical controls before producing command pulses. Future
memory/score logic must clear its length, indices and score on entry into RECORD.
The FSM does not store that data. Keep unused control inputs low; the display
still highlights notes in IDLE. The phase bar is blue/red/yellow/green/purple
for IDLE/RECORD/REPLAY/MATCH/RESULT respectively.

Keyboard/audio, recording memory, matching, scoring and text are later work.

## Course code and ModelSim

The supplied `vga_adapter/` files handle memory, VGA timing and the pixel clock.
Source: https://q.utoronto.ca/courses/468637/pages/vga-adapter
See [COURSE_SOURCES.md](COURSE_SOURCES.md) for attribution and original checksums.

On ECF, run `ModelSim/waveform.do` from the ModelSim folder with Intel libraries
mapped. It uses the real supplied PLL and Intel simulation libraries, not the
Icarus models. This waveform script is prepared but has not been run here.
